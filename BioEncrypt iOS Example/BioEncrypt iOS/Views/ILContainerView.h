//
//  ILContainerView.h
//  Pretzel Crisps
//
//  Created by Ivo Leko on 20/03/15.
//

#import <UIKit/UIKit.h>

@interface ILContainerView : UIView

@property (nonatomic, weak) UIViewController *childViewController;
@property (nonatomic, weak) UIViewController *currentViewController;

@end
