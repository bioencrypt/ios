//
//  BETrustFactor.h
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//

#import <Foundation/Foundation.h>

@interface BETrustFactor : NSObject

@property (nonatomic, retain) NSNumber *identification;
@property (nonatomic, retain) NSString *notFoundIssueMessage;
@property (nonatomic, retain) NSString *lowConfidenceIssueMessage;
@property (nonatomic, retain) NSString *notFoundSuggestionMessage;
@property (nonatomic, retain) NSString *lowConfidenceSuggestionMessage;
@property (nonatomic, retain) NSNumber *revision;
@property (nonatomic, retain) NSNumber *classID;
@property (nonatomic, retain) NSNumber *subClassID;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *transparentEligible;
@property (nonatomic, retain) NSNumber *highEntropyAuthenticator;
@property (nonatomic, retain) NSNumber *partialWeight;
@property (nonatomic, retain) NSNumber *weight;
@property (nonatomic, retain) NSNumber *dnePenalty;
@property (nonatomic, retain) NSNumber *learnMode;
@property (nonatomic, retain) NSNumber *learnTime;
@property (nonatomic, retain) NSNumber *learnAssertionCount;
@property (nonatomic, retain) NSNumber *learnRunCount;
@property (nonatomic, retain) NSNumber *whitelistable;
@property (nonatomic, retain) NSNumber *privateAPI;
@property (nonatomic, retain) NSNumber *decayMode;
@property (nonatomic, retain) NSNumber *decayMetric;
@property (nonatomic, retain) NSNumber *wipeOnUpdate;
@property (nonatomic, retain) NSString *dispatch;
@property (nonatomic, retain) NSString *implementation;
@property (nonatomic, retain) NSArray *payload;

@end
