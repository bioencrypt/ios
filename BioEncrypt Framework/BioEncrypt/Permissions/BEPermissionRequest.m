//
//  BEPermissionRequest.m
//  BioEncrypt
//
//  Created by Ivo Leko on 05/05/2019.
//

#import "BEPermissionRequest.h"

@implementation BEPermissionRequest

- (void)requestUserPermissionWithCompletionBlock: (PermissionRequestCompletionBlock)completion {
    NSAssert(NO, @"Should be overriden");
}

@end
