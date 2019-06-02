//
//  BEClassification+Computation.m
//  BioEncrypt
//
//

#import "BEClassification+Computation.h"

// Import the objc runtime
#import <objc/runtime.h>

@implementation BEClassification (Computation)

NSString const *scoreKeyClass = @"BioEncrypt.score";
NSString const *subClassificationsKeyClass = @"BioEncrypt.subClassifications";
NSString const *trustFactorsKeyClass = @"BioEncrypt.trustFactors";

// ProtectMode
NSString const *trustFactorsToWhitelistKey = @"BioEncrypt.trustFactorsToWhitelist";

// Transparent Auth
NSString const *trustFactorsForTransparentAuthenticationKey = @"BioEncrypt.trustFactorsForTransparentAuthentication";

// Debug
NSString const *trustFactorsTriggeredKey = @"BioEncrypt.trustFactorsTriggered";
NSString const *trustFactorsNotLearnedKey = @"BioEncrypt.trustFactorsNotLearned";
NSString const *trustFactorsWithErrorsKey = @"BioEncrypt.trustFactorsWithErrors";
NSString const *trustFactorsIssuesKey = @"BioEncrypt.trustFactorIssues";
NSString const *trustFactorsSuggestionsKey = @"BioEncrypt.trustFactorSuggestions";
NSString const *trustFactorsStatusKey = @"BioEncrypt.trustFactorStatus";

// GUI messages
NSString const *subClassResultObjectsKey = @"BioEncrypt.subClassResultObjects";

// Issues/Suggestions
NSString const *trustFactorIssuesKey = @"BioEncrypt.trustFactorIssuesKey";
NSString const *trustFactorSuggestionsKey = @"BioEncrypt.trustFactorSuggestionsKey";



// Classification score

- (void)setScore:(NSInteger)score {
    NSNumber *scoreNumber = [NSNumber numberWithInteger:score];
    objc_setAssociatedObject(self, &scoreKeyClass, scoreNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)score {
    NSNumber *scoreNumber = objc_getAssociatedObject(self, &scoreKeyClass);
    return [scoreNumber integerValue];
}

// Subclassifications

- (void)setSubClassifications:(NSArray *)subClassifications {
    objc_setAssociatedObject(self, &subClassificationsKeyClass, subClassifications, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)subClassifications {
    return objc_getAssociatedObject(self, &subClassificationsKeyClass);
}

// TrustFactors

- (void)setTrustFactors:(NSArray *)trustFactors {
    objc_setAssociatedObject(self, &trustFactorsKeyClass, trustFactors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactors {
    return objc_getAssociatedObject(self, &trustFactorsKeyClass);
}

// TrustFactors for transparent authentication

- (void)setTrustFactorsForTransparentAuthentication:(NSArray *)trustFactorsForTransparentAuthentication{
    objc_setAssociatedObject(self, &trustFactorsForTransparentAuthenticationKey, trustFactorsForTransparentAuthentication, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsForTransparentAuthentication {
    return objc_getAssociatedObject(self, &trustFactorsForTransparentAuthenticationKey);
}

// TrustFactors to whitelist during protect mode deactivation

- (void)setTrustFactorsToWhitelist:(NSArray *)trustFactorsToWhitelist{
    objc_setAssociatedObject(self, &trustFactorsToWhitelistKey, trustFactorsToWhitelist, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsToWhitelist {
    return objc_getAssociatedObject(self, &trustFactorsToWhitelistKey);
}

// TrustFactors that are triggered during tests
- (void)setTrustFactorsTriggered:(NSArray *)trustFactorsTriggered{
    objc_setAssociatedObject(self, &trustFactorsTriggeredKey, trustFactorsTriggered, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsTriggered {
    return objc_getAssociatedObject(self, &trustFactorsTriggeredKey);
}

// TrustFactors that have not been learned yet by assertion
- (void)setTrustFactorsNotLearned:(NSArray *)trustFactorsNotLearned{
    objc_setAssociatedObject(self, &trustFactorsNotLearnedKey, trustFactorsNotLearned, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsNotLearned {
    return objc_getAssociatedObject(self, &trustFactorsNotLearnedKey);
}

// TrustFactors with error checking
- (void)setTrustFactorsWithErrors:(NSArray *)trustFactorsWithErrors{
    objc_setAssociatedObject(self, &trustFactorsWithErrorsKey, trustFactorsWithErrors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorsWithErrors {
    return objc_getAssociatedObject(self, &trustFactorsWithErrorsKey);
}


// SubClassResultObjects, one object per subclass that is used within this class
- (void)setSubClassResultObjects:(NSArray *)subClassResultObjects{
    objc_setAssociatedObject(self, &subClassResultObjectsKey, subClassResultObjects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)subClassResultObjects {
    return objc_getAssociatedObject(self, &subClassResultObjectsKey);
}

// TrustFactor Issues
- (void)setTrustFactorIssues:(NSArray *)trustFactorIssues{
    objc_setAssociatedObject(self, &trustFactorIssuesKey, trustFactorIssues, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorIssues {
    return objc_getAssociatedObject(self, &trustFactorIssuesKey);
}

// TrustFactor Suggestions
- (void)setTrustFactorSuggestions:(NSArray *)trustFactorSuggestions{
    objc_setAssociatedObject(self, &trustFactorSuggestionsKey, trustFactorSuggestions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)trustFactorSuggestions {
    return objc_getAssociatedObject(self, &trustFactorSuggestionsKey);
}




@end
