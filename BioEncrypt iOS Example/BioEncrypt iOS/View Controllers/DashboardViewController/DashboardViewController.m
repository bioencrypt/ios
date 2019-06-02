//
//  DashboardViewController.m
//  BioEncrypt
//
//  Created by Ivo Leko on 22/11/16.
//

@import BioEncrypt;


#import "DashboardViewController.h"
#import "UserDeviceInformationViewController.h"

#import "NSDate+TimeElapsed.h"

#import "CircularProgressView.h"

// Side Menu
#import "RESideMenu.h"
#import "JTHamburgerButton.h"
#import "UIViewController+RESideMenu.h"
#import "DebugMenuViewController.h"




@interface DashboardViewController () <RESideMenuDelegate>

// data objects
@property (nonatomic, strong) BETrustScoreComputation *computationResults;

// UI elements
@property (weak, nonatomic) IBOutlet UILabel *labelLastRun;
@property (weak, nonatomic) IBOutlet UILabel *labelPercent;
@property (weak, nonatomic) IBOutlet UILabel *labelDashboardText;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUserError;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewUserNormal;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDeviceError;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDeviceNormal;

@property (weak, nonatomic) IBOutlet UIView *viewHolderForScore;
@property (weak, nonatomic) IBOutlet CircularProgressView *circularProgressView;


//Hamburger menu
@property (strong, nonatomic)  JTHamburgerButton *debugMenuButton;

@property (nonatomic, strong) DebugMenuViewController *debugMenuViewController;


- (IBAction)pressedUser:(id)sender;
- (IBAction)pressedDevice:(id)sender;


@end

@implementation DashboardViewController


#pragma mark - view-lifecycle

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // observe application will enter foreground
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    //load UI assets
    self.imageViewUserNormal.image = [[UIImage imageNamed:@"normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageViewUserNormal.tintColor = kCircularProgressFillColor;
    
    self.imageViewDeviceNormal.image = [[UIImage imageNamed:@"normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageViewDeviceNormal.tintColor = kCircularProgressFillColor;

    
    /*
     *  Navigation bar (header)
     */
    
    //remove blur
    self.navigationController.navigationBar.translucent = NO;
    
    //background color of bar (#444444)
    self.navigationController.navigationBar.barTintColor = kDefaultDashboardBarColor;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    //color of buttons
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    /**
     *  Circular Progress View setup
     */
    
    self.circularProgressView.circleWidth = 10.0;
    self.circularProgressView.circleColor = kCircularProgressEmptyColor;
    self.circularProgressView.circleProgressColor = kCircularProgressFillColor;
    self.circularProgressView.progress = 0;
    

    
    /**
     * Hamburger Menu
     */
    
    // Get policy to check for debug
    // Get the policy
    NSError *error;
    BEPolicy *policy = [[BECoreDetection sharedDetection] getCurrentPolicyWithError:&error];
    self.sideMenuViewController.delegate = self;

    
    
    if (policy.debugEnabled.intValue==1) {
        
        self.debugMenuViewController = [[DebugMenuViewController alloc] init];
        //need to set it twice because of bug in RESideMenu pod
        self.sideMenuViewController.leftMenuViewController = self.debugMenuViewController;
        self.sideMenuViewController.leftMenuViewController = self.debugMenuViewController;
    
        
        self.debugMenuButton = [[JTHamburgerButton alloc] initWithFrame:CGRectMake(0, 0, 40, 33)];
        [self.debugMenuButton setCurrentMode:JTHamburgerButtonModeHamburger];
        [self.debugMenuButton setLineColor:[UIColor whiteColor]];
        [self.debugMenuButton setLineWidth:28.0f];
        [self.debugMenuButton setLineHeight:2.0f];
        [self.debugMenuButton setLineSpacing:6.0f];
        [self.debugMenuButton setShowsTouchWhenHighlighted:YES];
        [self.debugMenuButton addTarget:self action:@selector(leftMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.debugMenuButton updateAppearance];
        
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.debugMenuButton];
        self.navigationItem.leftBarButtonItem = buttonItem;
        
    }
  
    
    //Prepare for animation
    self.viewHolderForScore.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    self.viewHolderForScore.alpha = 0;
    
    self.circularProgressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
    self.circularProgressView.alpha = 0;
    
    
}




- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    [self updateLabelsAndButtonsFromObject];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateAndUpdateProgress];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    [self updateLabelsAndButtonsFromObject];
    [self animateAndUpdateProgress];
}



#pragma mark - private methods

- (void) updateLabelsAndButtonsFromObject {
    
    
    // Set the trustscore
    self.labelPercent.text = [NSString stringWithFormat:@"%d", self.computationResults.deviceScore];
    
    // Last Run
    NSDate *lastRunDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"kLastRun"];
    
    // Check if the last run date exists
    if (!lastRunDate) {
        // Never updated
        self.labelLastRun.text = @"Last Run\nNever";
    } else {
        // Set the last update to when the last check was run
        self.labelLastRun.text = [NSString stringWithFormat:@"Last Run\n%@", [lastRunDate timeAgoSinceNow]];
    }
    
    
    // Dashboard text
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:5.0];
    style.alignment                = NSTextAlignmentCenter;
    
    NSDictionary *attribs = @{
                NSParagraphStyleAttributeName: style,
                NSForegroundColorAttributeName: kDefaultDashboardBarColor,
                NSFontAttributeName: [UIFont systemFontOfSize:22.0]
                };
    
   
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.computationResults.dashboardText attributes:attribs];
    self.labelDashboardText.attributedText = attributedString;
    
    
    
    // user button icon
    if (self.computationResults.userTrusted) {
        self.imageViewUserError.hidden = YES;
        self.imageViewUserNormal.hidden = NO;
    }
    else {
        self.imageViewUserError.hidden = NO;
        self.imageViewUserNormal.hidden = YES;
    }
    
    
    // device button icon
    if (self.computationResults.systemTrusted) {
        self.imageViewDeviceError.hidden = YES;
        self.imageViewDeviceNormal.hidden = NO;
    }
    else {
        self.imageViewDeviceError.hidden = NO;
        self.imageViewDeviceNormal.hidden = YES;
    }
    
}

- (void) animateAndUpdateProgress {
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.viewHolderForScore.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
        self.circularProgressView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);

        self.viewHolderForScore.alpha = 1;
        self.circularProgressView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
    
    [self.circularProgressView setProgress:self.computationResults.deviceScore withAnimationDuration:1.0];
}

- (NSArray *) sortedArray:(NSArray *) array byKey: (NSString *) key asceding: (BOOL) asceding {
    
    //create sort descriptor
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                 ascending:asceding];
    
    //array of sort descriptors
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    return sortedArray;
}




#pragma mark - IBActions


- (IBAction)pressedUser:(id)sender {
    UserDeviceInformationViewController *vc = [[UserDeviceInformationViewController alloc] init];
    vc.informationType = InformationTypeUser;
    vc.arrayOfSubClassResults = [self sortedArray:self.computationResults.userSubClassResultObjects
                                            byKey:@"subClassTitle"
                                         asceding:YES];

    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)pressedDevice:(id)sender {
    UserDeviceInformationViewController *vc = [[UserDeviceInformationViewController alloc] init];
    vc.informationType = InformationTypeDevice;
    vc.arrayOfSubClassResults = [self sortedArray:self.computationResults.systemSubClassResultObjects
                                            byKey:@"subClassTitle"
                                         asceding:YES];
    
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - RESideMenu

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController {
    // Set the hamburger button back
    [self.debugMenuButton setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
}


- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController {
    
    // Set the hamburger button back
    if (menuViewController == self.debugMenuViewController)
        [self.debugMenuButton setCurrentModeWithAnimation:JTHamburgerButtonModeCross];
    
}



// left Menu Button Pressed
- (void)leftMenuButtonPressed:(JTHamburgerButton *)sender {
    // Check which mode the menu button is in
    if (sender.currentMode == JTHamburgerButtonModeHamburger) {
        // Set it to arrow
        [sender setCurrentModeWithAnimation:JTHamburgerButtonModeCross];
        [sender setAnimationDuration:0.3];
        
        // Present the right menu
        [self presentLeftMenuViewController:self];
    } else {
        // Set it to hamburger
        [sender setCurrentModeWithAnimation:JTHamburgerButtonModeHamburger];
    }
}




@end
