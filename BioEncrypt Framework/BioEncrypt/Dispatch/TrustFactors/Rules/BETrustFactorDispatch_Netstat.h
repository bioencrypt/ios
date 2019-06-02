//
//  BETrustFactorDispatch_Netstat.h
//  BioEncrypt
//
//

/*!
 *  Trust Factor Dispatch Netstat is a rule that uses Netstat information for TrustScore calculation.
 */
#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Netstat : NSObject 

// Bad destination
+ (BETrustFactorOutputObject *)badDst:(NSArray *)payload;

// Priviledged port
+ (BETrustFactorOutputObject *)priviledgedPort:(NSArray *)payload;

// New service
+ (BETrustFactorOutputObject *)newService:(NSArray *)payload;

// Data exfiltration
+ (BETrustFactorOutputObject *)dataExfiltration:(NSArray *)payload;

// Unencrypted traffic
+ (BETrustFactorOutputObject *)unencryptedTraffic:(NSArray *)payload;

// Good NOC (TBD)
+ (BETrustFactorOutputObject *)goodDNS:(NSArray *)payload;

@end
