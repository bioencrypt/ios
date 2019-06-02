 //
//  BETransparentAuthentication.m
//  BioEncrypt
//
//

#import "BETransparentAuthentication.h"
#import "BEStartupStore.h"

#import "BECoreDetection.h"


// Crypto
#import "BECrypto.h"

// TrustFactor dataset functions
#import "BETrustFactorDatasets.h"

@implementation BETransparentAuthentication

// Singleton instance
+ (id)sharedTransparentAuth {
    static BETransparentAuthentication *sharedTransparentAuthentication = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTransparentAuthentication = [[self alloc] init];
    });
    return sharedTransparentAuthentication;
}

// Attempt Transparent Authentication for Computation
-  (BETrustScoreComputation *)attemptTransparentAuthenticationForComputation:(BETrustScoreComputation *)computationResults withPolicy:(BEPolicy *)policy withError:(NSError **)error {
    
    // Validate no errors
    if (!computationResults.transparentAuthenticationTrustFactorOutputObjects || computationResults.transparentAuthenticationTrustFactorOutputObjects == nil) {
        
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"No TrustFactorsObjects for transparent authentication processing", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No transparent authentication TrustFactorObjects", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:bioEncryptDomain code:SANoTransparentAuthenticationTrustFactorObjects userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get transparent auth trustfactor objects: %@", errorDetails);
        
        // We stil return computationResults instead of nil so that we can continue even if transparent auth fails
        // A transparent auth failure is not catastrophic
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthError;
        
        // Don't set these here anymore, let the next auth method specified take over instead
        //computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        //computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
        return computationResults;
        
    }
    
    // Get startup store of current transparent authentication key hashes
    // Get our startup file
    //NSError *startupError;
    BEStartup *startup = [[BEStartupStore sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        
        // Error out, no trustFactorOutputObject were able to be added
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:bioEncryptDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get startup file: %@", errorDetails);
        
        // We stil return computationResults instead of nil so that we can continue even if transparent auth fails
        // A transparent auth failure is not catastrophic
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthError;
        
        // Don't set these here anymore, let the next auth method specified take over instead
        //computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        //computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
        return computationResults;
        
    }

    
    // Seed it with the device salt
    NSString *candidateTransparentKeyRawOutputString = startup.deviceSaltString;
    
    // Concat all transparent auth realted TrustFactor output data to comprise the transparent key
    for (BETrustFactorOutputObject *trustFactorOutputObject in computationResults.transparentAuthenticationTrustFactorOutputObjects) {
        
        // Iterate through all output returned by TrustFactor
        for(NSString *output in trustFactorOutputObject.output) {
            
           candidateTransparentKeyRawOutputString = [candidateTransparentKeyRawOutputString stringByAppendingFormat:@",_%@",output];
        }
        
        
    }
    
    
    // Generate the PBKDF2 raw key from concatinated output and set it, salt is created once at startup and used for all PBKDF2 of
    // transparent auth keys - a different salt is used for encryption of the master key by each transparent key
    NSError *transparentKeyError;
    computationResults.candidateTransparentKey = [[BECrypto sharedCrypto] getTransparentKeyForTrustFactorOutput:candidateTransparentKeyRawOutputString withError:&transparentKeyError];
    
    // Validate return value
    if (!computationResults.candidateTransparentKey || computationResults.candidateTransparentKey == nil) {
        
        // Invalid return value
        
        // Check if we received an error
        if (transparentKeyError || transparentKeyError != nil) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error during transparent auth PBKDF2 of candidate transparent key", nil),
                                           NSLocalizedFailureReasonErrorKey: transparentKeyError.localizedFailureReason,
                                           NSLocalizedRecoverySuggestionErrorKey: transparentKeyError.localizedRecoverySuggestion
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:bioEncryptDomain code:SAInvalidPBKDF2TransparentKeyDerivation userInfo:errorDetails];
            
        } else {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Error during transparent auth PBKDF2 of candidate transparent key", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No trustfactor output or missing salt", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:bioEncryptDomain code:SAInvalidPBKDF2TransparentKeyDerivation userInfo:errorDetails];
            
        } // Done checking if we received an error
        
        // Log Error
        NSLog(@"Failed to derive key for transparent authentication candidate using  trustfactor output: %@", [*error debugDescription]);
        
        // We stil return computationResults instead of nil so that we can continue even if transparent auth fails
        // A transparent auth failure is not catastrophic
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthError;
        
        // Don't set these here anymore, let the next auth method specified take over instead
        //computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        //computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
        return computationResults;
        
    }
    
    // Create SHA1 hash of PBKDF2 raw key to perform search on and save for later in the event we dont find a match and
    // it is used to create a new key completely
    NSError *shaHashError = nil;
    computationResults.candidateTransparentKeyHashString = [[BECrypto sharedCrypto] createSHA1HashOfData:computationResults.candidateTransparentKey withError:&shaHashError];
    
    // Check if the candidate transparent key hash string was received
    if (!computationResults.candidateTransparentKeyHashString || computationResults.candidateTransparentKeyHashString == nil || computationResults.candidateTransparentKey.length < 1) {
        
        // Check if we received an error
        if (shaHashError || shaHashError != nil) {
            
            // Log the error
            NSLog(@"%@", shaHashError.debugDescription);
            
        } else {
            
            // Did not get a value for the candidate transparent key hash string
            NSLog(@"Did not get a value for the candidateTransparentKeyHashString");
            
        } // Done checking if error is valid
        
    } // Done checking candidateTransparentKeyHashString
    
    //Temporary for debugging purposes (add on plaintext)
    // Get policy to check for debug
    // Get the policy

    // Do not hash if debug
    if(policy.debugEnabled.intValue==1){
            computationResults.candidateTransparentKeyHashString = [computationResults.candidateTransparentKeyHashString stringByAppendingFormat:@"-%@",candidateTransparentKeyRawOutputString];
    }

    
    
    // TODO: Utilize Error
    
    // Defaults
    computationResults.foundTransparentMatch=NO;
    
    // Perform transparent authentication decay
    NSArray * currentTransparentAuthKeyObjects = [startup transparentAuthKeyObjects];
    NSArray * decayedTransparentAuthKeyObjects;
    
    if(currentTransparentAuthKeyObjects.count>0){
        
        // Decay
        decayedTransparentAuthKeyObjects  = [self performMetricBasedDecay:currentTransparentAuthKeyObjects forPolicy:policy withError:error];
        
        // Compare current transparent key hash to stored hashes
        for(BETransparentAuth_Object *storedTransparentAuthObject in decayedTransparentAuthKeyObjects)
        {
            
            if([[storedTransparentAuthObject transparentKeyPBKDF2HashString] isEqualToString:computationResults.candidateTransparentKeyHashString]){
                
                computationResults.foundTransparentMatch=YES;
                
                // Update decay information
                
                //increment hitCount for matching storedTransparentAuthObject
                NSNumber *origHitCount = [storedTransparentAuthObject hitCount];
                [storedTransparentAuthObject setHitCount:[NSNumber numberWithInt:[origHitCount intValue]+1]];
                
                // update last hit time
                [storedTransparentAuthObject setLastTime:[NSNumber numberWithInteger:[[BETrustFactorDatasets sharedDatasets] runTimeEpoch]]];
                
                
                // Store the matching transparentAuth Object in computation results
                computationResults.matchingTransparentAuthenticationObject = storedTransparentAuthObject;
                
                // return current successful status (may change if decrypt fails later on)
                computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthSuccess;
                //computationResults.preAuthenticationAction = preAuthenticationAction_TransparentlyAuthenticate;
                
                // its up for debate if we whitelist when there is transparent authentication taking place
                // obviously there cant be much to whitelist if we were above the userScore threshold
                // this allows BioEncrypt to auto-whitelist without a user intervention
                // im not sure what the impact of this may be on the profile if the user is constantly transparently authetnicated
                // it may help build a stronger profile when the user is not transparently authenticated or result in a bad profile
                
                //computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                
                break;
                
            }
        }
        
        // Set
        [startup setTransparentAuthKeyObjects:decayedTransparentAuthKeyObjects];
    }
    
    // Determine the actions to take once core detection completes
    // Transparent auth does not get its action codes from the policy, they are determined during runtime
    // This is unlike attributing classifications when the device is untrusted
    // In those conditions (violationActionCode and authenticationActionCodes are pulled striaght from that classifications
    // policy declerations
    
    if(computationResults.coreDetectionResult != CoreDetectionResult_TransparentAuthSuccess && computationResults.coreDetectionResult != CoreDetectionResult_TransparentAuthError && computationResults.foundTransparentMatch==NO){
        
        // If we made it this far there were no errors but we didnt find a match otherwise TransparentAuthSuccess would be present
        // checking for foundMatch is purely a sanity check as under normal operation if we make it this far and TransparentAuthSuccess
        // is not present then it has to be a new key
        
        computationResults.coreDetectionResult = CoreDetectionResult_TransparentAuthNewKey;
        
        // Don't set these here anymore, let the next auth method specified take over instead
        //computationResults.preAuthenticationAction = preAuthenticationAction_PromptForUserPassword;
        //computationResults.postAuthenticationAction = postAuthenticationAction_createTransparentKey;
    }
    
    return computationResults;
    
    
}

// Metric based decay function
- (NSArray *)performMetricBasedDecay:(NSArray *)currentTransparentAuthObjects forPolicy:(BEPolicy *)policy withError:(NSError **)error {
    
    double secondsInADay = 86400.0;
    double daysSinceCreation=0.0;
    double hitsPerDay=0.0;
    
    // Array to hold transparent auth objects to retain
    NSMutableArray *transparentAuthObjectsToKeep = [[NSMutableArray alloc]init];
    
    // Iterate through stored transparent auth objects
    for(BETransparentAuth_Object *storedTransparentAuthObject in currentTransparentAuthObjects){
        
        // Days since the assertion was created
        daysSinceCreation = ((double)[[BETrustFactorDatasets sharedDatasets] runTimeEpoch] - [storedTransparentAuthObject.created doubleValue]) / secondsInADay;
        
        // Check when last time it was created
        if(daysSinceCreation < 1){
            
            // Set creation date to 1 if less than 1
            daysSinceCreation = 1;
        }
        
        // Calculate our decay metric
        hitsPerDay = [storedTransparentAuthObject.hitCount doubleValue] / (daysSinceCreation);
        
        // Set the metric for storage
        [storedTransparentAuthObject setDecayMetric:hitsPerDay];
        
        // If the stored assertions (days / hits) metric exceeds the policy keep it
        if([storedTransparentAuthObject decayMetric] > policy.transparentAuthDecayMetric.floatValue) {
            
            [transparentAuthObjectsToKeep addObject:storedTransparentAuthObject];
        }
    }
    
    // Sort what we're keeping by decay metric, this should help performance, highest at top (in theory, the most frequently used)
    // Highest at top prevents from having to search long for a common match
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"decayMetric"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSArray *sortedArray;
    
    // Sort the array
    sortedArray = [transparentAuthObjectsToKeep sortedArrayUsingDescriptors:sortDescriptors];
    
    // Return TrustFactor object
    return transparentAuthObjectsToKeep;
}




/*!
 *  Attempts transparent authentication and returns True if an existing match was found and false if none was found
 */
- (BOOL)analyzeEligibleTransparentAuthObjects:(BETrustScoreComputation *)computationResults withPolicy:(BEPolicy *)policy withError:(NSError **)error{
    
    // REMEMBER - let the TrustScore determine profile, don't use transparent keys as another profiling methods, its simply for crypto

    // Array to hold transparent auth objects to retain at completion
    NSMutableArray *transparentAuthObjectsToKeep = [[NSMutableArray alloc]init];
    
    // Array that only holds the high entropy trustfactors outlined in policy
    NSMutableArray *transparentAuthHighEntropyObjects = [[NSMutableArray alloc]init];
    
    // Array that only holds the low entropy trustfactors
    NSMutableArray *transparentAuthMediumEntropyObjects = [[NSMutableArray alloc]init];
    
    // Array that only holds the low entropy trustfactors
    NSMutableArray *transparentAuthLowEntropyObjects = [[NSMutableArray alloc]init];
    
    
    // wifi subclass TFs
    BOOL wifiAuthenticator=NO;
    NSMutableArray *wifiAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];

    // location subclass TFs
    BOOL locationAuthenticator=NO;
    NSMutableArray *locationAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // Area subclass TFs
    BOOL areaAuthenticator=NO;
    NSMutableArray *areaAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // bluetooth paired subclass TFs
    BOOL bluetoothPairedAuthenticator=NO;
    NSMutableArray *bluetoothPairedAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // bluetooth subclass TFs
    BOOL bluetoothScanAuthenticator=NO;
    NSMutableArray *bluetoothScanAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // grip subclass TFs
    BOOL gripAuthenticator=NO;
    NSMutableArray *gripAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // device orientation sublcass TFs
    BOOL orientationAuthenticator=NO;
    NSMutableArray *orientationAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // device movement sublcass TFs
    BOOL movementAuthenticator=NO;
    NSMutableArray *movementAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // day time subclass TFs
    BOOL dayTimeAuthenticator=NO;
    NSMutableArray *dayTimeAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    // hour time subclass TFs
    BOOL hourTimeAuthenticator=NO;
    NSMutableArray *hourTimeAuthenticationTrustFactorOutputObjects = [[NSMutableArray alloc]init];
    
    
    // Sorting isn't required if we are manually building the order by subclass/type
    /*NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"factorID"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedTransparentAuthenticationTrustFactorOutputObjects = [computationResults.transparentAuthenticationTrustFactorOutputObjects sortedArrayUsingDescriptors:sortDescriptors];
    */
    

    // first loop through and calssify the TFs into their individual arrays
    for (BETrustFactorOutputObject *trustFactorOutputObject in computationResults.transparentAuthenticationTrustFactorOutputObjects) {
        
       
        // Identify high entropy trustfactors from eligible list and extract them
            
            switch (trustFactorOutputObject.trustFactor.subClassID.integerValue) {
                case 19: //WiFi
                    wifiAuthenticator=YES;
                    [wifiAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    break;
                case 21: //Location Anomaly
                    if([trustFactorOutputObject.trustFactor.name isEqualToString:@"approximate location anomaly"]){
                        areaAuthenticator=YES;
                        [areaAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    }
                    break;
                case 6: //Location GPS
                    if([trustFactorOutputObject.trustFactor.name isEqualToString:@"device location"]){
                        locationAuthenticator=YES;
                        [locationAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    }
                    break;
                case 8: //Bluetooth
                    
                    // Seperate paired from scan, if we don't scanned BLE may become a key over paired and caused a transparent key
                    // not to be found. Scanned bluetooth devices should be saved as a last resort for keying because they come and go often
                    // which results in multiple transparent keys having to be made (e.g., many odd login attempts in trusted zone)
                    
                    if([trustFactorOutputObject.trustFactor.name isEqualToString:@"bluetooth classic paired"] || [trustFactorOutputObject.trustFactor.name isEqualToString:@"bluetooth BLE paired"]){
                        bluetoothPairedAuthenticator=YES;
                        [bluetoothPairedAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    }
                    
                    if([trustFactorOutputObject.trustFactor.name isEqualToString:@"bluetooth low-energy scanning"]){
                        bluetoothScanAuthenticator=YES;
                        [bluetoothScanAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    }

                    break;
                case 13: //Grip
                    gripAuthenticator=YES;
                    [gripAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    break;
                case 5: //Time
                    if([trustFactorOutputObject.trustFactor.name isEqualToString:@"access time day"]){
                        dayTimeAuthenticator=YES;
                        [dayTimeAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    }
                    
                    if([trustFactorOutputObject.trustFactor.name isEqualToString:@"access time hour"]){
                        hourTimeAuthenticator=YES;
                        [hourTimeAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    }
                    break;
                case 14: //Orientation
                    orientationAuthenticator=YES;
                    [orientationAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    break;
                case 7: //Movement
                    movementAuthenticator=YES;
                    [movementAuthenticationTrustFactorOutputObjects addObject:trustFactorOutputObject];
                    break;
                default:
                    // Keep all the rest
                    //[transparentAuthLowEntropyObjects addObject:trustFactorOutputObject];
                    break;
            }
        
        
    }
    
    // Generate high entropy array manually (from highest entropy to lowest)
    
    // We don't use bluetooth scan devices because they change too much, only paired
    
    if(locationAuthenticator==YES){
        // Use area or it will not be  specific
        [transparentAuthHighEntropyObjects addObjectsFromArray:locationAuthenticationTrustFactorOutputObjects];
    }
    
    if(wifiAuthenticator==YES){
        [transparentAuthHighEntropyObjects addObjectsFromArray:wifiAuthenticationTrustFactorOutputObjects];
    }
    
    if(bluetoothPairedAuthenticator==YES){
        [transparentAuthHighEntropyObjects addObjectsFromArray:bluetoothPairedAuthenticationTrustFactorOutputObjects];
    }
    
    if(areaAuthenticator==YES){
        // Use area or it will not be  specific
        [transparentAuthHighEntropyObjects addObjectsFromArray:areaAuthenticationTrustFactorOutputObjects];
    }
    

    
    
    // Generate medium entropy array manually
    
    // Removed temporal indicators to improve pilot
    /*
    if(hourTimeAuthenticator==YES){
        [transparentAuthMediumEntropyObjects addObjectsFromArray:hourTimeAuthenticationTrustFactorOutputObjects];
    }
    */
    
    if(gripAuthenticator==YES){
        [transparentAuthMediumEntropyObjects addObjectsFromArray:gripAuthenticationTrustFactorOutputObjects];
    }
    
    
    // Generate low entropy array manually in reverse (lowest entropy to highest)
    if(orientationAuthenticator==YES){
        [transparentAuthLowEntropyObjects addObjectsFromArray:orientationAuthenticationTrustFactorOutputObjects];
    }
    
    if(movementAuthenticator==YES){
        [transparentAuthLowEntropyObjects addObjectsFromArray:movementAuthenticationTrustFactorOutputObjects];
    }
    
    // Removed temporal indicators to improve pilot
    /*
    if(dayTimeAuthenticator==YES){
        [transparentAuthLowEntropyObjects addObjectsFromArray:dayTimeAuthenticationTrustFactorOutputObjects];
    }
    */



    
    // Make selection based on the entropy setting (high,medium,low)
    switch (policy.minimumTransparentAuthEntropy.integerValue) {
        case 3: //High strength (ALWAYS 2 HIGH ENTROPY, ALL LOW ENTROPY, ALL MEDIUM)
            
            // Don't try if we dont have minimums
            if(transparentAuthHighEntropyObjects.count < 2){
                return NO;
            }
            
            // Take 2 high entropy
            [transparentAuthObjectsToKeep addObjectsFromArray:[transparentAuthHighEntropyObjects subarrayWithRange:NSMakeRange(0, 2)]];
            
            // Add Medium entropy (don't enforce number that are actually available)
            [transparentAuthObjectsToKeep addObjectsFromArray:transparentAuthMediumEntropyObjects];
            
            // Add low entropy
            // add this now because they are used by all level of strength
            [transparentAuthObjectsToKeep addObjectsFromArray:transparentAuthLowEntropyObjects];


            break;
        case 2: //Medium Strength ("SOMETIMES" 2 HIGH ENTROPY, MINIMUM 3 LOW ENTROPY)
            
            // Don't try if we dont have minimums
            if(transparentAuthHighEntropyObjects.count < 1){
                return NO;
            }

            // BLUETOOTH + LOW ENTROPY
            if(bluetoothPairedAuthenticator==YES){
                [transparentAuthObjectsToKeep addObjectsFromArray:bluetoothPairedAuthenticationTrustFactorOutputObjects];
                // try this for good measure but not required
                [transparentAuthObjectsToKeep addObjectsFromArray:locationAuthenticationTrustFactorOutputObjects];
            }
            // WIFI + LOCATION + LOW ENTROPY
            else if(wifiAuthenticator==YES && locationAuthenticator==YES){
                
                [transparentAuthObjectsToKeep addObjectsFromArray:wifiAuthenticationTrustFactorOutputObjects];
                [transparentAuthObjectsToKeep addObjectsFromArray:locationAuthenticationTrustFactorOutputObjects];
            }
            // AREA + LOCATION (because area can operate without GPS) + LOW ENTROPY
            else if(areaAuthenticator==YES && locationAuthenticator==YES){
                [transparentAuthObjectsToKeep addObjectsFromArray:areaAuthenticationTrustFactorOutputObjects];
                [transparentAuthObjectsToKeep addObjectsFromArray:locationAuthenticationTrustFactorOutputObjects];
            }
            // WIFI + LOW ENTROPY + MEDIUM ENTROPY
            else if(wifiAuthenticator==YES){
                
                if(transparentAuthMediumEntropyObjects.count < 2){
                    return NO;
                }
                
                [transparentAuthObjectsToKeep addObjectsFromArray:wifiAuthenticationTrustFactorOutputObjects];
                [transparentAuthObjectsToKeep addObjectsFromArray:transparentAuthMediumEntropyObjects];
                
            }
            
            break;
        case 1: //Low Strength (1 HIGH ENTROPY only)
            
            
            if(transparentAuthHighEntropyObjects.count > 0){
                // Take 1 high entropy
                [transparentAuthObjectsToKeep addObjectsFromArray:[transparentAuthHighEntropyObjects subarrayWithRange:NSMakeRange(0, 1)]];
            }
            else{ // employ medium + low
                
                [transparentAuthObjectsToKeep addObjectsFromArray:transparentAuthMediumEntropyObjects];
                [transparentAuthObjectsToKeep addObjectsFromArray:transparentAuthLowEntropyObjects];

            }
    
            break;
            
        default:
            return NO;
            break;
    }
    
    
    
    // Set back the computation results array
    computationResults.transparentAuthenticationTrustFactorOutputObjects = transparentAuthObjectsToKeep;
    return YES;
    

}


@end

