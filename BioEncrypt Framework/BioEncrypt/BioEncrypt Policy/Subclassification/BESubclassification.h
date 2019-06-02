//
//  BESubclassification.h
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//

#import <Foundation/Foundation.h>

@interface BESubclassification : NSObject

@property (nonatomic, retain) NSNumber *identification;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *iconID;
@property (nonatomic, retain) NSString *explanation;
@property (nonatomic, retain) NSString *suggestion;
@property (nonatomic, retain) NSString *dneUnauthorized;
@property (nonatomic, retain) NSString *dneUnsupported;
@property (nonatomic, retain) NSString *dneUnavailable;
@property (nonatomic, retain) NSString *dneDisabled;
@property (nonatomic, retain) NSString *dneNoData;
@property (nonatomic, retain) NSString *dneExpired;
@property (nonatomic, retain) NSString *dneInvalid;
@property (nonatomic, retain) NSNumber *weight;

@end
