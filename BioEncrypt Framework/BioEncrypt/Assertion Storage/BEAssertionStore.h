//
//  BEAssertionStore.h
//  BioEncrypt
//
//

/*!
 *  Assertion Store Class is all the output from the TrustFactors and a reference to the TrustFactors that ran
 */

#import <Foundation/Foundation.h>
#import "BEStoredTrustFactorObject.h"
#import "BETrustFactorOutputObject.h"

@interface BEAssertionStore : NSObject

/*!
 *  Application Identifier
 */
@property (atomic,strong) NSString *appID;

/**
 *  Assertion Objects
 */
@property (atomic,strong) NSArray *storedTrustFactorObjects; // BETA2 - Nick's Additions = Changed this back to NSArray

#pragma mark - Add

/**
 *  Add an array of new storedTrustFactorObjects to the store
 *
 *  @param storedTrustFactorObjects TrustFactors to add
 *  @param error                    Error
 *
 *  @return Whether it added them or not
 */
- (BOOL)addMultipleObjectsToStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error;

/**
 *  Add a single storedTrustFactorObject into the store
 *
 *  @param newStoredTrustFactorObject TrustFactor to add
 *  @param error                      Error
 *
 *  @return Whether it added them or not
 */
- (BOOL)addSingleObjectToStore:(BEStoredTrustFactorObject *)newStoredTrustFactorObject withError:(NSError **)error;

#pragma mark - Replace

/**
 *  Replace an array of storedTrustFactorObjects in the store
 *
 *  @param existingStoredTrustFactorObjects TrustFactors to replace with existing ones
 *  @param error                            Error
 *
 *  @return Whether it replaced them or not
 */
- (BOOL)replaceMultipleObjectsInStore:(NSArray *)existingStoredTrustFactorObjects withError:(NSError **)error;

/**
 *  Replace a single storedTrustFactorObject in the store
 *
 *  @param storedTrustFactorObject TrustFactor to replace with existing one
 *  @param error                   Error
 *
 *  @return Whether it replaced it or not
 */
- (BOOL)replaceSingleObjectInStore:(BEStoredTrustFactorObject *)storedTrustFactorObject withError:(NSError **)error;

#pragma mark - Remove

/**
 *  Remove array of storedTrustFactorObjects from the store
 *
 *  @param storedTrustFactorObjects Provide the TrustFactor Objects to be removed
 *  @param error                    Error
 *
 *  @return Whether they were removed or not
 */
- (BOOL)removeMultipleObjectsFromStore:(NSArray *)storedTrustFactorObjects withError:(NSError **)error;

/**
 *  Remove provided storedTrustFactorObject from the store
 *
 *  @param storedTrustFactorObject Provide the TrustFactor Object to be removed
 *  @param error                   Error
 *
 *  @return Whether it was removed or not
 */
- (BOOL)removeSingleObjectFromStore:(BEStoredTrustFactorObject *)storedTrustFactorObject withError:(NSError **)error;

@end
