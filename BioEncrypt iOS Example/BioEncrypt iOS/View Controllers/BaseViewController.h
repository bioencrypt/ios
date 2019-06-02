//
//  BaseViewController.h
//  GOOD
//
//  Created by Ivo Leko on 17/04/16.
//

#import <UIKit/UIKit.h>

// System Version
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

typedef void (^CompletionBlock)(BOOL confirmed);


@interface BaseViewController : UIViewController


// Show an alert
- (UIAlertController *) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message;


@end
