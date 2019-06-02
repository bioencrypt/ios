//
//  BETrustFactorOutputObject.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>
#import "BEStoredTrustFactorObject.h"
#import "BETrustFactor.h"
#import "BEConstants.h"
#import "BEStoredAssertion.h"


@interface BETrustFactorOutputObject : NSObject

// ID to allow sorting for transparent auth re-ordering
@property (nonatomic) NSInteger factorID;

// Attach the policy trustfactor data
@property (nonatomic,retain) BETrustFactor *trustFactor;

// Attach the parsed storedTrustFactorObject data
@property (nonatomic,retain) BEStoredTrustFactorObject *storedTrustFactorObject;

// Plaintext output from TrustFactor
@property (nonatomic,retain) NSArray *output;

// Required to calculate percent of weight to apply
// List of all matched assertions in the store
@property (nonatomic,retain) NSArray *storadeAssertionObjectsMatched;

// BEStoredAssertion objects to whitelist if protect mode is deactivated
@property (nonatomic,retain) NSArray *candidateAssertionObjectsForWhitelisting;

// BEStoreAssertion objects created from output
@property (nonatomic,retain) NSArray *candidateAssertionObjects;

// DNE modifier
@property (nonatomic) DNEStatusCode statusCode;

// Indicates if match found in assertion store, set during baseline analysis and checked during computation
@property (nonatomic) BOOL matchFound;

// Indicates if the TrustFactor shold be triggered regardless of match found or not found in the store
@property (nonatomic) BOOL forComputation;

// Indicates if the TrustFactor should be whitelisted
@property (nonatomic) BOOL whitelist;

// Debug value to hold the actual weight this TF applied (not necessarily the policy weight)
@property (nonatomic) NSInteger appliedWeight;
@property (nonatomic) double percentAppliedWeight;


- (void)setAssertionObjectsFromOutputWithError: (NSError **) error;

//TODO: Unused: - (void)setAssertionObjectsToDefault;

// Custom init to set DNE = OK and defaultAssertionString
- (id) init;


@end
