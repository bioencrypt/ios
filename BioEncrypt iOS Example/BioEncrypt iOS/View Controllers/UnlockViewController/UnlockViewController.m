/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  UnlockViewController.m
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

@import MessageUI;
@import BioEncrypt;

#import "UnlockViewController.h"

// Animated Progress Alerts
#import "MBProgressHUD.h"


// Helpers and wrappers
#import "ILContainerView.h"



@interface UnlockViewController () <UITextFieldDelegate> {
    BOOL once;
}



@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *onePixelConstraintsCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomFooterConstraint;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;

@property (weak, nonatomic) IBOutlet UIButton *buttonInfo;
@property (weak, nonatomic) IBOutlet UIButton *buttonBioencrypt;



// Progress HUD
@property (nonatomic,strong) MBProgressHUD *hud;

@end


@implementation UnlockViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    // generate lines with one pixel (on all iOS devices)
    for (NSLayoutConstraint *constraint in self.onePixelConstraintsCollection) {
        constraint.constant = 1.0 / [UIScreen mainScreen].scale;
    }
    
    //notifications for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startCoreDetection];
}

- (void) startCoreDetection {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.label.text = @"Authenticating";
    self.hud.label.font = [UIFont fontWithName:@"OpenSans-Regular" size:20.0f];
    
    /* Perform Core Detection */
    __weak UnlockViewController *weakSelf = self;
    
    // Run Core Detection
    [[BECoreDetection sharedDetection] performCoreDetectionWithCallback:^(BOOL success, BETrustScoreComputation *computationResults, NSError *error) {
        
        // Check if core detection completed successfully
        if (success) {
            
            [weakSelf analyzeAuthenticationActionsWithError:&error];
            [MBProgressHUD hideHUDForView:weakSelf.view animated:NO];
            [weakSelf showInput];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"kLastRun"];
            
            // Log the errors
            if (error) {
                NSLog(@"\n\nErrors: %@", [error localizedDescription]);
            }
            
        } else {
            // Core Detection Failed
            NSLog(@"Failed to run Core Detection: %@", [error localizedDescription] ); // Here's why
        }
        
    }]; // End of the Core Detection Block
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self confirm];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Workaround for the jumping text bug in iOS.
    [textField resignFirstResponder];
    [textField layoutIfNeeded];
}


- (void) confirm {
    
    //Get password
    NSString *passwordAttempt = self.textFieldPassword.text;
    
    
    [[BECoreDetection sharedDetection] tryToLoginWithPassword:passwordAttempt callback:^(BOOL success, BETrustScoreComputation *computationResults, NSError *error) {
   
        if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
        
            // Now we can pass the key to the runtime
            NSData *decryptedMasterKey = computationResults.loginResponseObject.decryptedMasterKey;
            
            NSString *decryptedMasterKeyString = [[BECrypto sharedCrypto] convertDataToHexString:decryptedMasterKey withError:&error];
            
            [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
            
        } else if(computationResults.authenticationResult == authenticationResult_incorrectLogin) {
            
            // Show alert window
            [self showAlertWithTitle:computationResults.loginResponseObject.responseLoginTitle andMessage:computationResults.loginResponseObject.responseLoginDescription];
            
        } else if (computationResults.authenticationResult == authenticationResult_irrecoverableError) {
            
            // Show alert window
            [self showAlertWithTitle:computationResults.loginResponseObject.responseLoginTitle andMessage:computationResults.loginResponseObject.responseLoginDescription];
        }
    }];
}

- (void) finishWithDecryptedMasterKey: (NSString *) decryptedMasterKeyString {
    
    //got master key succesfully
    [self.delegate finishWithDecryptedMasterKey:decryptedMasterKeyString];

}


- (void) showInput {
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.buttonInfo.alpha = 1.0;
        self.inputContainer.alpha = 1.0;
        self.buttonBioencrypt.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}




-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and location
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    //do animation
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:UIViewAnimationOptionBeginFromCurrentState | [curve intValue] animations:^{
        self.bottomFooterConstraint.constant = (keyboardBounds.size.height);
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    //do animation
    [UIView animateWithDuration:[duration doubleValue] delay:0 options:UIViewAnimationOptionBeginFromCurrentState | [curve intValue] animations:^{
        self.bottomFooterConstraint.constant = 50;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}


- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //scroll inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.viewFooter.frame.size.height, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
}




#pragma mark - Analysis

// Set up the customizations for the view
- (void)analyzeAuthenticationActionsWithError:(NSError **)error {
    
    // Get last computation results
    BETrustScoreComputation *computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    
    
    // The only preAuthenticationActions handled here are transparent, blockAndWarn,
    switch (computationResults.authenticationAction) {
        case authenticationAction_TransparentlyAuthenticate:
        case authenticationAction_TransparentlyAuthenticateAndWarn:
        {
            // Now we can pass the key to the runtime
            NSData *decryptedMasterKey = computationResults.decryptedMasterKey;
            
            NSString *decryptedMasterKeyString = [[BECrypto sharedCrypto] convertDataToHexString:decryptedMasterKey withError:error];
            
            if (computationResults.authenticationAction == authenticationAction_TransparentlyAuthenticateAndWarn) {
                
                //show pop-up on rootViewController to be visible on dashboard
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:computationResults.warnTitle
                                                                               message:computationResults.warnDesc
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                      }];
                [alert addAction:defaultAction];
                
                [self presentViewController:alert animated:YES completion:^{
                    [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
                }];
            }
            else {
                [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
            }
            break;
        }
        case authenticationAction_PromptForUserBiometric:
        {
            //No promptForUserBiometricAndWarn because Biometric always displays a message
            [self tryToLoginWithBiometricMessage:computationResults.authenticationModuleEmployed.warnTitle];
            break;
        }
        case authenticationAction_PromptForUserBiometricAndWarn:
        {

            // Show message and than call biometric
            __weak __typeof (self) weakSelf = self;
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:computationResults.warnTitle
                                                                           message:computationResults.warnDesc
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [weakSelf tryToLoginWithBiometricMessage:computationResults.authenticationModuleEmployed.warnTitle];
                                                                  }];
            
            
            [alert addAction:defaultAction];
            
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
        case authenticationAction_PromptForUserPassword:
        {
            [self.textFieldPassword becomeFirstResponder];

            break;
        }
            
        case authenticationAction_PromptForUserPasswordAndWarn:
        {
            // Since we're already on the login screen, simply show a popup message then allow user to interact with login prompt

            [self.textFieldPassword becomeFirstResponder];
            [self showAlertWithTitle:computationResults.warnTitle andMessage:computationResults.warnDesc];
            
            break;
        }
        
        case authenticationAction_BlockAndWarn:
        {
            [self.textFieldPassword becomeFirstResponder];

            // TODO: Change to show denied view instead of popup box
            [self showAlertWithTitle:@"Access Denied" andMessage:@"This device is high risk or in violation of policy, this access attempt has been denied."];
            
            // Done
            break;
        }

        default:
            [self.textFieldPassword becomeFirstResponder];
            break;
            
    } // Done switch preauthentication action

}




#pragma mark - biometric

- (void) tryToLoginWithBiometricMessage:(NSString *) loginMessage {
    [[BECoreDetection sharedDetection] tryToLoginWithBiometricMessage:loginMessage callback:^(BiometricResultType biometricResult, NSError *error) {
        
        BETrustScoreComputation *computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
        
        if (biometricResult == BiometricResultType_Success) {
            // Success and recoverable errors operate the same since we still managed to get a decrypted master key
            if(computationResults.authenticationResult == authenticationResult_Success || computationResults.authenticationResult == authenticationResult_recoverableError ) {
                
                // Now we can pass the key to the runtime
                NSData *decryptedMasterKey = computationResults.loginResponseObject.decryptedMasterKey;
                
                NSString *decryptedMasterKeyString = [[BECrypto sharedCrypto] convertDataToHexString:decryptedMasterKey withError:&error];
                
                [self finishWithDecryptedMasterKey:decryptedMasterKeyString];
            }
            else {
                [self showAlertWithTitle:computationResults.loginResponseObject.responseLoginTitle andMessage:computationResults.loginResponseObject.responseLoginDescription];
            }
        }
        else if (biometricResult == BiometricResultType_ItemNotFound) {
            
            //probabbly invalidated item due change of biometric set
            if ([[BECoreDetection sharedDetection] faceIDAvailable]) {
                [self showAlertWithTitle:@"Notice"
                              andMessage:@"FaceID on this device has changed or was removed. You must reinstall BioEncrypt to resume biometric use. A password is required until corrected."];
            } else {
                [self showAlertWithTitle:@"Notice"
                              andMessage:@"One of the fingerprints on this device has changed or was removed. You must reinstall BioEncrypt to resume fingerprint use. A password is required until corrected."];
            }
        }
        else {
            //if failed auth, or biometric disabled, or user simply pressed cancel, do nothing
        }
    }];
}



@end
