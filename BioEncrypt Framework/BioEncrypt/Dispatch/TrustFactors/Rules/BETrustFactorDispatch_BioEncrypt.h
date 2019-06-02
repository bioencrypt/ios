//
//  BETrustFactorDispatchBioEncrypt.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch BioEncrypt is a tamper check rule.
 */
#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_BioEncrypt : NSObject 

// Tamper check
+ (BETrustFactorOutputObject *)tamper:(NSArray *)payload;

@end
