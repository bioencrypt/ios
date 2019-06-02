/*
 * This file contains Good Sample Code subject to the Good Dynamics SDK Terms and Conditions.
 * (c) 2014 Good Technology Corporation. All rights reserved.
 */

//
//  UnlockViewController.h
//  Skeleton
//
//  Created by Ian Harvey on 17/03/2014.
//

#import <UIKit/UIKit.h>


@protocol UnlockViewControllerDelegate <NSObject>

- (void) finishWithDecryptedMasterKey: (NSString *) masterKey;

@end

@import BioEncrypt;
#import "BaseViewController.h"


@interface UnlockViewController : BaseViewController

@property (nonatomic, weak) id<UnlockViewControllerDelegate> delegate;

@end
