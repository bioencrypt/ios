//
//  JYJSONResponseSerializer.h
//  Jealousy
//
//  Created by Ivo Leko on 15/02/16.
//

#import "AFURLResponseSerialization.h"

static NSString * const BioEncryptServerErrorMessage = @"BioEncryptServerErrorMessage";
static NSString * const BioEncryptServerDeveloperErrorMessage = @"BioEncryptServerDeveloperErrorMessage";
static NSString * const BioEncryptServerCustomErrorCode = @"BioEncryptServerCustomErrorCode";

@interface BEJSONResponseSerializer : AFJSONResponseSerializer

@end
