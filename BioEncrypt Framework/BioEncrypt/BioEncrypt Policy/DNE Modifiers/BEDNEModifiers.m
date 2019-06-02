//
//  DNEModifiers.m
//  SenTest
//
//  Created by Nick Kramer on 1/31/15.
//

#import "BEDNEModifiers.h"

@implementation BEDNEModifiers

// Unauthorized
- (void)setUnauthorized:(NSNumber *)unauthorized{
    _unauthorized = unauthorized;
}

// Unsupported
- (void)setUnsupported:(NSNumber *)unsupported{
    _unsupported = unsupported;
}

// Unavailable
- (void)setUnavailable:(NSNumber *)unavailable{
    _unavailable = unavailable;
}

// Disabled
- (void)setDisabled:(NSNumber *)disabled{
    _disabled = disabled;
}

// Expired
- (void)setExpired:(NSNumber *)expired{
    _expired = expired;
}

//Error
- (void)setError:(NSNumber *)error{
    _error = error;
}

//noData
- (void)setNoData:(NSNumber *)noData{
    _noData = noData;
}

//Error
- (void)setInvalid:(NSNumber *)invalid{
    _invalid = invalid;
}



@end
