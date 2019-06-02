//
//  SystemDebugViewController.m
//
//  Created by Kramer, Nicholas on 8/10/15.
//

#import "SystemDebugViewController.h"

@interface SystemDebugViewController () {
    // Is the view dismissing?
    BOOL isDismissing;
}

// Right Menu Button Press
- (void)rightMenuButtonPressed:(JTHamburgerButton *)sender;

@end

@implementation SystemDebugViewController

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
    [self.systemDebugOutput setContentOffset:CGPointZero animated:NO];
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
    
    NSString *systemTrustFactorsTriggered = @"\nTrustFactors Triggered\n++++++++++++++++++++++++++++++\n";
    for(BETrustFactorOutputObject *trustFactorOutputObject in self.computationResults.systemTrustFactorsAttributingToScore){
        
        NSString *storedAssertions =@"";
        NSString *currentAssertions =@"";
        
        for(BEStoredAssertion *stored in trustFactorOutputObject.storadeAssertionObjectsMatched){
            
            storedAssertions = [storedAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",stored.assertionHash,stored.hitCount,stored.decayMetric,stored.lastTime];
        }
        
        for(BEStoredAssertion *current in trustFactorOutputObject.candidateAssertionObjects){
            
            currentAssertions = [currentAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",current.assertionHash,current.hitCount,current.decayMetric,current.lastTime];
            
        }

        systemTrustFactorsTriggered = [systemTrustFactorsTriggered stringByAppendingFormat:@"--Name: %@\n\nWeight Applied:%ld\nWeight Percent:%.02g\nUse Partial:%@\nTotal Possible:%@\n\nCurrent Assertion:\n%@Matching Assertions:\n%@",trustFactorOutputObject.trustFactor.name, (long)trustFactorOutputObject.appliedWeight,trustFactorOutputObject.percentAppliedWeight,trustFactorOutputObject.trustFactor.partialWeight,trustFactorOutputObject.trustFactor.weight,currentAssertions,storedAssertions];
        
    }
    complete = [complete stringByAppendingString:systemTrustFactorsTriggered];
    
    NSString *systemTrustFactorsNotLearned = @"\nTrustFactors Not Learned\n++++++++++++++++++++++++++++++\n";
    for(BETrustFactorOutputObject *trustFactorOutputObject in self.computationResults.systemTrustFactorsNotLearned){
        NSString *storedAssertions =@"";
        NSString *currentAssertions =@"";
        
        for(BEStoredAssertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            storedAssertions = [storedAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",stored.assertionHash,stored.hitCount,stored.decayMetric,stored.lastTime];
        }
        
        for(BEStoredAssertion *current in trustFactorOutputObject.candidateAssertionObjects){
            
            currentAssertions = [currentAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",current.assertionHash,current.hitCount,current.decayMetric,current.lastTime];
        }
        systemTrustFactorsTriggered = [systemTrustFactorsTriggered stringByAppendingFormat:@"--Name: %@\n\nCurrent Assertion:\n%@Stored Assertions:\n%@",trustFactorOutputObject.trustFactor.name, currentAssertions,storedAssertions];
    }
    complete = [complete stringByAppendingString:systemTrustFactorsNotLearned];
    
    
    
    NSString *systemTrustFactorsWithErrors = @"\nTrustFactors Errored\n++++++++++++++++++++++++++++++\n";
    for(BETrustFactorOutputObject *trustFactorOutputObject in self.computationResults.systemTrustFactorsWithErrors){
        
        systemTrustFactorsWithErrors = [systemTrustFactorsWithErrors stringByAppendingFormat:@"\nName: %@\nDNE: %u\n",trustFactorOutputObject.trustFactor.name,trustFactorOutputObject.statusCode];
        
    }
    
    complete = [complete stringByAppendingString:systemTrustFactorsWithErrors];
    
    NSString *systemTrustFactorsToWhitelist = @"\nTrustFactors To Whitelist\n++++++++++++++++++++++++++++++\n";
    for(BETrustFactorOutputObject *trustFactorOutputObject in self.computationResults.systemTrustFactorWhitelist){
        
        NSString *storedAssertions =@"";
        NSString *currentAssertions =@"";
        
        for(BEStoredAssertion *stored in trustFactorOutputObject.storedTrustFactorObject.assertionObjects){
            
            storedAssertions = [storedAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",stored.assertionHash,stored.hitCount,stored.decayMetric,stored.lastTime];
        }
        
        for(BEStoredAssertion *current in trustFactorOutputObject.candidateAssertionObjects){
            
            currentAssertions = [currentAssertions stringByAppendingFormat:@"Hash: %@\nHitCount: %@\nDecayMetric: %f\nLastTime: %@\n\n",current.assertionHash,current.hitCount,current.decayMetric,current.lastTime];
        }
        systemTrustFactorsTriggered = [systemTrustFactorsTriggered stringByAppendingFormat:@"--Name: %@\n\nCurrent Assertion:\n%@Stored Assertions:\n%@",trustFactorOutputObject.trustFactor.name, currentAssertions,storedAssertions];
        
        
    }
    complete = [complete stringByAppendingString:systemTrustFactorsToWhitelist];
    
    
    
    
    [self.systemDebugOutput setEditable:NO];
    self.systemDebugOutput.text = complete;
    
    
}


@end
