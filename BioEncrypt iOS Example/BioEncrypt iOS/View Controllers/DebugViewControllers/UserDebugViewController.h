//
//  UserDebugViewController.h
//
//  Created by Kramer, Nicholas on 8/10/15.
//

@import BioEncrypt;

#import <UIKit/UIKit.h>

// Menu Bar Button
#import "JTHamburgerButton.h"


@interface UserDebugViewController : UIViewController

// Computation Results
@property (nonatomic,strong) BETrustScoreComputation *computationResults;

// Menu Button
@property (strong, nonatomic) IBOutlet JTHamburgerButton *menuButton;

// Main Progress Bar - middle
@property (strong, nonatomic) IBOutlet UITextView *userDebugOutput;


@end
