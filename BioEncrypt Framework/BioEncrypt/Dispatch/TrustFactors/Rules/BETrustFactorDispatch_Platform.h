//
//  BETrustFactorDispatch_Platform.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Platform is rule that checks for bad/allowed versions as well as up time for
 *  TrustFactor calculations.
 */
#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Platform : NSObject 

// Vunerable/bad version
+ (BETrustFactorOutputObject *)vulnerableVersion:(NSArray *)payload;

// Allowed versions
+ (BETrustFactorOutputObject *)versionAllowed:(NSArray *)payload;

// Short up time
+ (BETrustFactorOutputObject *)shortUptime:(NSArray *)payload;



@end
