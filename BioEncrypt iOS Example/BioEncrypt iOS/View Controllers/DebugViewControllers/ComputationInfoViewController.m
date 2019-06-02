//
//  ComputationInfoViewController.m
//
//  Created by Kramer, Nicholas on 8/10/15.
//

#import "ComputationInfoViewController.h"

@interface ComputationInfoViewController () {
    // Is the view dismissing?
    BOOL isDismissing;
}

// Right Menu Button Press
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

@end

@implementation ComputationInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set up the menu button
    [self.menuButton setCurrentMode:JTHamburgerButtonModeCross];
    [self.menuButton setLineColor:[UIColor colorWithWhite:0.921f alpha:1.0f]];
    [self.menuButton setLineWidth:40.0f];
    [self.menuButton setLineHeight:4.0f];
    [self.menuButton setLineSpacing:7.0f];
    [self.menuButton setShowsTouchWhenHighlighted:YES];
    [self.menuButton addTarget:self action:@selector(rightMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton updateAppearance];
    
    // Get last computation results
    self.computationResults = [[BECoreDetection sharedDetection] getLastComputationResults];
    
    // Populate debug text
    [self setText];
}

#pragma mark - Actions

// Right Menu Button Pressed
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender {
    // Check which mode the menu button is in
    if (sender.currentMode == JTHamburgerButtonModeCross) {
        
        // Set is dismissing to yes
        isDismissing = YES;
        
        // Remove the view controller
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

// Layout subviews
- (void)viewDidLayoutSubviews {
    // Call SuperClass
    [super viewDidLayoutSubviews];
    
    // Don't show if dismissing
    if (isDismissing) {
        return;
    }
    
    // Cutting corners here
    //self.view.layer.cornerRadius = 7.0;
    //self.view.layer.masksToBounds = YES;
    self.view.layer.mask = nil;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(7.0, 7.0)].CGPath;
    self.view.layer.mask = maskLayer;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Use the screen rectangle, not the current size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // Set the frame - depending on the orientation
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        // Landscape
        [self.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    } else {
        // Portrait
        [self.view setFrame:CGRectMake(0, 0 + [UIApplication sharedApplication].statusBarFrame.size.height, screenRect.size.width, screenRect.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
    }
    
    // Scroll to top
    [self.computationDebugOutput setContentOffset:CGPointZero animated:NO];
}

// Set the status bar to white
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setText {
    
    NSString *complete = @"";
    
    NSString *policy = @"\nPolicy Settings\n++++++++++++++++++++++++++++++\n";
    NSError *error;
    
    BEPolicy * policy1 = [[BECoreDetection sharedDetection] getCurrentPolicyWithError:&error];
    
    //policy = [policy stringByAppendingFormat:@"\nSystem Threshold: %@\nUser Threshold: %@\n",policy1.systemThreshold,policy1.userThreshold];
    
    policy = [policy stringByAppendingFormat:@"\nSYSTEM THRESHOLD: %@\n",policy1.systemThreshold];
    
    complete = [complete stringByAppendingString:policy];
    
    NSString *systemSubScores = @"\nSystem Sub Scores\n++++++++++++++++++++++++++++++\n";
    
    systemSubScores = [systemSubScores stringByAppendingFormat:@"\nBREACH_INDICATOR: %d\nPOLICY_VIOLATION: %d\nSYSTEM_SECURITY: %d\n",self.computationResults.systemBreachScore, self.computationResults.systemPolicyScore,self.computationResults.systemSecurityScore];
    
    
    complete = [complete stringByAppendingString:systemSubScores];
    
    
    NSString *userSubScores = @"\nUser Sub Scores\n++++++++++++++++++++++++++++++\n";
    
    userSubScores = [userSubScores stringByAppendingFormat:@"\nUSER_POLICY: %d\nUSER_ANOMALY: %d\n",self.computationResults.userPolicyScore, self.computationResults.userAnomalyScore];
    
    
    complete = [complete stringByAppendingString:userSubScores];
    
    NSString *authModules = @"\nAuthentication Modules\n++++++++++++++++++++++++++++++\n";
    
    for(BEAuthentication *authModule in policy1.authenticationModules){
        
        authModules = [authModules stringByAppendingFormat:@"\nMODULE NAME: %@\nTHRESHOLD: %d\n",authModule.name,[authModule.activationRange intValue]];
    }
    

    complete = [complete stringByAppendingString:authModules];

    
    [self.computationDebugOutput setEditable:NO];
    self.computationDebugOutput.text = complete;
    
    
}

@end
