//
//  FirstTimeViewController.m
//  BioEncrypt
//
//  Created by Ivo Leko on 27/07/16.
//

@import BioEncrypt;


#import "FirstTimeViewController.h"
#import "WelcomeViewController.h"
#import "PasswordCreationViewController.h"
#import "UnlockViewController.h"
#import "BiometricPermissionViewController.h"

#import "LocationPermissionViewController.h"
#import "ActivityPermissionViewController.h"




@interface FirstTimeViewController () <CoreDetectionDelegate>

@property (strong, nonatomic) BiometricPermissionViewController *biometricPermissionViewController;
@property (nonatomic, strong) UnlockViewController *unlockViewController;

@property (nonatomic, strong) NSData *masterKey;

@property (nonatomic, strong) UIViewController *currentViewController;

//helper for managing viewController's views
@property (weak, nonatomic) IBOutlet ILContainerView *containerView;



@end

@implementation FirstTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.containerView setCurrentViewController:self];
    
    //show welcome screen
    [self showWelcome];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setCurrentViewController:(UIViewController *)currentViewController {
    
    //show currentViewController on the screen
    [self.containerView setChildViewController:currentViewController];
    _currentViewController = currentViewController;
    
}

- (void) coreDetectionRequires: (CoreDetectionRequirement ) requirement {
    switch (requirement) {
        case CoreDetectionRequirement_LocationPermission:
            {
                LocationPermissionViewController *vc = [[LocationPermissionViewController alloc] init];
                [vc setCompletionBlock:^(BOOL confirmed) {
                    [[BECoreDetection sharedDetection] acceptLocationPermission:confirmed];
                }];
                [self setCurrentViewController:vc];
            }
            break;
        case CoreDetectionRequirement_ActivityPermission:
            {
                ActivityPermissionViewController *vc = [[ActivityPermissionViewController alloc] init];
                [vc setCompletionBlock:^(BOOL confirmed) {
                    [[BECoreDetection sharedDetection] acceptActivityPermission:confirmed];
                }];
                [self setCurrentViewController:vc];
            }
            break;
        case CoreDetectionRequirement_PasswordSetUp:
            {
                PasswordCreationViewController *vc = [PasswordCreationViewController new];
                [vc setCompletionBlock:^(NSString *password) {
                    NSError *error = nil;
                    [[BECoreDetection sharedDetection] setUpPassword:password withError: &error];
                    if (error) {
                        [self showAlertWithTitle:@"Unknown error" andMessage:error.localizedDescription];
                    }
                }];
                [self setCurrentViewController:vc];
            }
            break;
        case CoreDetectionRequirement_BiometricsApproval:
            {
                BiometricPermissionViewController *vc = [BiometricPermissionViewController new];
                [vc setCompletionBlock:^(BOOL confirmed) {
                    NSError *error;
                    [[BECoreDetection sharedDetection] enableBiometrics:confirmed withError: &error];
                    if (error) {
                        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
                    }
                }];
                [self setCurrentViewController:vc];
            }
            break;
        case CoreDetectionRequirement_FinishedInitialisation: {
            break;
        }
    }
}


- (void) showWelcome {
    
    WelcomeViewController *welcome = [[WelcomeViewController alloc] init];
    
    [welcome setCompletionBlock:^(BOOL confirmed) {
        NSError *error;
        [[BECoreDetection sharedDetection] initializeCoreDetectionFromViewController:self error:&error];
        
        if (error) {
            [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
        }
    }];
    
    //set new screen and state
    [self setCurrentViewController:welcome];
}

@end
