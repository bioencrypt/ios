//
//  BEClassification+Computation.h
//  BioEncrypt
//
//

#import "BEClassification.h"

@interface BEClassification (Computation)

// Link subclasses and trustfactors from the policy to this classification (these are static from the policy)
@property (nonatomic,retain) NSArray *subClassifications;
@property (nonatomic,retain) NSArray *trustFactors;

// populated trustFactorOutputObjects that need whitelisting if this classification is deemed attributing to a threshold violation
@property (nonatomic,retain) NSArray *trustFactorsToWhitelist;

// populated trustFactorOutputObjects that could be used for transparent authentication if transparent auth is attempted
@property (nonatomic,retain) NSArray *trustFactorsForTransparentAuthentication;

// Lists of trustFactorOutputObjects used for debug purposes
@property (nonatomic,retain) NSArray *trustFactorsNotLearned;
@property (nonatomic,retain) NSArray *trustFactorsTriggered;
@property (nonatomic,retain) NSArray *trustFactorsWithErrors;

// Weight (not used anymore, but left in code)
@property (nonatomic) NSInteger score;

// GUI subclass objects for display
@property (nonatomic,retain) NSArray *subClassResultObjects;

// GUI subclass issues for display or runHistory
@property (nonatomic,retain) NSArray *trustFactorIssues;

// GUI subclass suggestions for display or runHistory
@property (nonatomic,retain) NSArray *trustFactorSuggestions;



@end
