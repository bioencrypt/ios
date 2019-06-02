//
//  BEBaselineAnalysis.h
//  BioEncrypt
//
//

/*!
 *  Baseline Analysis - Determines which rules have "triggered" based on current and stored assertions.
 */
#import <Foundation/Foundation.h>
#import "BETrustFactorOutputObject.h"
#import "BEPolicy.h"

@interface BEBaselineAnalysis : NSObject

// TrustFactorOutputObject (assertions) eligable for protectMode whitelisting
@property (nonatomic) NSMutableArray *trustFactorOutputObjectsForProtectMode;

/*!
 *  Perform baseline analysis with given TrustFactor output objects (assertions).
 *
 *  @param trustFactorOutputObjects
 *  @param policy                   The policy used for baseline analysis
 *  @param error                    Send an NSError to recieve an error value
 *
 *  @return An array with analysis
 */
+ (NSArray *)performBaselineAnalysisUsing:(NSArray *)trustFactorOutputObjects forPolicy:(BEPolicy *)policy withError:(NSError **)error;

@end
