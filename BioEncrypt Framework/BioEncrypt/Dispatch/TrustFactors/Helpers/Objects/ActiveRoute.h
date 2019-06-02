//
//  ActiveConnection.h
//  System Monitor
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2013 Arvydas Sidorenko
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ActiveRoute : NSObject
@property (nonatomic, copy) NSString              *interface;
@property (nonatomic) BOOL                        isDefault;
@property (nonatomic, copy) NSString              *gateway;

@end
