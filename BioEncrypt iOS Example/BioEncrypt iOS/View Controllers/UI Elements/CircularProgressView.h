//
//  CircularProgressView.h
//  BioEncrypt
//
//  Created by Ivo Leko on 22/11/16.
//

#import <UIKit/UIKit.h>

@interface CircularProgressView : UIView

/**
 *  Integer value between 0 and 100. Default is 0.
 */
@property (nonatomic) NSInteger progress;

/**
 *  Color of circle while progress is 0. Default color is clearColor.
 */
@property (nonatomic, strong) UIColor *circleColor;

/**
 *  Color of circle while progress is 100. Default color is clearColor.
 */
@property (nonatomic, strong) UIColor *circleProgressColor;

/**
 *  Width of circle (in points). Default is 10.0
 */
@property (nonatomic) CGFloat circleWidth;


/**
 *  Change progress with animation.
 *
 *  @param progress   new progress
 *  @param animationDuration duration of animation, in seconds.
 */
- (void) setProgress:(NSInteger)progress withAnimationDuration: (CGFloat) animationDuration;


@end
