//
//  BETrustFactorDispatch.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Cellular is a rule that gets connection information in addition to checking if 
 *  the user's device is in airplane mode.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Celluar : NSObject 

// USES PRIVATE API
+ (BETrustFactorOutputObject *)cellConnectionChange:(NSArray *)payload;

// USES PRIVATE API
+ (BETrustFactorOutputObject *)airplaneMode:(NSArray *)payload;

@end
