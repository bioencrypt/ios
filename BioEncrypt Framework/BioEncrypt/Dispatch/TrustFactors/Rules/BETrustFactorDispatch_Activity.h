//
//  BETrustFactorDispatch_Activity.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Activity is a rule that gets the user's activities whether they are moving,
 *  stationary, or in a vehicle.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"
#import <CoreMotion/CoreMotion.h>

@interface BETrustFactorDispatch_Activity : NSObject 

// Get the user's previous activities as in if they are moving, stationary, etc.
+ (BETrustFactorOutputObject *)previous:(NSArray *)payload;

// Get device state while BioEncrypt running
+ (BETrustFactorOutputObject *) deviceState: (NSArray *) payload;

@end
