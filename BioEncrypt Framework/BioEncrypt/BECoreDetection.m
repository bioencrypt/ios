//
//  BECoreDetection.m
//  BioEncrypt
//
//

#import "BECoreDetection.h"

// TrustFactor Datasets
#import "BETrustFactorDatasets.h"

// Constants
#import "BEConstants.h"

// Parser
#import "BEPolicyParser.h"

// TrustFactor Dispatcher
#import "BETrustFactorDispatcher.h"

// Baseline Analysis
#import "BEBaselineAnalysis.h"

// Startup
#import "BEStartupStore.h"

#import "BEActivityDispatcher.h"

// Core Detection Results Analysis
#import "BEResultsAnalysis.h"

#import "BETrustFactorStorage.h"

#import "BEBiometricManager.h"

#import "BELocationPermissionRequest.h"
#import "BEActivityPermissionRequest.h"
#import "BEPermissionRequest.h"
#import "BELoginResponse_Object.h"
#import "BELoginAction.h"
#import "BEBiometricManager.h"

#import "BECrypto.h"

@interface BECoreDetection ()

/**
 *  Protect Mode Analysis callback
 *
 *  See: CoreDetectionBlock
 */
- (void)coreDetectionResponse:(BOOL)success withComputationResults:(BETrustScoreComputation *)computationResults andError:(NSError **)error;


@property (nonatomic, strong) UIViewController *parentViewController;
@property (nonatomic, strong) BEActivityDispatcher *activityDispatcher;

@property (nonatomic, strong) BELocationPermissionRequest *locationPermissionRequest;
@property (nonatomic, strong) BEActivityPermissionRequest *activityPermissionRequest;

@property (nonatomic, strong) NSData *masterKey;

@end

@implementation BECoreDetection
@synthesize delegate, activityDispatcher;

/*!
 *  Callback block definition
 */
void (^coreDetectionBlockCallBack)(BOOL success, BETrustScoreComputation *computationResults, NSError *error);

#pragma mark - Protect Mode Analysis


- (void)runCoreDetectionWithCallback:(coreDetectionBlock)callback {
    
    self.computationResults = nil;
    // Create the error to use
    NSError *error = nil;
    
    // Validate the callback
    if (!callback || callback == nil) {
        
        // No valid callback provided
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid callback block was provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid callback block", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoCallbackBlockProvided userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    // Set the callback block to be the block definition
    coreDetectionBlockCallBack = callback;
    
    // Flush the policy in the event it was updated inbetween runs
    // This forces it to re-parse
    [[BEPolicyParser sharedPolicy] setCurrentPolicy:nil];
    
    // Get the policy
    BEPolicy *policy = [[BEPolicyParser sharedPolicy] getPolicy:&error];
    
    // Validate the policy.trustFactors
    if (!policy || policy.trustFactors.count < 1 || !policy.trustFactors) {
        
        // No valid trustfactors found to analyze
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactors found to analyze", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Please provide a policy with valid TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoTrustFactorsSetToAnalyze userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    // Get the startup store
    
    // Get our startup file
    
    BEStartup *startup = [[BEStartupStore sharedStartupStore] getStartupStore:&error];
    
    // Validate no errors
    if (!startup || startup == nil) {
        
        // Check if there are any errors
        if (error || error != nil) {
            
            // Unable to get startup file!
            
            // Log Error
            NSLog(@"Failed to get startup file: %@", error.debugDescription);
            
            
        }
        
        // Error out, no trustFactorOutputObject were able to be added
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to get startup file", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No startup file received", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try validating the startup file", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:@"BioEncrypt" code:SAInvalidStartupInstance userInfo:errorDetails];
        
        // Log Error
        NSLog(@"Failed to get startup file: %@", errorDetails);
        
    }
    
    // increment run count
    startup.runCount = startup.runCount+1;
    
    // Set the current state of Core Detection
    [[BEStartupStore sharedStartupStore] setCurrentState:@"Starting Core Detection"];
    
    /* Start the TrustFactor Dispatcher */
    
    // Executes the TrustFactors and gets the output objects
    NSArray *trustFactorOutputObjects = [BETrustFactorDispatcher performTrustFactorAnalysis:policy.trustFactors withTimeout:[policy.timeout doubleValue] andError:&error];
    
    // Check for valid trustFactorOutputObjects
    if (!trustFactorOutputObjects || trustFactorOutputObjects == nil || trustFactorOutputObjects.count < 1) {
        
        // Invalid TrustFactor Output Objects
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No TrustFactorOutputObjects returned from dispatch", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Double check provided TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoTrustFactorOutputObjectsFromDispatcher userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    /* Perform Baseline Analysis (get stored trustfactor objects, perform learning, and compare) */
    
    // Set the current state of Core Detection
    [[BEStartupStore sharedStartupStore] setCurrentState:@"Performing baseline analysis"];
    
    // Retrieve storedTrustFactorObjects & attach to trustFactorOutputObjects
    NSArray *updatedTrustFactorOutputObjects = [BEBaselineAnalysis performBaselineAnalysisUsing:trustFactorOutputObjects forPolicy:policy withError:&error];
    
    // Check that we have objects for computation
    if (!updatedTrustFactorOutputObjects || updatedTrustFactorOutputObjects == nil) {
        
        // Invalid TrustFactor output objects after baseline analysis
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No trustFactorOutputObjects available for computation", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Double check provided TrustFactors to analyze", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SANoTrustFactorOutputObjectsForComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    /* Perform TrustScore Computation (generates scores) */
    // Set the current state of Core Detection
    [[BEStartupStore sharedStartupStore] setCurrentState:@"Performing computation"];
    
    // Get the computation results
    BETrustScoreComputation *computationResults = [BETrustScoreComputation performTrustFactorComputationWithPolicy:policy withTrustFactorOutputObjects:updatedTrustFactorOutputObjects withError:&error];
    
    // Validate the computation results
    if (!computationResults || computationResults == nil) {
        
        // Invalid analysis, bad computation results
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No computation object returned, error during computation", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    /* Perform Results Analysis */
    
    // This largely sets the violationActionCodes and authenticationActionCodes
    
    [[BEStartupStore sharedStartupStore] setCurrentState:@"Performing results analysis"];
    
    // Get the computation results
    computationResults = [BEResultsAnalysis analyzeResultsForComputation:computationResults WithPolicy:policy WithError:&error];
    
    // Validate the computation results
    if (!computationResults || computationResults == nil) {
        
        // Invalid analysis, bad computation results
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"No results analysis object returned, error during result analysis", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    
    // Sanity check that we have all the action codes we need
    if (computationResults.postAuthenticationAction==0 || computationResults.authenticationAction==0 ||computationResults.coreDetectionResult==0) {
        
        // Invalid analysis, bad computation results
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Perform Core Detection Unsuccessful", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Missing one or more action codes", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check error logs for details", nil)
                                       };
        
        // Set the error
        error = [NSError errorWithDomain:coreDetectionDomain code:SAErrorDuringComputation userInfo:errorDetails];
        
        // Log it
        NSLog(@"Perform Core Detection Unsuccessful: %@", errorDetails);
        
        // Don't return anything except the error
        [self coreDetectionResponse:NO withComputationResults:nil andError:&error];
        
        // Return
        return;
    }
    
    
    // Set last computation results to be stored in core detection for use by functions that need it after core detection has alreay compelted
    [self setComputationResults:computationResults];
    
    // Return through the block callback
    [self coreDetectionResponse:YES withComputationResults:computationResults andError:&error];
    
}

- (void) recoverCoreDetectionWithError: (NSError **) error  callback:(coreDetectionBlock) callback {
    // We avoid analyzePreAuthenticationActions
    
    // Create  dummy computation results object that forces user login
    BETrustScoreComputation *computationResults = [[BETrustScoreComputation alloc]init];
    
    // Set the pre authetnication action
    computationResults.authenticationAction = authenticationAction_PromptForUserPasswordAndWarn;
    
    // Set to breach class
    computationResults.attributingClassID = 1;
    
    // Set GUI manually
    
    computationResults.dashboardText = @"Unknown Risk";
    
    // Set the core detection result to error
    computationResults.coreDetectionResult = CoreDetectionResult_CoreDetectionError;
    
    // Set the post authentication action, we cant whitelist because we have no assertions
    computationResults.postAuthenticationAction = postAuthenticationAction_DoNothing;
    
    // Populate data for dashboard
    // Scores
    
    computationResults.deviceTrusted = NO;
    computationResults.userTrusted = NO;
    computationResults.systemTrusted = NO;
    computationResults.systemScore = 0;
    computationResults.deviceScore=0;
    computationResults.userScore=0;
    
    // Set GUI messag
    computationResults.userSubClassResultObjects = nil;
    computationResults.systemSubClassResultObjects = nil;
    
    // Set the last computation results manually so that confirm() can use it
    [self setComputationResults:computationResults];
    
    callback(NO, computationResults, *error);
}



// Start Core Detection
// ** REMEMBER ** This can be called repeatedly without closing the app, therefore you must wipe datasets prior to each run of core detection
- (void)performCoreDetectionWithCallback:(coreDetectionBlock)callback {
    
    
    __weak BECoreDetection *weakSelf = self;

    @autoreleasepool {
        
        dispatch_queue_t myQueue = dispatch_queue_create("Core_Detection_Queue",NULL);
        
        dispatch_async(myQueue, ^{
            
            // Perform Core Detection
            @try {
                
                [weakSelf runCoreDetectionWithCallback:callback];
                
            } @catch (NSException *exception) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSMutableDictionary * info = [NSMutableDictionary dictionary];
                    [info setValue:exception.name forKey:@"ExceptionName"];
                    [info setValue:exception.reason forKey:@"ExceptionReason"];
                    [info setValue:exception.callStackReturnAddresses forKey:@"ExceptionCallStackReturnAddresses"];
                    [info setValue:exception.callStackSymbols forKey:@"ExceptionCallStackSymbols"];
                    [info setValue:exception.userInfo forKey:@"ExceptionUserInfo"];
                    
                    NSError *error = [[NSError alloc] initWithDomain:coreDetectionDomain
                                                                code:SAUnknownError
                                                            userInfo:info];
                    
                    [weakSelf recoverCoreDetectionWithError:&error callback:callback];
                });
                
            }
        });
    }
}

// Callback function for core detection
- (void)coreDetectionResponse:(BOOL)success withComputationResults:(BETrustScoreComputation *)computationResults andError:(NSError **)error {
    
    // Block callback
    if (coreDetectionBlockCallBack) {
        
        NSError *finalError = *error;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (finalError) {
                coreDetectionBlockCallBack(NO, computationResults, finalError);
                return;
            }
            
            NSError *error = nil;
            
            
            switch (computationResults.authenticationAction) {
                case authenticationAction_TransparentlyAuthenticate:
                case authenticationAction_TransparentlyAuthenticateAndWarn:
                    
                    {
                        
                        // Attempt to login
                        // we have no input to pass, use nil
                        BELoginResponse_Object *loginResponseObject = [[BELoginAction sharedLogin] attemptLoginWithTransparentAuthentication:&error];
                        
                        // Set the authentication response code
                        computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                        
                        // Set history now, we have all the info we need
                        [[BEStartupStore sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:&error];
                        
                        
                        if (computationResults.authenticationResult != authenticationResult_Success) {
                            //Transparent auth errored, something very wrong happened because the transparent module found a match earlier...
                            
                            // Have the user interactive login
                            // Manually override the preAuthenticationAction and recall this function, we don't need to run core detection again
                            
                            computationResults.authenticationAction = authenticationAction_PromptForUserPassword;
                            computationResults.postAuthenticationAction = postAuthenticationAction_whitelistUserAssertions;
                        }
                    }
                    
                    break;
                    
                    
                case authenticationAction_BlockAndWarn:
                    {
                        // Login Response
                        BELoginResponse_Object *loginResponseObject = [[BELoginAction sharedLogin] attemptLoginWithBlockAndWarn:&error];
                        
                        // Set the authentication response code
                        computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                        computationResults.loginResponseObject = loginResponseObject;
                        
                        // Set history now, we already have all the info we need
                        [[BEStartupStore sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:&error];
                    }
                    break;
            }
            
            // Call the Core Detection Block Callback
            coreDetectionBlockCallBack(success, computationResults, error);
            coreDetectionBlockCallBack = nil;
        });
        
    } else {
        
        // Block callback is nil (something is really wrong)
        NSDictionary *errorDetails = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Core Detection Response Failed", nil),
                                       NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"An invalid callback block was provided", nil),
                                       NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try passing a valid callback block", nil)
                                       };
        
        // Set the error
        *error = [NSError errorWithDomain:coreDetectionDomain code:SANoCallbackBlockProvided userInfo:errorDetails];
        
        // Log it
        NSLog(@"Core Detection Response Failed: %@", errorDetails);
        
    }
}

#pragma mark Singleton and init methods

// Singleton shared instance
+ (BECoreDetection *)sharedDetection {
    static BECoreDetection *sharedMyDetection = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyDetection = [[self alloc] init];
    });
    return sharedMyDetection;
}

// Init (Defaults)
- (id)init {
    if (self = [super init]) {
        // Default values get set here
        _computationResults = nil;
        BEActivityDispatcher *aaa = [[BEActivityDispatcher alloc] init];
        self.activityDispatcher = aaa;
    }
    return self;
}

#pragma mark - Main Methods


// Get the last computation results
- (BETrustScoreComputation *)getLastComputationResults {
    
    // Get the last computation result from the instance variable
    return _computationResults;
}

- (BEStartup *) getStartupError: (NSError **) error {
    BEStartup *startup = [[BEStartupStore sharedStartupStore] getStartupStore:error];
    return  startup;
}


#pragma mark - initialization

- (BEPolicy *) getCurrentPolicyWithError: (NSError **) error {
    BEPolicy *policy = [[BEPolicyParser sharedPolicy] getPolicy:error];
    return policy;
}

- (void) initializeCoreDetectionFromViewController: (UIViewController *) viewController error: (NSError **) error {
    self.parentViewController = viewController;
    
    //create permission requests
    self.locationPermissionRequest = [BELocationPermissionRequest new];
    self.activityPermissionRequest = [BEActivityPermissionRequest new];
    
    //create new startup file, we need it now because of deviceSalt
    [[BEStartupStore sharedStartupStore] createNewStartupFileWithError:error];
    if (*error) { return; }
    
    //remove any previous downloaded policy
    [[BEPolicyParser sharedPolicy] removePolicyFromDocuments:nil];
    
    //create new policy
    [[BEPolicyParser sharedPolicy] getPolicy:error];
    if (*error) { return; }

    [self updateInitialisation];
    
}


- (void) updateInitialisation {
    
    //first, check location permission
    if (self.locationPermissionRequest != nil) {
        if (self.locationPermissionRequest.permissionState == PermissionState_Unknown) {
            [self.delegate coreDetectionRequires: CoreDetectionRequirement_LocationPermission];
            return;
        } else if (self.locationPermissionRequest.permissionState == PermissionState_Authorized) {
            // Location allowed
            [[BETrustFactorDatasets sharedDatasets]  setLocationDNEStatus:DNEStatus_ok];
            [[BETrustFactorDatasets sharedDatasets]  setPlacemarkDNEStatus:DNEStatus_ok];
            [self.activityDispatcher startLocation];
        }
    }
    
    //second, check activity permissions
    if (self.activityPermissionRequest != nil) {
        if (self.activityPermissionRequest.permissionState == PermissionState_Unknown) {
            [self.delegate coreDetectionRequires: CoreDetectionRequirement_ActivityPermission];
            return;
        } else if (self.activityPermissionRequest.permissionState == PermissionState_Authorized) {
            // Location allowed
            [[BETrustFactorDatasets sharedDatasets] setActivityDNEStatus:DNEStatus_ok];
            [self.activityDispatcher startActivity];
        }
    }
    
    
    //third, ask for password
    [self.delegate coreDetectionRequires: CoreDetectionRequirement_PasswordSetUp];
    
}

- (void) acceptActivityPermission:(BOOL) accept {
    if (accept) {
        [self.activityPermissionRequest requestUserPermissionWithCompletionBlock:^(PermissionState state, NSError * _Nullable error) {
            [self updateInitialisation];
        }];
    } else {
        self.activityPermissionRequest = nil;
        [self updateInitialisation];
    }
   
}

- (void) acceptLocationPermission:(BOOL) accept {
    if (accept) {
        [self.locationPermissionRequest requestUserPermissionWithCompletionBlock:^(PermissionState state, NSError * _Nullable error) {
            [self updateInitialisation];
        }];
    } else {
        self.locationPermissionRequest = nil;
        [self updateInitialisation];
    }
}

- (void) setUpPassword: (NSString *) password withError: (NSError **) error {
    
    //reset assertion store (remove assertion file)
    [[BETrustFactorStorage sharedStorage] resetAssertionStoreWithError:error];
    
    if (*error) {
        return;
    }
    
    //new startup is already created, just update it with new password
    NSString *masterKeyString = [[BEStartupStore sharedStartupStore] updateStartupFileWithPassoword:password withError:error];
    
    if (*error) {
        return;
    }
    
    NSData *masterKey = [[BECrypto sharedCrypto] convertHexStringToData:masterKeyString withError:error];
    if (*error) {
        return;
    }
    
    self.masterKey = masterKey;
    
    
    //now check for biometrics
    NSNumber *passcodeStatus = [[BETrustFactorDatasets sharedDatasets] getPassword];
    
    //if passcode is set
    if (passcodeStatus.integerValue == 1) {
        
        //check if TouchID/FaceID is avaialable
        if ([[BEBiometricManager shared] checkIfBiometricIsAvailableWithError:error]) {
            //true
            [self.delegate coreDetectionRequires:CoreDetectionRequirement_BiometricsApproval];
        }
        else {
            // error code == -7 ("No fingers are enrolled with Touch ID.")
            // error code == -5 ("Passcode not set.")
            
            if ((*error).code == (-7)) {
                //no fingers/face are enrolled, show TouchID/FaceID and ask user to add fingerprint/face
                *error = nil;
                [self.delegate coreDetectionRequires:CoreDetectionRequirement_BiometricsApproval];
            }
            else {
                [self.delegate coreDetectionRequires:CoreDetectionRequirement_FinishedInitialisation];
            }
        }
    }
    
    else if (passcodeStatus.integerValue == 2) {
        
        UIAlertController* alert = [UIAlertController
                                    alertControllerWithTitle:@"Warning"
                                    
                                    message:@"A device-level passcode was not detected. This will result in increased authentication requirements. Would you like to add a passcode to the device?"
                                    
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"No, Continue"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 
                                                                 //set startup flag that user disabled Biometric
                                                                 NSError *error;
                                                                 BEStartup *startup = [[BEStartupStore sharedStartupStore] getStartupStore:&error];
                                                                 
                                                                 
                                                                 if (!error) {
                                                                     [startup setBiometricDisabledByUser:YES];
                                                                     [[BEStartupStore sharedStartupStore] setStartupStoreWithError:nil];
                                                                 }
                                                                 else {
                                                                     NSLog(@"ERROR: loading startup file");
                                                                 }
                                                                 
                                                                 // Continue to next step
                                                                 [self.delegate coreDetectionRequires:CoreDetectionRequirement_FinishedInitialisation];

                                                             }];
        
        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Yes, Exit Setup"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * action) {
                                                                   //Force to crash
                                                                   [self performSelector:NSSelectorFromString(@"crashme:") withObject:nil afterDelay:1];
                                                               }];
        
        [alert addAction:cancelAction];
        [alert addAction:settingsAction];
        
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
    }
    
    else {
        //unknown state, continue to the next step
        // If disabled show the unlock screen
        [self.delegate coreDetectionRequires:CoreDetectionRequirement_FinishedInitialisation];
    }
}

- (BOOL) isInitialisationFinished {
    NSError *error;
    BEStartup *startup = [[BEStartupStore sharedStartupStore] getStartupStore:&error];

    if (error) {
        return NO;
    }
    
    if (startup.userKeyEncryptedMasterKeyBlobString == nil) {
        return NO;
    }
    
    return YES;
}

- (void) enableBiometrics: (BOOL) enable withError: (NSError **) error {

    if (enable) {
        BEBiometricManager *biometricManager = [BEBiometricManager shared];
        
        if (![biometricManager checkIfBiometricIsAvailableWithError:error]) {
            
            // error code == -7 ("No fingers are enrolled with Touch ID.")
            // error code == -5 ("Passcode not set.")
            
            if ((*error).code == (-7) || (*error).code == (-5)) {
                
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:(*error).localizedDescription
                                                                               message:@"Open settings to configure TouchID/FaceID."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * action) {}];
                
                UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Open Settings"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * action) {
                                                                           
                                                                           //open settings (TouchID/FaceID section) for iOS 10 +
                                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:root=TOUCHID_PASSCODE"]
                                                                                                              options:@{}
                                                                                                    completionHandler:nil];
                                                                       }];
                
                [alert addAction:cancelAction];
                [alert addAction:settingsAction];
                
                [self.parentViewController presentViewController:alert animated:YES completion:nil];
                
                return;
            }
        }
        
        if (*error) {
            return;
        }
        
        //ask user to use touch ID for future login
        NSString *message = nil;
        if ([self faceIDAvailable]) {
            message = @"Use your Face ID to enroll in BioEncrypt";
        } else {
            message = @"Place fingerprint on the reader to enroll in BioEncrypt";
        }
        
        
        [biometricManager checkForBiometricAuthWithMessage:message withCallback:^(BiometricResultType resultType, NSError *errorT) {
            
            
            if (resultType == BiometricResultType_Success) {
                
                //create touch ID
                [biometricManager createBiometricWithDecryptedMasterKey:self.masterKey withCallback:^(BOOL successful, NSError *error) {
                    if (!successful) {
                        //error
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:error.localizedDescription
                                                                                       message:nil
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
                        [alert addAction:okAction];
                        
                        [self.parentViewController presentViewController:alert animated:YES completion:nil];
                    }
                    else {
                        //everything successfull
                        [self.delegate coreDetectionRequires:CoreDetectionRequirement_FinishedInitialisation];
                    }
                }];
            }
            else if (resultType == BiometricResultType_UserCanceled) {
                //user canceled popUp, do nothing
            }
            else if (resultType == BiometricResultType_FailedAuth) {
                //user failed to authentificate, show error
            }
            else {
                //unknown error
            }
        }];
    } else {
        BEStartup *startup = [[BEStartupStore sharedStartupStore] getStartupStore:error];
        
        if (*error) {
            return;
        }
        
        //save an answer
        [startup setBiometricDisabledByUser:YES];
        [[BEStartupStore sharedStartupStore] setStartupStoreWithError:error];
        
        if (*error) {
            return;
        }
        
        [self.delegate coreDetectionRequires:CoreDetectionRequirement_FinishedInitialisation];
    }
}

- (void) resetStoreAndStartupWithError: (NSError **) error {
    
    // Check if the store file exists
    BOOL storeFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[[BETrustFactorStorage sharedStorage] assertionStoreFilePath]];
    
    // Check for an error
    if (!storeFileExists) {
        
        // No store to remove
        NSLog(@"No store to remove");
        
        // Error out
        return;
        
    }
    
    // Remove the store
    NSLog(@"Store Path: %@", [[BETrustFactorStorage sharedStorage] assertionStoreFilePath]);
    [[NSFileManager defaultManager] removeItemAtPath:[[BETrustFactorStorage sharedStorage] assertionStoreFilePath] error:error];
    
    // Check for an error
    if (*error != nil) {
        
        // Unable to remove the store
        NSLog(@"Error unable to remove the store: %@", (*error).debugDescription);
        
        // Error out
        return;
        
    }

    // Get the startup store
    [[BEStartupStore sharedStartupStore] setCurrentStartupStore:[[BEStartup alloc] init]];
    
    // Write the new startup store to disk
    [[BEStartupStore sharedStartupStore] setStartupStoreWithError:error];
    
    // Check for an error
    if (*error != nil) {
        
        // Unable to remove the store
        NSLog(@"Error unable to write the new startup store: %@", (*error).debugDescription);
        
        // Error out
        return;
        
    }
}


/// checks if face id is avaiable on device
- (BOOL) faceIDAvailable {
    if (@available(iOS 11.0, *)) {
        LAContext *context = [[LAContext alloc] init];
        return  [context canEvaluatePolicy: kLAPolicyDeviceOwnerAuthentication error:nil] && context.biometryType == LABiometryTypeFaceID;
    }
    return false;
}

- (void) tryToLoginWithBiometricMessage: (NSString *) message callback: (BiometricBlock) callback {
    
    NSError *error;
    BEStartup *startup = [[BEStartupStore sharedStartupStore] getStartupStore:&error];
    
    if (error) {
        //did not able to read startup file, break
        callback(BiometricResultType_Error, error);
        return;
    }
    
    BEBiometricManager *biometricManager = [BEBiometricManager shared];
    
    //if touchID is already configured
    if (!startup.biometricDisabledByUser && startup.biometricKeyEncryptedMasterKeyBlobString) {
        
        if (message == nil)
            message = @"";
        
        [biometricManager getBiometricPasswordFromKeychainwithMessage:message
                                                     withCallback:^(BiometricResultType resultType, NSString *password, NSError *error) {
                                                         
            if (resultType == BiometricResultType_Success) {
                
                BETrustScoreComputation *computationResults = [self getLastComputationResults];
                
                BELoginResponse_Object *loginResponseObject = [[BELoginAction sharedLogin] attemptLoginWithBiometricpassword:password andError:&error];
                
                // Set the authentication response code
                computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
                
                // Set history now, we already have all the info we need
                [[BEStartupStore sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:&error];
                
                callback(resultType, nil);

            }
            else if (resultType == BiometricResultType_ItemNotFound) {
                //probabbly invalidated item due change of fingerprint/face set, we will just try to delete it
                [biometricManager removeBiometricPasswordFromKeychainWithCallback:nil];
                callback(resultType, nil);
            }
            else {
                //if failed auth, or user simply pressed cancel, do nothing
                callback(resultType, nil);
            }
        }];
    } else {
        callback(BiometricResultType_Error, nil);
    }
}


- (void) tryToLoginWithPassword: (NSString *) passwordAttempt callback: (coreDetectionBlock) callback
 {
    
     NSError *error;
     
    // Get last computation results
     BETrustScoreComputation *computationResults = [self getLastComputationResults];
    
    BEBiometricManager *biometricManager = [BEBiometricManager shared];
    
    BELoginResponse_Object *loginResponseObject = [[BELoginAction sharedLogin] attemptLoginWithPassword:passwordAttempt andError:&error];
    
    // Set the authentication response code
    computationResults.authenticationResult = loginResponseObject.authenticationResponseCode;
    
    // Set history now, we already have all the info we need
    [[BEStartupStore sharedStartupStore] setStartupFileWithComputationResult:computationResults withError:&error];
    
    // Success and recoverable errors operate the same since we still managed to get a decrypted master key
    if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
        
        NSData *decryptedMasterKey = loginResponseObject.decryptedMasterKey;
       
        NSError *error;
        BEStartup *startup = [[BEStartupStore sharedStartupStore] getStartupStore:&error];
        
        //user succesfully logged in with password, now check if user enabled touch ID for future login
        if (![startup biometricDisabledByUser]) {
            
            //touch ID enabled, check if touch ID is available on current device
            if ([biometricManager checkIfBiometricIsAvailableWithError:nil]) {
                
                //great, it is available, now check is touchID already configured, but item is invalidated
                if (biometricManager.biometricItemInvalidated) {
                    
                    //create touchID again
                    [biometricManager createBiometricWithDecryptedMasterKey:decryptedMasterKey withCallback:^(BOOL successful, NSError *error) {
                        callback(YES, computationResults, nil);
                    }];
                }
                //if touch ID is already configured and active, that means that user probbably canceled TouchID auth, or failed with auth. In both cases, just ignore and continue.
                else if (startup.biometricKeyEncryptedMasterKeyBlobString) {
                    // do nothing
                    callback(YES, computationResults, nil);
                }
                else {
                    //This should never happen because we are asking user for touchID after password creation
                   
                    callback(YES, computationResults, nil);
                }
            }
            else
                callback(YES, computationResults, nil);
        }
        else
            callback(YES, computationResults, nil);
        
    } else if(computationResults.authenticationResult == authenticationResult_incorrectLogin) {
        
        callback(NO, computationResults, nil);
        
    } else if (computationResults.authenticationResult == authenticationResult_irrecoverableError) {
        
        callback(NO, computationResults, nil);
        
    }
}

@end
