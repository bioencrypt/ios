//
//  UserDebugViewController.m
//
//  Created by Kramer, Nicholas on 8/10/15.
//

#import "TransparentDebugViewController.h"

@interface TransparentDebugViewController () {
    // Is the view dismissing?
    BOOL isDismissing;
}

// Right Menu Button Press
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

@end

@implementation TransparentDebugViewController

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
    [self.transparentDebugOutput setContentOffset:CGPointZero animated:NO];
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
    
    NSString *userTrustFactorsEligible = @"\nTrustFactors Eligible\n++++++++++++++++++++++++++++++\n";
    for(BETrustFactorOutputObject *trustFactorOutputObject in self.computationResults.transparentAuthenticationTrustFactorOutputObjects){
        
        NSString *currentAssertions =@"";

        
        for(BEStoredAssertion *current in trustFactorOutputObject.candidateAssertionObjects){
            
            currentAssertions = [currentAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",current.assertionHash,current.hitCount,current.decayMetric,current.lastTime];
        }
        userTrustFactorsEligible = [userTrustFactorsEligible stringByAppendingFormat:@"--Name: %@\n\nWeight Applied:%ld\nWeight Percent:%.02g\nUse Partial:%@\nTotal Possible:%@\n\nCurrent Assertion:\n%@",trustFactorOutputObject.trustFactor.name, (long)trustFactorOutputObject.appliedWeight,trustFactorOutputObject.percentAppliedWeight,trustFactorOutputObject.trustFactor.partialWeight,trustFactorOutputObject.trustFactor.weight,currentAssertions];
        
    }
    complete = [complete stringByAppendingString:userTrustFactorsEligible];
    
    
    
    NSString *transparentAuthKey = @"\nCandidate Auth Key\n++++++++++++++++++++++++++++++\n";
    transparentAuthKey = [transparentAuthKey stringByAppendingFormat:@"--Name: %@\n\n",self.computationResults.candidateTransparentKeyHashString];
    
    complete = [complete stringByAppendingString:transparentAuthKey];
    
    
    
    
    NSString *transparentAuthMatch = @"\nFound Matching Key\n++++++++++++++++++++++++++++++\n";
    transparentAuthMatch = [transparentAuthMatch stringByAppendingFormat:@"%i\n\n",self.computationResults.foundTransparentMatch];
    
    complete = [complete stringByAppendingString:transparentAuthMatch];
    
    
    NSString *storedTransparentAuthKeys = @"\nStored Transparent Auth Keys\n++++++++++++++++++++++++++++++\n";
    
    NSError *error;
    BEStartup *startup = [[BECoreDetection sharedDetection] getStartupError:&error];
    
    NSArray * storedTransparentAuthObjects = [startup transparentAuthKeyObjects];
    
    // Compare current transparent key hash to stored hashes
    for(BETransparentAuth_Object *storedTransparentAuthObject in storedTransparentAuthObjects)
    {
        
        storedTransparentAuthKeys = [storedTransparentAuthKeys stringByAppendingFormat:@"AuthKeyHash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",[storedTransparentAuthObject transparentKeyPBKDF2HashString],[storedTransparentAuthObject hitCount],[storedTransparentAuthObject decayMetric],[storedTransparentAuthObject lastTime]];
        
        ;
    }
    
    complete = [complete stringByAppendingString:storedTransparentAuthKeys];
    
    
    [self.transparentDebugOutput setEditable:NO];
    self.transparentDebugOutput.text = complete;
    
    
}

@end
