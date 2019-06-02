//
//  BEAssertionStore+Helper.h
//  BioEncrypt
//
//

#import "BEAssertionStore.h"

@interface BEAssertionStore (Helper)

#pragma mark - Helper Methods

/**
 *  Creates a stored TrustFactor Object from a TrustFactor Output
 *
 *  @param trustFactorOutputObject TrustFactor Output Object
 *  @param error                   Error
 *
 *  @return BEStoredTrustFactorObject
 */
- (BEStoredTrustFactorObject *)createStoredTrustFactorObjectFromTrustFactorOutput:(BETrustFactorOutputObject *)trustFactorOutputObject withError:(NSError **)error;

/**
 *  Get a stored TrustFactor Object by a factorID
 *
 *  @param factorID The Factor ID of the TrustFactor
 *  @param exists   Whether it exists or not
 *  @param error    Error
 *
 *  @return Returns the Stored TrustFactor Object if it exists
 */
- (BEStoredTrustFactorObject *)getStoredTrustFactorObjectWithFactorID:(NSNumber *)factorID doesExist:(BOOL *)exists withError:(NSError **)error;

@end
