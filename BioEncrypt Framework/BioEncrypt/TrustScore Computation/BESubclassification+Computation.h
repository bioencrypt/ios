//
//  BESubclassification+Computation.h
//  BioEncrypt
//
//

#import "BESubclassification.h"

@interface BESubclassification (Computation)

@property (nonatomic,retain) NSArray *trustFactors;
@property (nonatomic) NSInteger score;
@property (nonatomic) NSInteger totalPossibleScore;

@end
