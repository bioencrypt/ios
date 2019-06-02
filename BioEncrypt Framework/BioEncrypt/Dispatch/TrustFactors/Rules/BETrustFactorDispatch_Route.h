//
//  BETrustFactorDispatch_Route.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Route is a rule that checks for a VPN and routes.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Route : NSObject 

// Check if using a VPN
+ (BETrustFactorOutputObject *)vpnUp:(NSArray *)payload;

// No route
+ (BETrustFactorOutputObject *)noRoute:(NSArray *)payload;

@end
