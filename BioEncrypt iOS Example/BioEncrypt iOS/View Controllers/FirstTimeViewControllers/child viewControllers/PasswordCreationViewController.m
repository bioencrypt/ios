//
//  InitialPasswordCreation.m
//  GOOD
//
//  Created by Ivo Leko on 16/04/16.
//

#import "PasswordCreationViewController.h"
@import BioEncrypt;

@interface PasswordCreationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *onePixelConstraintsCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomFooterConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *textFieldNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *textFieldConfirmPassword;
@property (weak, nonatomic) IBOutlet UIView *viewFooter;

- (IBAction)pressedInfoButton:(id)sender;

@end

@implementation PasswordCreationViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

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
    
    //scroll inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.viewFooter.frame.size.height, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;

}



- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //hide nav bar if neccesary
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //scroll inset
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, self.viewFooter.frame.size.height, 0);
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
}



- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (self.textFieldNewPassword == textField) {
        [self.textFieldConfirmPassword becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self confirm];
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Workaround for the jumping text bug in iOS.
    [textField resignFirstResponder];
    [textField layoutIfNeeded];
}


- (NSDictionary *) getPasswordRequirements: (NSError **) error {
    
    //get new policy
    BEPolicy *policy = [[BECoreDetection sharedDetection] getCurrentPolicyWithError:error];
    
    if (*error) {
        //some strange error occured
        return nil;
    }
    
    // get password requirements from policy
    NSDictionary *passwordRequirements = policy.passwordRequirements;
    
    //if there is no passwordRequirements defined in the policy, use default values (to support older policies)
    if (passwordRequirements == nil) {
        passwordRequirements =  @{
                                  @"minLength" : @(8),
                                  @"alphaNumeric" : @(YES),
                                  @"mixedCase" : @(NO),
                                  @"specialCharacter" : @(NO)
                                  };
    }

    
    return passwordRequirements;
}


// Validate the passwords
- (void)confirm {
    
    NSError *error;
    
    // Get the passwords
    NSString *pass1 = self.textFieldNewPassword.text;
    NSString *pass2 = self.textFieldConfirmPassword.text;

    //get password requirements from policies
    NSDictionary *passwordRequirements = [self getPasswordRequirements:&error];
    
    if (error) {
        [self showAlertWithTitle:@"Unknown error" andMessage:error.localizedDescription];
        return;
    }
    
    // Check if the passwords meet the criteria
    if (![pass1 isEqualToString:pass2]) {
        
        // passwords do not match
        [self showAlertWithTitle:@"Passwords do not match!" andMessage:@"Please try again."];
        return;
        
    } else if (![self checkPassword:pass1 withRequirements:passwordRequirements]) {
        
        // password is not valid
        return;
    }
    
    
    self.completionBlock(pass1);
}

- (IBAction)pressedInfoButton:(id)sender {
    //Show alert
    
    NSError *error;
    
    NSDictionary *dic = [self getPasswordRequirements:&error];
    if (error) {
        [self showAlertWithTitle:@"Unknown Error" andMessage:error.localizedDescription];
        return;
    }
    
    
    NSMutableString *stringM = [NSMutableString string];
    [stringM appendString:@"Your password must have:\n"];
    [stringM appendFormat:@"- At least %ld characters", (long)[dic[@"minLength"] integerValue]];
    
    if ([dic[@"alphaNumeric"] boolValue]) {
        [stringM appendFormat:@"\n"];
        [stringM appendFormat:@"- Alphanumeric characters"];
    }
    
    if ([dic[@"mixedCase"] boolValue]) {
        [stringM appendFormat:@"\n"];
        [stringM appendFormat:@"- Mixed case characters"];
    }
    
    if ([dic[@"specialCharacter"] boolValue]) {
        [stringM appendFormat:@"\n"];
        [stringM appendFormat:@"- Special character"];
    }

    
    [self showAlertWithTitle:   @"Password requirements"
                  andMessage:   stringM];
}


// TBD
- (BOOL) checkPassword: (NSString *) password withRequirements:(NSDictionary *) requirements {

    BOOL lowerCaseLetter = NO;
    BOOL upperCaseLetter = NO;
    BOOL digit = NO;
    BOOL character = NO;
    BOOL specialCharacter = NO;

    
    if (![requirements[@"mixedCase"] boolValue]) {
        lowerCaseLetter = YES;
        upperCaseLetter = YES;
    }
    
    if (![requirements[@"alphaNumeric"] boolValue]) {
        digit = YES;
        character = YES;
    }
    
    if (![requirements[@"specialCharacter"] boolValue]) {
        specialCharacter = YES;
    }
    
    if([password length] >= [requirements[@"minLength"] integerValue])
    {
        for (int i = 0; i < [password length]; i++)
        {
            unichar c = [password characterAtIndex:i];
            if(!lowerCaseLetter)
            {
                lowerCaseLetter = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!upperCaseLetter)
            {
                upperCaseLetter = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:c];
            }
            if(!digit)
            {
                digit = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:c];
            }
            if(!character)
            {
                character = [[NSCharacterSet letterCharacterSet] characterIsMember:c];
            }
            if(!specialCharacter)
            {
                specialCharacter = [[NSCharacterSet symbolCharacterSet] characterIsMember:c];
            }
        }
        
        if(digit && lowerCaseLetter && upperCaseLetter && character && specialCharacter)
        {
            //password is valid for given requirements
            return YES;
        }
        else
        {
            
            NSMutableString *stringM = [[NSMutableString alloc] init];
            [stringM appendString:@"Please ensure that you have at least "];
            if (!lowerCaseLetter || !upperCaseLetter) {
                [stringM appendString:@"one lower case letter and one upper case letter."];
            }
            else if (!digit) {
                [stringM appendString:@"one digit."];
            }
            else if (!character) {
                [stringM appendString:@"one character."];
            }
            else if (!specialCharacter) {
                [stringM appendString:@"one special character."];
            }
            
            [self showAlertWithTitle:@"Password Requirements" andMessage:stringM];
        }
        
    }
    else
    {
        [self showAlertWithTitle:@"Password Requirements" andMessage:[NSString stringWithFormat:@"Please Enter password with at least %ld characters.", (long)[requirements[@"minLength"] integerValue]]];
        
    }
    
    return NO;
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


@end
