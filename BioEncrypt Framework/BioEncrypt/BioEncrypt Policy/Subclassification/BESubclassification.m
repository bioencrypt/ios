//
//  BESubclassification.m
//  SenTest
//
//  Created by Walid Javed on 2/4/15.
//

#import "BESubclassification.h"

@implementation BESubclassification

// Identification
- (void)setIdentification:(NSNumber *)identification{
    _identification = identification;
}

// Name
- (void)setName:(NSString *)name{
    _name = name;
}

// Icon ID
- (void)setIconID:(NSNumber *)iconID{
    _iconID = iconID;
}
// GUI explanation text
- (void)setExplanation:(NSString *)explanation{
    _explanation = explanation;
}

// GUI suggestion text
- (void)setSuggestion:(NSString *)suggestion{
    _suggestion = suggestion;
}
// dneUnauthorized
- (void)setDneUnauthorized:(NSString *)dneUnauthorized{
    _dneUnauthorized = dneUnauthorized;
}

// dneUnsupported
- (void)setDneUnsupported:(NSString *)dneUnsupported{
    _dneUnsupported = dneUnsupported;
}

// dneUnavailable
- (void)setDneUnavailable:(NSString *)dneUnavailable{
    _dneUnavailable = dneUnavailable;
}

// dneDisabled
- (void)setDneDisabled:(NSString *)dneDisabled{
    _dneDisabled = dneDisabled;
}

// dneNoData
- (void)setDneNoData:(NSString *)dneNoData{
    _dneNoData = dneNoData;
}

// dneExpired
- (void)setDneExpired:(NSString *)dneExpired{
    _dneExpired = dneExpired;
    
}

// dneExpired
- (void)setDneInvalid:(NSString *)dneInvalid{
    _dneInvalid = dneInvalid;
}
// Weight
- (void)setWeight:(NSNumber *)weight{
    _weight = weight;
}

@end
