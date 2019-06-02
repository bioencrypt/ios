//
//  BETrustFactorDispatch_Configuration.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Configuration is a simple rule that checks for basic information such as
 *  if the user uses a passcode or iCloud backup capability.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Configuration : NSObject

// Check if iCloud is enabled
+ (BETrustFactorOutputObject *)backupEnabled:(NSArray *)payload;

// Seperate TF for user because it only returns when pw IS set
+ (BETrustFactorOutputObject *)passcodeSetUser:(NSArray *)payload;

// Seperate TF for system because it only returns when pw NOT set
+ (BETrustFactorOutputObject *)passcodeSetSystem:(NSArray *)payload;

@end
