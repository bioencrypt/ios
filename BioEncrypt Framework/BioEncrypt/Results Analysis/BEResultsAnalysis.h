//
//  BETrustScoreComputation.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>
#import "BEPolicy.h"

// Transparent Authentication
#import "BETransparentAuthentication.h"

#import "BETrustScoreComputation.h"

@class BETrustScoreComputation;


@interface BEResultsAnalysis : NSObject

+ (BETrustScoreComputation *)analyzeResultsForComputation:(BETrustScoreComputation *)computationResults WithPolicy:(BEPolicy *)policy WithError:(NSError **)error;


@end
