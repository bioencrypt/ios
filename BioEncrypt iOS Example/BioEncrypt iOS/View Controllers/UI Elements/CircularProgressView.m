//
//  CircularProgressView.m
//  BioEncrypt
//
//  Created by Ivo Leko on 22/11/16.
//

#import "CircularProgressView.h"

@interface CircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *shapeLayerEmpty;
@property (nonatomic, strong) CAShapeLayer *shapeLayerProgress;

@end


@implementation CircularProgressView



#pragma mark - constructors and init methods

- (id) init {
    self = [super init];
    if (self) {
        [self configureLayers];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureLayers];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureLayers];
    }
    return self;
}

- (void) configureLayers {
    //set default values
    _progress = 0;
    _circleWidth = 10.0;
    
    //create layers
    self.shapeLayerEmpty = [[CAShapeLayer alloc] init];
    self.shapeLayerProgress = [[CAShapeLayer alloc] init];
    
    self.shapeLayerEmpty.fillColor = [UIColor clearColor].CGColor;
    self.shapeLayerProgress.fillColor = [UIColor clearColor].CGColor;

    
    [self.layer addSublayer:self.shapeLayerEmpty];
    [self.layer addSublayer:self.shapeLayerProgress];

    [self updateLayers];
}


- (void) updateLayers {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    self.shapeLayerEmpty.path = [UIBezierPath
                                 bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0)
                                 radius:self.bounds.size.height/2.0 - _circleWidth/2.0
                                 startAngle:-M_PI_2
                                 endAngle:2*M_PI-M_PI_2
                                 clockwise:YES].CGPath;
    
    self.shapeLayerEmpty.lineWidth = _circleWidth;
    
    self.shapeLayerProgress.path = [UIBezierPath
                                 bezierPathWithArcCenter:CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0)
                                 radius:self.bounds.size.height/2.0 - _circleWidth/2.0
                                 startAngle:-M_PI_2
                                 endAngle:(2*M_PI-M_PI_2)
                                 clockwise:YES].CGPath;
    
    self.shapeLayerProgress.lineWidth = _circleWidth;
    self.shapeLayerProgress.strokeEnd = (CGFloat) self.progress/100.0;

    [CATransaction commit];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    [self updateLayers];
}


#pragma mark - public methods

//progress (without animation)
- (void) setProgress:(NSInteger)progress {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    _progress = progress;
    self.shapeLayerProgress.strokeEnd = (CGFloat) progress/100.0;
    
    [CATransaction commit];
}

//color of empty circle
- (void) setCircleColor:(UIColor *)circleColor {
    self.shapeLayerEmpty.strokeColor = circleColor.CGColor;
}
- (UIColor *) circleColor {
    return [UIColor colorWithCGColor:self.shapeLayerEmpty.strokeColor];
}

//color of full circle
- (void) setCircleProgressColor:(UIColor *)circleProgressColor {
    self.shapeLayerProgress.strokeColor = circleProgressColor.CGColor;
}
- (UIColor *) circleProgressColor {
    return [UIColor colorWithCGColor:self.shapeLayerProgress.strokeColor];
}

//circle width
- (void) setCircleWidth:(CGFloat)circleWidth {
    _circleWidth = circleWidth;
    [self updateLayers];
}

//public method
- (void) setProgress:(NSInteger)progress withAnimationDuration: (CGFloat) animationDuration {
    if (animationDuration == 0)
        self.progress = progress;
    else {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        basicAnimation.fromValue = @((CGFloat)_progress/100.0);
        basicAnimation.toValue = @((CGFloat)progress/100.0);
        basicAnimation.duration = animationDuration;
        basicAnimation.removedOnCompletion = NO;
        basicAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        basicAnimation.fillMode = kCAFillModeForwards;
        [self.shapeLayerProgress addAnimation:basicAnimation forKey:@"StrokeEndAnimation"];
        _progress = progress;
    }
}





@end
