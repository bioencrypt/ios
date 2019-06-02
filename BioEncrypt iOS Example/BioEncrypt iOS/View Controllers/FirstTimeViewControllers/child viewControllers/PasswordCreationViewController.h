//
//  InitialPasswordCreation.h
//  GOOD
//
//  Created by Ivo Leko on 16/04/16.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef void (^PasswordCompletionBlock)(NSString * password);


@interface PasswordCreationViewController : BaseViewController

@property (nonatomic, copy) PasswordCompletionBlock completionBlock;


@end
