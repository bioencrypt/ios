//
//  RootViewController.m
//  BioEncrypt iOS
//
//  Created by Ivo Leko on 09/03/2019.
//

#import "RootViewController.h"
#import "ILContainerView.h"
#import "FirstTimeViewController.h"
#import "AppDelegate.h"
#import "RESideMenu.h"
#import "BaseNavigationController.h"
#import "DashboardViewController.h"
#import "UnlockViewController.h"


@interface RootViewController () <CoreDetectionDelegate, UnlockViewControllerDelegate>

@property (nonatomic, strong) ILContainerView *containerView;
@property (nonatomic, strong) FirstTimeViewController *firstViewController;
@property (nonatomic, strong) UnlockViewController *unlockViewController;
@property (nonatomic) BOOL once;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.containerView = [[ILContainerView alloc] initWithFrame:self.view.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.containerView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:self.containerView];
    self.containerView.currentViewController = self;
    
    [BECoreDetection sharedDetection].delegate = self;
    
}

- (void) coreDetectionRequires: (CoreDetectionRequirement ) requirement {
    if (self.firstViewController != nil) {
        [self.firstViewController coreDetectionRequires:requirement];
    }
    
    if (requirement == CoreDetectionRequirement_FinishedInitialisation) {
        [self.firstViewController dismissViewControllerAnimated:YES completion:^{
            self.firstViewController = nil;
            [self openUnlock];
        }];
    }
    
}

- (void) openFirstTimeViewController {
    FirstTimeViewController *firstViewController = [[FirstTimeViewController alloc] init];
    self.firstViewController = firstViewController;
    [self presentViewController:firstViewController animated:YES completion:nil];
}


- (void) openUnlock {
    UnlockViewController *unlockVC = [[UnlockViewController alloc] init];
    unlockVC.delegate = self;
    self.unlockViewController = unlockVC;
    [self presentViewController:unlockVC animated:YES completion:nil];
}

- (void) finishWithDecryptedMasterKey: (NSString *) masterKey {
    //open dashboard
    
    DashboardViewController *dashboardViewController = [[DashboardViewController alloc] init];
    
    // Navigation Controller
    BaseNavigationController *navController = [[BaseNavigationController alloc] initWithRootViewController:dashboardViewController];
    
    
    RESideMenu *sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navController leftMenuViewController:nil rightMenuViewController:nil];
    
    // Don't scale content view
    [sideMenuViewController setScaleContentView:NO];
    //[sideMenuViewController setScaleMenuView:NO];
    
    sideMenuViewController.view.backgroundColor = [UIColor blackColor];
    
    //set new screen and state
    self.containerView.childViewController = sideMenuViewController;
    
    //dismiss unlock
    [self.unlockViewController dismissViewControllerAnimated:YES completion:^{
        self.unlockViewController = nil;
    }];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.once) {
        return;
    }
    self.once = YES;
    
    if (![[BECoreDetection sharedDetection] isInitialisationFinished]) {
        [self openFirstTimeViewController];
    } else {
        [self openUnlock];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return [self.containerView.childViewController preferredStatusBarStyle];
}
    


@end
