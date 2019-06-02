//
//  ActivityPermissionViewController.h
//  BioEncrypt
//
//  Created by Kramer on 9/30/15.
//

// Permission Kit
@import BioEncrypt;

#import "BaseViewController.h"


#import <UIKit/UIKit.h>

@interface ActivityPermissionViewController : BaseViewController

@property (nonatomic, copy) CompletionBlock completionBlock;


// Accept
- (IBAction)accept:(id)sender;

// Decline
- (IBAction)decline:(id)sender;

@end
