//
//  ComputationInfoViewController.h
//
//  Created by Kramer, Nicholas on 8/10/15.
//

@import BioEncrypt;
#import <UIKit/UIKit.h>

@import BioEncrypt;

// Menu Bar Button
#import "JTHamburgerButton.h"


@interface ComputationInfoViewController : UIViewController

// Computation Results
@property (nonatomic,strong) BETrustScoreComputation *computationResults;

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

@property (strong, nonatomic) IBOutlet UITextView *computationDebugOutput;

@end
