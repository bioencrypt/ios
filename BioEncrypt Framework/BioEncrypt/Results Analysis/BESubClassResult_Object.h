//
//  BESubClassResult_Object.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>

@interface BESubClassResult_Object : NSObject

// Parent class ID (for backend server reference)
@property (nonatomic, assign) NSInteger classID;

// Parent subclass ID (for backend server reference)
@property (nonatomic, assign) NSInteger subClassID;

// Stored error codes for translation
@property (nonatomic, retain) NSArray* errorCodes;

// Total possible score
@property (nonatomic, assign) NSInteger totalPossibleScore;

// Total actual score
@property (nonatomic, assign) NSInteger totalScore;

// Trust percent (out of 100)
@property (nonatomic, assign) NSInteger trustPercent;

// Subclass GUI title text
@property (nonatomic, retain) NSString *subClassTitle;

// Subclass GUI Icon ID
@property (nonatomic, assign) NSInteger subClassIconID;

// Subclass GUI status text
@property (nonatomic, retain) NSString *subClassStatusText;

// Subclass GUI explanation
@property (nonatomic, retain) NSString *subClassExplanation;

// Subclass GUI suggestion
@property (nonatomic, retain) NSString *subClassSuggestion;

// TrustFactor issues in subClass
@property (nonatomic, retain) NSArray* trustFactorIssuesInSubClass;

// TrustFactor suggestions in subClass
@property (nonatomic, retain) NSArray* trustFactorSuggestionInSubClass;

@end
