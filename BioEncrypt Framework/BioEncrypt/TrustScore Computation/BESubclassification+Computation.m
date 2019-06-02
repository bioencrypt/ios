//
//  BESubclassification+Computation.m
//  BioEncrypt
//
//

#import "BESubclassification+Computation.h"

// Import the objc runtime
#import <objc/runtime.h>

@implementation BESubclassification (Computation)
NSString const *totalScoreKey = @"BioEncrypt.score";
NSString const *totalPossibleScoreKey = @"BioEncrypt.totalPossibleScore";
NSString const *subClassificationsKey = @"BioEncrypt.subClassifications";
NSString const *trustFactorsKey = @"BioEncrypt.trustFactors";

// Subclass Score

- (void)setScore:(NSInteger)score {
    NSNumber *totalScore = [NSNumber numberWithInteger:score];
    objc_setAssociatedObject(self, &totalScoreKey, totalScore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)score {
    NSNumber *totalScore = objc_getAssociatedObject(self, &totalScoreKey);
    return [totalScore integerValue];
}

// Subclass Total Possible Score

- (void)setTotalPossibleScore:(NSInteger)totalPossibleScore {
    NSNumber *totalPossible = [NSNumber numberWithInteger:totalPossibleScore];
    objc_setAssociatedObject(self, &totalPossibleScoreKey, totalPossible, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)totalPossibleScore {
    NSNumber *totalPossibleScore = objc_getAssociatedObject(self, &totalPossibleScoreKey);
    return [totalPossibleScore integerValue];
}


// TrustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKey, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKey);
}

@end
