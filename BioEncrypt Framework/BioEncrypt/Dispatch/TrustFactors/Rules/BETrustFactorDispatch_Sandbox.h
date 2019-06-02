//
//  BETrustFactorDispatch_Sandbox.h
//  BioEncrypt
//
//

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Sandbox : NSObject 

// Sandbox Verification
+ (BETrustFactorOutputObject *)integrity:(NSArray *)payload;

@end
