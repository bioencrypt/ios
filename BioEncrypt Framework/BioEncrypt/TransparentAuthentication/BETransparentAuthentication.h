//
//  BETransparentAuthentication.h
//  BioEncrypt
//
//

/*!
 *  Transparent authentication converts TrustFactors to encryption keys when the device is trusted
 */

#import <Foundation/Foundation.h>

// BioEncrypt constants
#import "BEConstants.h"

// BioEncrypt Policy
#import "BEPolicy.h"
#import "BETrustScoreComputation.h"
#import "BETrustFactorOutputObject.h"

// Startup
#import "BEStartup.h"


// Computation
#import "BETrustScoreComputation.h"

@class BETrustScoreComputation;

@interface BETransparentAuthentication : NSObject

// Singleton instance
+ (id)sharedTransparentAuth;

/*!
 *  Attempts transparent authentication and returns True if an existing match was found and false if none was found
 */
- (BETrustScoreComputation *)attemptTransparentAuthenticationForComputation:(BETrustScoreComputation *)computationResults withPolicy:(BEPolicy *)policy withError:(NSError **)error;


/*!
 *  Analyzes the eligible transparent auth objects and prioritizes the best authenticators to avoid making weak or uncommon keys
 */
- (BOOL)analyzeEligibleTransparentAuthObjects:(BETrustScoreComputation *)computationResults withPolicy:(BEPolicy *)policy withError:(NSError **)error;


@end
