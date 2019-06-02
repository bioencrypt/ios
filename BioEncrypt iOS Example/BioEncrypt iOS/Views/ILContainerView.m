//
//  ILContainerView.m
//  Pretzel Crisps
//
//  Created by Ivo Leko on 20/03/15.
//

#import "ILContainerView.h"

@implementation ILContainerView


- (void) setChildViewController:(UIViewController *)childViewController {
    
    if (_childViewController!=nil && childViewController!=nil) {
        [_childViewController willMoveToParentViewController:nil];
        [_childViewController.view removeFromSuperview];
        [_childViewController removeFromParentViewController];
    }
    
    UIViewController *vc = self.currentViewController;
    
    NSAssert(vc!=nil, @"ILContainerView must have been added as subview to UIViewController's view before adding childViewController");
    
    
    if (childViewController == nil) {
        [_childViewController willMoveToParentViewController:nil];
        [_childViewController.view removeFromSuperview];
        [_childViewController removeFromParentViewController];
    }
    else {
        [vc addChildViewController:childViewController];
        childViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        childViewController.view.frame = self.bounds;
        childViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        [self insertSubview:childViewController.view atIndex:0];
        [childViewController didMoveToParentViewController:vc];
    }
    _childViewController = childViewController;

}

- (void) dealloc {
    _childViewController = nil;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
