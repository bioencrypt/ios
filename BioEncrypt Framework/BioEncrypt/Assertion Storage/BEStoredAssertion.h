//
//  BEStoredAssertion.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>

@interface BEStoredAssertion : NSObject

// Hash the Assertion
@property (atomic,retain) NSString *assertionHash;

// Hit Counter
@property (atomic,retain) NSNumber *hitCount;

// Date and Time of last hit
@property (atomic,retain) NSNumber *lastTime;

// Date and Time first created
@property (atomic,retain) NSNumber *created;

// How many time to learn from
@property (atomic) double decayMetric;

@end
