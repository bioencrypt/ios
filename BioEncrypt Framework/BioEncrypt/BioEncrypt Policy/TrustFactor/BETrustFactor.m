//
//  BETrustFactor.m
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//

#import "BETrustFactor.h"

@implementation BETrustFactor


// Identification
- (void)setIdentification:(NSNumber *)identification{
    _identification = identification;
}

// issue message
- (void)setNotFoundIssueMessage:(NSString *)notFoundIssueMessage{
    _notFoundIssueMessage = notFoundIssueMessage;
}

// issue message
- (void)setLowConfidenceIssueMessage:(NSString *)lowConfidenceIssueMessage{
    _lowConfidenceIssueMessage = lowConfidenceIssueMessage;
}


// suggestion message
- (void)setNotFoundSuggestionMessage:(NSString *)notFoundSuggestionMessage{
    _notFoundSuggestionMessage = notFoundSuggestionMessage;
}

// suggestion message
- (void)setLowConfidenceSuggestionMessage:(NSString *)lowConfidenceSuggestionMessage{
    _lowConfidenceSuggestionMessage = lowConfidenceSuggestionMessage;
}


// Revision
- (void)setRevision:(NSNumber *)revision{
    _revision = revision;
}

// ClassID
- (void)setClassID:(NSNumber *)classID{
    _classID = classID;
}

// SubclassID
- (void)setSubClassID:(NSNumber *)subClassID{
    _subClassID = subClassID;
}


// Name
- (void)setName:(NSString *)name{
    _name = name;
}


// Transparent Eligibile
- (void)setTransparentEligible:(NSNumber *)transparentEligible{
    _transparentEligible = transparentEligible;
}

// High entropy authentication
- (void)setHighEntropyAuthenticator:(NSNumber *)highEntropyAuthenticator{
    _highEntropyAuthenticator = highEntropyAuthenticator;
}

// Partial weight
- (void)setPartialWeight:(NSNumber *)partialWeight{
    _partialWeight = partialWeight;
}

// Weight
- (void)setWeight:(NSNumber *)weight{
    _weight = weight;
}

//DNEPenalty
- (void)setDnePenalty:(NSNumber *)dnePenalty{
    _dnePenalty = dnePenalty;
}

//LearnMode
- (void)setLearnMode:(NSNumber *)learnMode{
    _learnMode = learnMode;
}

// LearnTime
- (void)setLearnTime:(NSNumber *)learnTime{
    _learnTime = learnTime;
}

// LearnAssertionCount
- (void)setLearnAssertionCount:(NSNumber *)learnAssertionCount{
    _learnAssertionCount = learnAssertionCount;
}

// LearnRunCount
- (void)setLearnRunCount:(NSNumber *)learnRunCount{
    _learnRunCount = learnRunCount;
}


// Decay Mode
- (void)setDecayMode:(NSNumber *)decayMode{
    _decayMetric= decayMode;
}

// Decay Metric
- (void)setDecayMetric:(NSNumber *)decayMetric{
    _decayMetric = decayMetric;
}

// Dispatch
- (void)setDispatch:(NSString *)dispatch{
    _dispatch = dispatch;
}

// Implementation
- (void)setImplementation:(NSString *)implementation{
    _implementation = implementation;
}


// Whitelistable
- (void)setWhitelistable:(NSNumber *)whitelistable{
    _whitelistable = whitelistable;
}

// PrivateAPI
- (void)setPrivateAPI:(NSNumber *)privateAPI{
    _privateAPI = privateAPI;
}

// Payload
- (void)setPayload:(NSArray *)payload{
    _payload = payload;
}

// WipeOnUpdate
- (void)setWipeOnUpdate:(NSNumber *)wipeOnUpdate{
    _wipeOnUpdate = wipeOnUpdate;
}

@end
