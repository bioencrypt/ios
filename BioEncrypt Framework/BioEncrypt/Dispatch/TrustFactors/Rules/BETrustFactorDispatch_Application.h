//
//  BETrustFactorDispatch_Application.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Application is a rule that that looks for installed apps on the user's device to
 *  determine which ones are trusted as opposed to ones that are high risk.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Application : NSObject

// USES PRIVATE API
//+ (BETrustFactorOutputObject *)installedApp:(NSArray *)payload;

/* Removed due to iOS 9
 
// 4 - Bad URL Handler Checks (cydia://, snoopi-it://, etc)
+ (BETrustFactorOutputObject *)uriHandler:(NSArray *)payload;

+ (BETrustFactorOutputObject *)runningApp:(NSArray *)payload;

 */

@end
