//
//  BEStartupStore.m
//  BioEncrypt
//
//  Created by Kramer on 2/18/16.
//

#import "BEStartupStore.h"

// Constants
#import "BEConstants.h"

// UIKit
#import <UIKit/UIKit.h>

// DCObjectMapping
#import "DCKeyValueObjectMapping.h"
#import "DCArrayMapping.h"
#import "DCParserConfiguration.h"
#import "NSObject+ObjectMap.h"

// Crypto
#import "BECrypto.h"

@implementation BEStartupStore

// Singleton instance
+ (id)sharedStartupStore {
    static BEStartupStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    return sharedStore;
}

// remove startup file
- (void) resetStartupStoreWithError: (NSError **) error {
    
    //Check if the startup file exists, if it does delete it
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self startupFilePath]]) {
        
        //remove startup file
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self startupFilePath] error:error];
        
        if (!success) {
            NSLog(@"Startup Store Error: store file cannot be deleted.");

            if (*error) {
                return;
            }
            else {
                *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                             code:NSFileReadCorruptFileError
                                         userInfo:@{@"More Information": @"Startup File JSON cannot be deleted."}];
                return;
            }
        }
    }
    
    self.currentStartupStore = nil;
}



// Get the startup file
- (BEStartup *)getStartupStore:(NSError **)error {
    
    // Check if the startup file exists
    
    // Print out the startup file path
    //NSLog(@"Startup File Path: %@", filePath);
    
    // Did we already create a startup store instance of the object?
    if(self.currentStartupStore == nil || !self.currentStartupStore){
        
            BEStartup *startup = [[BEStartup alloc] init];
            self.currentStartupStore = startup;
        
        // Check if the startup file exists, if not we will create a new one
        if (![[NSFileManager defaultManager] fileExistsAtPath:[self startupFilePath]]) {
        
            
            return nil;

            
        } else {
            
            // Startup file does exist, just not yet parsed
            
            // Get the contents of the file
            NSDictionary *jsonParsed = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self startupFilePath]]
                                                                       options:NSJSONReadingMutableContainers error:error];
            
            // Check the parsed startup file
            if (jsonParsed.count < 1 || jsonParsed == nil) {
                
                // Check if the error is set
                if (!*error || *error == nil) {
                    
                    // No such file
                    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                                 code:NSFileReadCorruptFileError
                                             userInfo:@{@"More Information": @"Startup File JSON may not be formatted correctly"}];
                }
                
                // Fail
                NSLog(@"Startup File JSON formatting problem");
                
                // Return nothing
                return nil;
            }
            
            // Map History
            DCArrayMapping *runHistorymapper = [DCArrayMapping mapperForClassElements:[BEHistoryObject class] forAttribute:kRunHistory onClass:[BEStartup class]];
            DCArrayMapping *transparentAuthKeymapper = [DCArrayMapping mapperForClassElements:[BETransparentAuth_Object class] forAttribute:kTransparentAuthKeys onClass:[BEStartup class]];
            
            // Set up the parser configuration for json parsing
            DCParserConfiguration *config = [DCParserConfiguration configuration];
            [config addArrayMapper:runHistorymapper];
            [config addArrayMapper:transparentAuthKeymapper];
            
            // Set up the date parsing configuration
            config.datePattern = OMDateFormat;
            
            // Set the parser and include the configuration
            DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[BEStartup class] andConfiguration:config];
            
            // Get the Startup Class from the parsing
            BEStartup *startup = [parser parseDictionary:jsonParsed];
            
            // Make sure the class is valid
            if (!startup || startup == nil) {
                
                // Startup Class is invalid!
                
                // No valid policy provided
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Getting Startup File Unsuccessful", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Startup Class file is invalid", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try removing the startup file and retrying", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupFile userInfo:errorDetails];
                
            }
            
            // Return the object
            self.currentStartupStore = startup;
            return self.currentStartupStore;
            
        }

        
    }
    else{
        return self.currentStartupStore;
    }
    
    // Not found
    return nil;
}




- (void) createNewStartupFileWithError:(NSError **)error {
    // Alloc the startup file
    BEStartup *startup = [[BEStartup alloc] init];
    self.currentStartupStore = startup;
    
    /*
     * Set first time defaults for the application
     */
    
    
    /*
     * Set device salt
     */
    NSData *deviceSaltData = [[BECrypto sharedCrypto] generateSalt256];
    [self.currentStartupStore setDeviceSaltString:[[BECrypto sharedCrypto] convertDataToHexString:deviceSaltData withError:error]];
    // TODO: Utilize Error
    /*
     * Set the user key salt
     */
    NSData *userKeySaltData = [[BECrypto sharedCrypto] generateSalt256];
    [self.currentStartupStore setUserKeySaltString:[[BECrypto sharedCrypto] convertDataToHexString:userKeySaltData withError:error]];
    // TODO: Utilize Error
    /*
     * Set the transparent auth global PBKDF2 salt (used for all PBKDF2 transparent key hashes)
     */
    NSData *transparentAuthGlobalPBKDF2Salt = [[BECrypto sharedCrypto] generateSalt256];
    [self.currentStartupStore setTransparentAuthGlobalPBKDF2SaltString:[[BECrypto sharedCrypto] convertDataToHexString:transparentAuthGlobalPBKDF2Salt withError:error]];
    // TODO: Utilize Error
    /*
     * Set the transparent auth global PBKDF2 round estimate
     */
    
    // How many rounds to use so that it takes 0.05s (50ms) ?
    NSString *testTransparentAuthOutput = @"TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0_TEST_0";
    int transparentAuthEstimateRounds = [[BECrypto sharedCrypto] benchmarkPBKDF2UsingExampleString:testTransparentAuthOutput forTimeInMS:10 withError:error];
    // TODO: Utilize Error
    [self.currentStartupStore setTransparentAuthPBKDF2rounds:transparentAuthEstimateRounds];


    /*
     * Set the user auth PBKDF2 round estimate
     */
    
    // How many rounds to use so that it takes 0.05s (50ms) ?
    NSString *testUserPassword = @"abcdef";
    int userEstimateRounds = [[BECrypto sharedCrypto] benchmarkPBKDF2UsingExampleString:testUserPassword forTimeInMS:50 withError:error];
    // TODO: Utilize Error
    [self.currentStartupStore setUserKeyPBKDF2rounds:userEstimateRounds];
    
    /*
     * Set the OS Version
     */
    [self.currentStartupStore setLastOSVersion:[[UIDevice currentDevice] systemVersion]];
    
    
    // Default values
    [self.currentStartupStore setLastState:@""];

    
    // We set a dummy email here becaue we dont have access to the GD enterprise policy yet to provide the true email
    //[self.currentStartupStore setEmail:@"email@notset.com"];
    NSArray *empty = [[NSArray alloc]init];
    [self.currentStartupStore setRunHistoryObjects:empty];
    [self.currentStartupStore setTransparentAuthKeyObjects:empty];
    self.currentStartupStore.runCount = 0;
    self.currentStartupStore.runCountAtLastUpload = 0;
    self.currentStartupStore.dateTimeOfLastUpload = 0.0;
    
    // Save the store
    [self setStartupStoreWithError:error];
}





- (void) updateStartupFileWithBiometricPassoword: (NSString *)password masterKey: (NSData *) decryptedMasterKey withError:(NSError **)error {
    
    //load startup file
    [self getStartupStore:error];
    if (*error)
        return;
    
    
    // Generate and store biometric key hash and biometric key encrypted master key blob
    [[BECrypto sharedCrypto] updateBiometricForExistingMasterKeyWithBiometricPassword:password withDecryptedMasterKey:decryptedMasterKey withError:error];
    

    if (*error)
        return;
    
    // Save the store
    [self setStartupStoreWithError:error];
}




- (NSString *) updateStartupFileWithPassoword: (NSString *)password withError:(NSError **)error {

    //load startup file
    [self getStartupStore:error];
    if (*error)
        return nil;

    
    /*
     * First time user provisoning:
     * Prompt for user password (simulated for demo)
     * Generated the one and only permanent master key for secure container user
     * Encrypt master with user key
     * Store user key encrypter master key blob
     */
    
    
    // Generate and store user key hash and user key encrypted master key blob
    NSString *masterKeyString = [[BECrypto sharedCrypto] provisionNewUserKeyAndCreateMasterKeyWithPassword:password withError:error];
    
    // TODO: Utilize Error
    
    if (!masterKeyString || masterKeyString==Nil){
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Error creating new user and master key", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unknown", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Very startup file and other inputs", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToCreateNewUserAndMasterKey userInfo:errorDetails];
        
        
    }
    
    
   
    // Save the store
    [self setStartupStoreWithError:error];
    
    return masterKeyString;
}



// Create a new startup file and return master key as a string
- (void)updateStartupFileWithEmail:(NSString *)email withError:(NSError **)error {
    
    // Alloc the startup file
    // Get our startup file
    self.currentStartupStore.email = email;
    
    // Save the store because it was written once earlier during password creation and we
    // were not able to update the email until afterwards
    [self setStartupStoreWithError:error];

}

// Set the startup file
- (BOOL)setStartupStoreWithError:(NSError **)error {
    
    
    // Make sure the class is valid
    if (!self.currentStartupStore || self.currentStartupStore == nil) {
        
        // Startup Class is invalid!
        
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Startup File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Startup Class reference is invalid", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid startup object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Return NO
        return NO;
        
    }
    
    // Save the startup file to disk (as json)
    NSData *data = [self.currentStartupStore JSONData];
 
    // Validate the data
    if (!data || data == nil) {
        
        // Problem parsing to JSON
        
        // No valid startup provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Setting Startup File Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Startup Class reference does not parse to JSON correctly", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid JSON startup object instance", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Return NO
        return NO;
        
    }
    
    // Write the data out to the path
    BOOL outFileWrite = [data writeToFile:[self startupFilePath] options:NSDataWritingFileProtectionComplete error:error];
    
    // Validate that the write was successful
    if (!outFileWrite ) {
        
        // Check if error passed back was empty
        if (!*error || *error == nil) {
            
            // Unable to write out startup file!!
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to Write Startup file", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to write startup file", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try providing correct store to write out.", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:coreDetectionDomain code:SAUnableToWriteStore userInfo:errorDetails];
            
            // Return NO
            return NO;
            
        }
        
        // Log Error
        NSLog(@"Failed to Write Store: %@", *error);

    }
    
    // Return Success
    return YES;
    
}

// Startup File Path
- (NSString *)startupFilePath {
    
    // Get the documents directory paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the document directory
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Get the path to our startup file
    return [NSString stringWithFormat:@"%@/%@", documentsDirectory, kStartupFileName];
}

#pragma mark - Override Setter

// Override set current state
- (void)setCurrentState:(NSString *)currentState {
    
    // Create an error
    NSError *error;
    
    // Get the startup instance (from file)
    BEStartup *startup = [self currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Log it
        NSLog(@"Setting Startup File Current State Failed");
        
        // Return
        return;
        
    }
    
    // Set the last state
    [startup setLastState:currentState];
    
    // Set the variable as well
    _currentState = currentState;
    
    // Save the startup file
    //[self setStartupStoreWithError:&error];
    
    // Validate no errors
    if (error || error != nil) {
        
        // Log it
        NSLog(@"Setting Startup File Failed");
        
        // Return
        return;
        
    }
    
}

- (void)setStartupFileWithComputationResult:(BETrustScoreComputation *)computationResults withError:(NSError **)error {
    
    // Get our startup file
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
        
    } // Done validating no errors
    
    // Create a run history object for this run
    BEHistoryObject *runHistoryObject = [[BEHistoryObject alloc] init];
    
    // Date
    [runHistoryObject setTimestamp:[NSDate date]];
    
    // Results and status codes
    [runHistoryObject setCoreDetectionResult:computationResults.coreDetectionResult];
    [runHistoryObject setPreAuthenticationAction:computationResults.authenticationAction];
    [runHistoryObject setPostAuthenticationAction:computationResults.postAuthenticationAction];
    [runHistoryObject setAuthenticationResult:computationResults.authenticationResult];
    
    // Scores
    [runHistoryObject setDeviceScore:computationResults.systemScore];
    [runHistoryObject setTrustScore:computationResults.deviceScore];
    [runHistoryObject setUserScore:computationResults.userScore];

    // Issues
    [runHistoryObject setUserIssues:computationResults.userIssues];
    [runHistoryObject setSystemIssues:computationResults.systemIssues];
    


    // Check if the startup file already has an array of history objects
    if (!startup.runHistoryObjects || startup.runHistoryObjects.count < 1) {
        
        // Create a new array
        NSArray *historyArray = [NSArray arrayWithObject:runHistoryObject];
        
        // Set the array to the startup file
        [startup setRunHistoryObjects:historyArray];
        
    } else {
        
        // Startup History is an array with objects in it already
        NSArray *historyArray = [[startup runHistoryObjects] arrayByAddingObject:runHistoryObject];
        
        // Set the array to the startup file
        [startup setRunHistoryObjects:historyArray];
        
    }
    
    // Save all updates to the startup file, this includes version check during baseline analysis, any transparent auth changes, run history
    if (![[BEStartupStore sharedStartupStore] setStartupStoreWithError:error]) {
        
        // TODO: Something wonky here - Check for errors
        if (*error || *error != nil || *error != NULL) {
            
            // Unable to set startup file!
            
            // Log Error
            NSLog(@"Failed to set startup file: %@", [(NSError *)*error debugDescription]);
            
        } else {
            
            // Failed to set startup file for unknown reason
            NSLog(@"Fialed to set startup file for unknown reasons");
            
        }
        
    }

}

@end
