//
//  BEStoredTrustFactorObject.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>

#import "BEStoredAssertion.h"

@interface BEStoredTrustFactorObject : NSObject

// Unique Identifier
@property (nonatomic,retain) NSNumber *factorID;

// Revision Number
@property (nonatomic,retain) NSNumber *revision;

// History - How many to learn from
@property (nonatomic,retain) NSNumber *decayMetric;

// Learning mode allowed
@property (nonatomic) BOOL learned;

// First run date
@property (nonatomic,retain) NSDate *firstRun;

// Run count
@property (nonatomic,retain) NSNumber *runCount;

// Array of BEStoredAssertion objects
@property (nonatomic,retain) NSArray *assertionObjects;


@end
