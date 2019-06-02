//
//  BELoginAction.m
//  BioEncrypt
//
//

#import "BELoginAction.h"

// Assertion Store
#import "BEAssertionStore+Helper.h"

// TrustFactor Storage
#import "BETrustFactorStorage.h"

// Transparent Auth
#import "BETransparentAuthentication.h"

// Crypto
#import "BECrypto.h"

// Core Detection
#import "BECoreDetection.h"

#import "BEStartupStore.h"

@implementation BELoginAction

// Singleton instance
+ (id)sharedLogin {
    static BELoginAction *sharedLogin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLogin = [[self alloc] init];
    });
    return sharedLogin;
}

#pragma mark - Deactivations


- (BELoginResponse_Object *)attemptLoginWithBiometricpassword:(NSString *)biometricPassword andError:(NSError **)error {
    // Get computation results
    // Get last computation results
    BETrustScoreComputation *computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    
    // Create response object
    BELoginResponse_Object *loginResponseObject = [[BELoginResponse_Object alloc] init];
    computationResults.loginResponseObject = loginResponseObject;

    
    BEStartup *startup = [[BEStartupStore sharedStartupStore] currentStartupStore];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Set to error, no response title/desc required because its not used for transparent
        NSLog(@"Unable to get the startup file for preauthentication action: PromptForUserPassword");
        [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
        [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
        [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
        [loginResponseObject setDecryptedMasterKey:nil];
        
    } // Done validating no errors
    
    // Derive key from user input (we do this here instead of inside BioEncrypt crypto to prevent doing multiple key derivations, in the event the password is correct and we need to do decryption)
    NSData *biometricKey = [[BECrypto sharedCrypto] getUserKeyForPassword:biometricPassword withError:error];
    
    // TODO: Utilize Error
    
    // Create user key hash
    NSString *candidateBiometricKeyHash =  [[BECrypto sharedCrypto] createSHA1HashOfData:biometricKey withError:error];
    
    // TODO: Utilize Error
    
    // Retrieve the stored user key hash created during provisoning
    NSString *storedBiometricKeyHash = [startup biometricKeyHash];
    
    // Successful login
    if ([candidateBiometricKeyHash isEqualToString:storedBiometricKeyHash]) {
        
        // Attempt to decrypt master
        computationResults.decryptedMasterKey = [[BECrypto sharedCrypto] decryptMasterKeyUsingBiometricKey:biometricKey withError:error];
        
        // TODO: Utilize Error
        
        // See if it decrypted
        if (computationResults.decryptedMasterKey != nil || !computationResults.decryptedMasterKey) {
            
            // Master key decrypted successfully
            
            // Set to success, no response title/desc required
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_Success];
            [loginResponseObject setResponseLoginTitle:@""];
            [loginResponseObject setResponseLoginDescription:@""];
            [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
            
            // Perform post auth action (e.g., whitelist)
            if ([BELoginAction performPostAuthenticationActionWithError:error] == NO) {
                
                // Unable to perform post authentication events
                
                // Set the error if it's not set
                if (!*error) {
                    
                    // Set the error details
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Post authentication action failed", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during post authentication", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify whitelisting and other post authentication actions", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToPerformPostAuthenticationAction userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"Post authentication action failed: %@", errorDetails);
                    
                } // Done setting the error if not set
                
                // This is not catastrophic but it likely means we didn't whitelist, we will still return a loginResponseObject to keep things working because the master key decrypted successfully
                [loginResponseObject setAuthenticationResponseCode:authenticationResult_recoverableError];
                [loginResponseObject setResponseLoginTitle:@""];
                [loginResponseObject setResponseLoginDescription:@""];
                [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                
            } // Done Perform Post Auth
            
        } else {
            
            // Set to error, no response title/desc required because its not used for transparent
            NSLog(@"Unable to authenticate: unable to decrypt master key");
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
            [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
            [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
            [loginResponseObject setDecryptedMasterKey:nil];
            
        } // Done Seeing if it decrypted
        
    } else {
        
        // Login failed
        
        // Set to error, no response title/desc required because its not used for transparent
        NSLog(@"Unable to authenticate: unsuccessful login");
        [loginResponseObject setAuthenticationResponseCode:authenticationResult_incorrectLogin];
        [loginResponseObject setResponseLoginTitle:@"Incorrect password"];
        [loginResponseObject setResponseLoginDescription:@"Please retry your password"];
        [loginResponseObject setDecryptedMasterKey:nil];
        
    } // Done Successful login
    
    return loginResponseObject;
}


// Attempt login with transparent auth
- (BELoginResponse_Object *)attemptLoginWithTransparentAuthentication:(NSError **)error {
    
    // Get computation results
    // Get last computation results
    BETrustScoreComputation *computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    
    // Create response object
    BELoginResponse_Object *loginResponseObject = [[BELoginResponse_Object alloc] init];
    computationResults.loginResponseObject = loginResponseObject;

        
    // Transparent Authentication
    
    // Decrypt using previously determiend values
    computationResults.decryptedMasterKey = [[BECrypto sharedCrypto] decryptMasterKeyUsingTransparentAuthenticationWithError:error];
    
    // TODO: Utilize Error
    
    // See if it decrypted
    if (computationResults.decryptedMasterKey != nil || !computationResults.decryptedMasterKey) {
        
        // Set to success, no response title/desc required because its not used for transparent
        [loginResponseObject setAuthenticationResponseCode:authenticationResult_Success];
        [loginResponseObject setResponseLoginTitle:@""];
        [loginResponseObject setResponseLoginDescription:@""];
        [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
        
        // Perform post auth action (e.g., whitelist)
        if ([BELoginAction performPostAuthenticationActionWithError:error] == NO) {
            
            // Unable to perform post authentication events
            
            // Set the error if it's not set
            if (!*error) {
                
                // Set the error details
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Post authentication action failed", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during post authentication", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify whitelisting and other post authentication actions", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToPerformPostAuthenticationAction userInfo:errorDetails];
                
                // Log it
                NSLog(@"Post authentication action failed: %@", errorDetails);
                
            } // Done checking for error
            
            // This is not catastrophic but it likely means we didn't whitelist, we will still return a loginResponseObject to keep things working because the master key decrypted successfully
            [loginResponseObject setAuthenticationResponseCode:authenticationResult_recoverableError];
            [loginResponseObject setResponseLoginTitle:@""];
            [loginResponseObject setResponseLoginDescription:@""];
            [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
            
        } // Done performing post auth action
        
    } else {
        
        // Set to error, no response title/desc required because its not used for transparent
        [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
        [loginResponseObject setResponseLoginTitle:@""];
        [loginResponseObject setResponseLoginDescription:@""];
        [loginResponseObject setDecryptedMasterKey:nil];
        
    } // Done seeing if it decrypted

    // Return the response object
    return loginResponseObject;
    
} // Done Attempt login with user input

// Attempt login with user input
- (BELoginResponse_Object *)attemptLoginWithPassword:(NSString *)Userinput andError:(NSError **)error {
    
    // Get computation results
    // Get last computation results
    BETrustScoreComputation *computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    
    // Create response object
    BELoginResponse_Object *loginResponseObject = [[BELoginResponse_Object alloc] init];
    computationResults.loginResponseObject = loginResponseObject;

        
     // Prompt for user password
     
     // We bundle these together because they do the same
     
     //NSError *startupError;
     BEStartup *startup = [[BEStartupStore sharedStartupStore] currentStartupStore];
     
     // Validate no errors
     if (!startup || startup == nil) {
         
         // Set to error, no response title/desc required because its not used for transparent
         NSLog(@"Unable to get the startup file for preauthentication action: PromptForUserPassword");
         [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
         [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
         [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
         [loginResponseObject setDecryptedMasterKey:nil];
         
     } // Done validating no errors
     
     // Derive key from user input (we do this here instead of inside BioEncrypt crypto to prevent doing multiple key derivations, in the event the password is correct and we need to do decryption)
     NSData *userKey = [[BECrypto sharedCrypto] getUserKeyForPassword:Userinput withError:error];
     
     // TODO: Utilize Error
     
     // Create user key hash
     NSString *candidateUserKeyHash =  [[BECrypto sharedCrypto] createSHA1HashOfData:userKey withError:error];
     
     // TODO: Utilize Error
     
     // Retrieve the stored user key hash created during provisoning
     NSString *storedUserKeyHash = [startup userKeyHash];
     
     // Successful login
     if ([candidateUserKeyHash isEqualToString:storedUserKeyHash]) {
         
         // Attempt to decrypt master
         computationResults.decryptedMasterKey = [[BECrypto sharedCrypto] decryptMasterKeyUsingUserKey:userKey withError:error];
         
         // TODO: Utilize Error
         
         // See if it decrypted
         if (computationResults.decryptedMasterKey != nil || !computationResults.decryptedMasterKey) {
             
             // Master key decrypted successfully
             
             // Set to success, no response title/desc required
             [loginResponseObject setAuthenticationResponseCode:authenticationResult_Success];
             [loginResponseObject setResponseLoginTitle:@""];
             [loginResponseObject setResponseLoginDescription:@""];
             [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
             
             // Perform post auth action (e.g., whitelist)
             if ([BELoginAction performPostAuthenticationActionWithError:error] == NO) {
                 
                 // Unable to perform post authentication events
                 
                 // Set the error if it's not set
                 if (!*error) {
                     
                     // Set the error details
                     NSDictionary *errorDetails = @{
                                                    NSLocalizedDescriptionKey: NSLocalizedString(@"Post authentication action failed", nil),
                                                    NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during post authentication", nil),
                                                    NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Verify whitelisting and other post authentication actions", nil)
                                                    };
                     
                     // Set the error
                     *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToPerformPostAuthenticationAction userInfo:errorDetails];
                     
                     // Log it
                     NSLog(@"Post authentication action failed: %@", errorDetails);
                     
                 } // Done setting the error if not set
                 
                 // This is not catastrophic but it likely means we didn't whitelist, we will still return a loginResponseObject to keep things working because the master key decrypted successfully
                 [loginResponseObject setAuthenticationResponseCode:authenticationResult_recoverableError];
                 [loginResponseObject setResponseLoginTitle:@""];
                 [loginResponseObject setResponseLoginDescription:@""];
                 [loginResponseObject setDecryptedMasterKey:computationResults.decryptedMasterKey];
                 
             } // Done Perform Post Auth
             
         } else {
             
             // Set to error, no response title/desc required because its not used for transparent
             NSLog(@"Unable to authenticate: unable to decrypt master key");
             [loginResponseObject setAuthenticationResponseCode:authenticationResult_irrecoverableError];
             [loginResponseObject setResponseLoginTitle:@"Authentication Error"];
             [loginResponseObject setResponseLoginDescription:@"An error occured during authentication, please reinstall the application"];
             [loginResponseObject setDecryptedMasterKey:nil];
             
         } // Done Seeing if it decrypted
         
     } else {
         
         // Login failed
         
         // Set to error, no response title/desc required because its not used for transparent
         NSLog(@"Unable to authenticate: unsuccessful login");
         [loginResponseObject setAuthenticationResponseCode:authenticationResult_incorrectLogin];
         [loginResponseObject setResponseLoginTitle:@"Incorrect password"];
         [loginResponseObject setResponseLoginDescription:@"Please retry your password"];
         [loginResponseObject setDecryptedMasterKey:nil];
         
     } // Done Successful login
    

    // Return the response object
    return loginResponseObject;
    
} // Done Attempt login with user input


// Attempt login with user input
- (BELoginResponse_Object *)attemptLoginWithBlockAndWarn:(NSError **)error {
    
    
    // Create response object
    BELoginResponse_Object *loginResponseObject = [[BELoginResponse_Object alloc] init];

    // Block and warn
    [loginResponseObject setAuthenticationResponseCode:authenticationResult_incorrectLogin];
    [loginResponseObject setResponseLoginTitle:@"Access Denied"];
    [loginResponseObject setResponseLoginDescription:@"This device has exceeded it's risk threshold."];
    [loginResponseObject setDecryptedMasterKey:nil];
    
    // Return the response object
    return loginResponseObject;
    
}
// Perform post-login action
+ (BOOL)performPostAuthenticationActionWithError:(NSError **)error {
    
    // Get computation results
    // Get last computation results
    BETrustScoreComputation *computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    
    //Get trustfactors to whitelist from computation results
    NSArray *trustFactorsToWhitelist;
    
    // Go through the post authentication actions
    switch (computationResults.postAuthenticationAction) {
            
        case postAuthenticationAction_whitelistUserAssertions: {
            
            // Whitelist User Assertions
            
            // Get the trustfactors to whitelist
            trustFactorsToWhitelist = computationResults.userTrustFactorWhitelist;
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting trustfacotrs
                
            } // Done checking for trustfactors to whitelist
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistUserAssertions
            
        case postAuthenticationAction_whitelistUserAndSystemAssertions: {
            
            // Whitelist user and system assertions
            
            // Get the trustfactors to whitelist
            trustFactorsToWhitelist = [computationResults.userTrustFactorWhitelist arrayByAddingObjectsFromArray:computationResults.systemTrustFactorWhitelist];
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting assertions
                
            } // Done checking the whitelist count
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistUserAndSystemAssertions
            
        case postAuthenticationAction_whitelistSystemAssertions: {
            
            // Whitelist system assertions
            
            // Set the trustfactors to whitelist
            trustFactorsToWhitelist = computationResults.systemTrustFactorWhitelist;
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting
                
            } // Done checking the whitelist count
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistSystemAssertions
            
        case postAuthenticationAction_whitelistUserAssertionsAndCreateTransparentKey: {
            
            // Whitelist user assertions and create transparent key
            
            // Set the trustfactors to whitelist
            trustFactorsToWhitelist = computationResults.userTrustFactorWhitelist;
            
            // Check the whitelist count
            if (trustFactorsToWhitelist.count > 0) {
                
                // Whitelist them and check for an error
                if ([self whitelistAttributingTrustFactorOutputObjects:trustFactorsToWhitelist withError:error] == NO) {
                    
                    // Unable to whitelist attributing TrustFactor Output Objects
                    
                    // Set the error if it's not set
                    if (!*error) {
                        
                        // Set the error details
                        NSDictionary *errorDetails = @{
                                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Deactivate Protect Mode Failed", nil),
                                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error during assertion whitelisting", nil),
                                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to ProtectMode", nil)
                                                       };
                        
                        // Set the error
                        *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
                        
                        // Log it
                        NSLog(@"Deactivate Protect Mode Failed: %@", errorDetails);
                        
                    } // Done checking for errors
                    
                    // Return NO
                    return NO;
                    
                } // Done whitelisting
                
            } // Done checking the whitelist count
            
            // Now create a new transparent key
            BETransparentAuth_Object *newTransparentObject = [[BECrypto sharedCrypto] createNewTransparentAuthKeyObjectWithError:(NSError **)error];
            
            // TODO: Utilize Error Checking
            
            // Check for error
            if (!newTransparentObject || newTransparentObject == nil) {
                
                // Unable to whitelist attributing TrustFactor Output Objects
                
                // Set the error if it's not set
                if (!*error) {
                    
                    // Set the error details
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to create new transparent key", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Faile to create new object for whitelisting", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check transparent object parameters", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToCreateNewTransparentKey userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"New transparent auth object store failed: %@", errorDetails);
                    
                } // Done checking for errors
                
                // Return NO
                return NO;
                
            } // Done Checking for newTransparent object errors
            
            // Get the current Transparent objects from the startup file and re-set the file
            
            //NSError *startupError;
            BEStartup *startup = [[BEStartupStore sharedStartupStore] currentStartupStore];
            
            // Validate no errors
            if (!startup || startup == nil) {
                
                // Error out, no trustFactorOutputObject were able to be added
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file during whitelisting", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:bioEncryptDomain code:SAInvalidStartupInstance userInfo:errorDetails];
                
                // Log Error
                NSLog(@"Failed to get startup file during whitelisting: %@", errorDetails);
                
                // Return no
                return NO;
                
            } // Done checking for errors
            
            // Create the currentTransparentAuthKeyObjects array
            NSMutableArray *currentTransparentAuthKeyObjects = [[startup transparentAuthKeyObjects] mutableCopy];
            [currentTransparentAuthKeyObjects addObject:newTransparentObject];
            
            // Set the Transparent Auth Key Objects
            [startup setTransparentAuthKeyObjects:currentTransparentAuthKeyObjects];
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_whitelistUserAssertionsAndCreateTransparentKey
            
        case postAuthenticationAction_createTransparentKey: {
            
            // No whitelisting
            
            // Now create a new transparent key
            BETransparentAuth_Object *newTransparentObject = [[BECrypto sharedCrypto] createNewTransparentAuthKeyObjectWithError:(NSError **)error];
            
            // TODO: Utilize Error Checking
            
            // Check for error
            if (!newTransparentObject || newTransparentObject == nil) {
                
                // Unable to whitelist attributing TrustFactor Output Objects
                
                // Set the error if it's not set
                if (!*error) {
                    
                    // Set the error details
                    NSDictionary *errorDetails = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to create new transparent key", nil),
                                                   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Faile to create new object for whitelisting", nil),
                                                   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check transparent object parameters", nil)
                                                   };
                    
                    // Set the error
                    *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToCreateNewTransparentKey userInfo:errorDetails];
                    
                    // Log it
                    NSLog(@"New transparent auth object store failed: %@", errorDetails);
                    
                } // Done checking for errors
                
                // Return NO
                return NO;
                
            } // Done Checking for newTransparent object errors
            
            // Get the current Transparent objects from the startup file and re-set the file
            
            //NSError *startupError;
            BEStartup *startup = [[BEStartupStore sharedStartupStore] currentStartupStore];
            
            // Validate no errors
            if (!startup || startup == nil) {
                
                // Error out, no trustFactorOutputObject were able to be added
                NSDictionary *errorDetails = @{
                                               NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file during whitelisting", nil),
                                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                               };
                
                // Set the error
                *error = [NSError errorWithDomain:bioEncryptDomain code:SAInvalidStartupInstance userInfo:errorDetails];
                
                // Log Error
                NSLog(@"Failed to get startup file during transparent auth: %@", errorDetails);
                
                // Return no
                return NO;
                
            } // Done checking for errors
            
            // Create the currentTransparentAuthKeyObjects array
            NSMutableArray *currentTransparentAuthKeyObjects = [[startup transparentAuthKeyObjects] mutableCopy];
            [currentTransparentAuthKeyObjects addObject:newTransparentObject];
            
            // Set the Transparent Auth Key Objects
            [startup setTransparentAuthKeyObjects:currentTransparentAuthKeyObjects];
            
            // Return YES - no errors
            return YES;
            
            // Break
            break;
            
        } // Done postAuthenticationAction_createTransparentKey
            
        case postAuthenticationAction_DoNothing: {
            
            // Really only used for when transparent auth is happening
        
            return YES;
            break;
        }
            
        default: {
            
            // Return NO
            return NO;
            
            // Break
            break;
            
        } // Done default
            
    } // Done switch
    
} // Done performPostAuthenticationActionWithError

#pragma mark - Whitelisting

// Whitelist the Attributing TrustFactor Output Objects
+ (BOOL)whitelistAttributingTrustFactorOutputObjects:(NSArray *)trustFactorsToWhitelist withError:(NSError **)error {
    
    // Get the shared store
    BEAssertionStore *localStore = [[BETrustFactorStorage sharedStorage] getAssertionStoreWithError:error];
    
    // Check for errors
    if (!localStore || localStore == nil ) {
        
        // Unable to get the local store
        // Set the error if it's not set
        if (!*error) {
            
            // Set the error details
            NSDictionary *errorDetails = @{
                                           NSLocalizedDescriptionKey: NSLocalizedString(@"Whitelist Attributing TrustFactor Output Objects Failed", nil),
                                           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Error getting the local store", nil),
                                           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Make sure assertions are provided to whitelist", nil)
                                           };
            
            // Set the error
            *error = [NSError errorWithDomain:bioEncryptDomain code:SAUnableToWhitelistAssertions userInfo:errorDetails];
            
            // Log it
            NSLog(@"Whitelist Attributing TrustFactor Output Objects Failed: %@", errorDetails);
            
        } // Done checking for errors
        
        // Return NO
        return NO;
        
    } // Done checking for localStore errors
    
    // Create variables to hold the existing assertion objects and the merged assertion objects
    NSArray *existingStoredAssertionObjects = [NSArray array];
    NSArray *mergedStoredAssertionObjects = [NSArray array];
    
    // Run through all the Assertions in the whitelist
    for (BETrustFactorOutputObject *trustFactorOutputObject in trustFactorsToWhitelist) {
        
        // Make sure the assertionObjects is not empty or we cant merge
        if (trustFactorOutputObject.storedTrustFactorObject.assertionObjects == nil || trustFactorOutputObject.storedTrustFactorObject.assertionObjects.count < 1) {
            
            // Set the assertion objects
            
            // Set the assertion objects to the whitelist objects
            trustFactorOutputObject.storedTrustFactorObject.assertionObjects = trustFactorOutputObject.candidateAssertionObjects;
            
        } else {
            
            // Merge the assertion objects
            
            // Get the existing objects
            existingStoredAssertionObjects = trustFactorOutputObject.storedTrustFactorObject.assertionObjects;
            
            // Get the merged objects
            mergedStoredAssertionObjects = [existingStoredAssertionObjects arrayByAddingObjectsFromArray:trustFactorOutputObject.candidateAssertionObjectsForWhitelisting];
            
            // Set the merged list back to storedTrustFactorObject
            [trustFactorOutputObject.storedTrustFactorObject setAssertionObjects:mergedStoredAssertionObjects];
        }
        
        // Exists Variable
        BOOL exists;
        
        // Check for matching stored assertion object in the local store
        BEStoredTrustFactorObject *storedTrustFactorObject = [localStore getStoredTrustFactorObjectWithFactorID:trustFactorOutputObject.trustFactor.identification doesExist:&exists withError:error];
        
        // If we can't find in the local store then skip
        if (!storedTrustFactorObject || storedTrustFactorObject == nil || exists == NO) {
            // Continue
            continue;
        }
        
        // Try to set the storedTrustFactorObject back in the store, skip if fail
        if (![localStore replaceSingleObjectInStore:trustFactorOutputObject.storedTrustFactorObject withError:error]) {
            // Continue
            continue;
        }
        
    } // Done for
    
    // Update the stores
    [[BETrustFactorStorage sharedStorage] setAssertionStoreWithError:error];
    
    // Return YES
    return YES;
    
} // Done whitelistAttributingTrustFactorOutputObjects

@end
