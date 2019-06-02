//
//  BETrustFactorDispatch_Power.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Power is a rule that uses power level, whether the device is plugged in, and 
 *  battery state for TrustFactor calculations
 */

#import "BETrustFactorOutputObject.h"
#import "BETrustFactorDatasets.h"

@interface BETrustFactorDispatch_Power : NSObject

// Check power level of device
+ (BETrustFactorOutputObject *)powerLevelTime:(NSArray *)payload;

// Check if device is plugged in and charging
+ (BETrustFactorOutputObject *)pluggedIn:(NSArray *)payload;

// Get the state of the battery
+ (BETrustFactorOutputObject *)batteryState:(NSArray *)payload;


@end
