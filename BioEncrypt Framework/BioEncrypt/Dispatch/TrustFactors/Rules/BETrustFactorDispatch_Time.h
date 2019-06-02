//
//  BETrustFactorDispatch_Time.h
//  BioEncrypt
//
//

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Time : NSObject

// Not implemented in default policy
+ (BETrustFactorOutputObject *)accessTimeDay:(NSArray *)payload;


+ (BETrustFactorOutputObject *)accessTimeHour:(NSArray *)payload;


@end





