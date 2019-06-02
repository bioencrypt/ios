//
//  SystemDebugViewController.h
//
//  Created by Kramer, Nicholas on 8/10/15.
//


@import BioEncrypt;

#import <UIKit/UIKit.h>

// Menu Bar Button
#import "JTHamburgerButton.h"

@interface SystemDebugViewController : UIViewController

// Computation Results
@property (nonatomic,strong) BETrustScoreComputation *computationResults;

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

@property (strong, nonatomic) IBOutlet UITextView *systemDebugOutput;


@end
