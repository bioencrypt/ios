//
//  UserDeviceInformationViewController.h
//  BioEncrypt
//
//  Created by Ivo Leko on 24/11/16.
//

#import "BaseViewController.h"

typedef enum {
    InformationTypeUser = 0,
    InformationTypeDevice
} InformationType;

@interface UserDeviceInformationViewController : BaseViewController

@property (nonatomic, strong) NSArray *arrayOfSubClassResults;
@property (nonatomic) InformationType informationType;

@end
