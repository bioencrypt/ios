//
//  BETrustFactorDispatch_Location.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Location is a rule that uses the location of the device and the changes of the
 *  device to assess the trust score of the user and the device.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Location : NSObject

/* Old/Archived
// Determine if device is in a location of an allowed country
// + (BETrustFactorOutputObject *)countryAllowed:(NSArray *)payload;
 */

// Determine location of device
+ (BETrustFactorOutputObject *)locationGPS:(NSArray *)payload;

// Location approximation using brightness of screen, strength of cell tower, and magnetometer readings
+ (BETrustFactorOutputObject *)locationApprox:(NSArray *)payload;

@end
