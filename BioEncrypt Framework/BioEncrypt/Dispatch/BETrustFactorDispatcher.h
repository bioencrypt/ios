//
//  BETrustFactorDispatcher.h
//  BioEncrypt
//
//

/*!
 *  The TrustFactor Dispatcher calls the appropriate function and implementation routine for a provided rule.
 */

#import <Foundation/Foundation.h>

// Assertions
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatcher : NSObject

/**
 *  Run an array of trustfactors
 *
 *  @param trustFactors TrustFactors to run
 *  @param timeout      Timeout period (how long it has to run)
 *  @param error        Error
 *
 *  @return Returns an array of trustfactor assertions (output)
 */
+ (NSArray *)performTrustFactorAnalysis:(NSArray *)trustFactors withTimeout:(NSTimeInterval)timeout andError:(NSError **)error;

// Generate the output from a single TrustFactor
+ (BETrustFactorOutputObject *)executeTrustFactor:(BETrustFactor *)trustFactor withError:(NSError **)error;

// Run an individual trustfactor with just the name and the payload (returned assertion will not be able to identify the trustfactor that was run)
+ (BETrustFactorOutputObject *)runTrustFactorWithDispatch:(NSString *)dispatch andImplementation:(NSString *)implementation withPayload:(NSArray *)payload andError:(NSError **)error;

@end
