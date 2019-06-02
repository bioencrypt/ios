//
//  BETrustFactorDispatch_Motion.h
//  BioEncrypt
//
//

/*!
 *  Trust Factor Dispatch Activity is a rule that get's the motion of the device by such means as gyroscope 
 *  and orientation.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"
#import <CoreMotion/CoreMotion.h>

@interface BETrustFactorDispatch_Motion : NSObject

// Get motion using gyroscope
+ (BETrustFactorOutputObject *)grip:(NSArray *)payload;

+ (BETrustFactorOutputObject *)movement:(NSArray *)payload;

// Gets the device's orientation
+ (BETrustFactorOutputObject *)orientation:(NSArray *)payload;

@end
