//
//  MDBluetoothDevice.m
//  BeeTee
//
//  Created by Michael Dorner on 02.01.15.
//  Copyright (c) 2015 Michael Dorner. All rights reserved.
//

#import "MDBluetoothDevice.h"


@interface MDBluetoothDevice ()

@property (strong, nonatomic, readwrite) NSString* name;
@property (strong, nonatomic, readwrite) NSString* address;
@property (assign, nonatomic, readwrite) NSUInteger majorClass;
@property (assign, nonatomic, readwrite) NSUInteger minorClass;
@property (assign, nonatomic, readwrite) NSInteger type;
@property (assign, nonatomic, readwrite) BOOL supportsBatteryLevel;
@property (strong, nonatomic, readwrite) NSDate* detectingDate;

- (instancetype)initWithBluetoothDevice:(id)bluetoothDevice;

@end

@implementation MDBluetoothDevice

- (instancetype)initWithBluetoothDevice:(id)bluetoothDevice
{
    self = [super init];
    
    // Get the selector
    SEL selector = NSSelectorFromString(@"name");
    
    // Check if the class responds
    if ([bluetoothDevice respondsToSelector:selector]) {
        
        // call fake selector
        self.name = [NSString stringWithFormat:@"%@", [bluetoothDevice name]];
        
    }
    
    // Get the selector
    selector = NSSelectorFromString(@"address");
    
    
    // Check if the class responds
    if ([bluetoothDevice respondsToSelector:selector]) {
        
        // call fake selector
        self.address = [NSString stringWithFormat:@"%@", [bluetoothDevice address]];
        

    }
    
    // Get the selector
    selector = NSSelectorFromString(@"majorClass");
    
    // Check if the class responds
    if ([bluetoothDevice respondsToSelector:selector]) {
        
        // call fake selector
        self.majorClass = [bluetoothDevice majorClass];
        
    }
    
    // Get the selector
    selector = NSSelectorFromString(@"minorClass");
    
    
    // Check if the class responds
    if ([bluetoothDevice respondsToSelector:selector]) {
        
        // call fake selector
        self.minorClass = [bluetoothDevice minorClass];
    }
    
    // Get the selector
    selector = NSSelectorFromString(@"type");
    
    
    // Check if the class responds
    if ([bluetoothDevice respondsToSelector:selector]) {
        
        // call fake selector
        self.type = [(MDBluetoothDevice *)bluetoothDevice type];
    }
    
    // Get the selector
    selector = NSSelectorFromString(@"supportsBatteryLevel");
        
    // Check if the class responds
    if ([bluetoothDevice respondsToSelector:selector]) {
        
        // call fake selector
        self.supportsBatteryLevel = [(MDBluetoothDevice *)bluetoothDevice supportsBatteryLevel];
    }
    
    self.detectingDate = [[NSDate alloc] init];

    return self;
}

- (BOOL)isEqualToBluetoothDevice:(MDBluetoothDevice*)bluetoothDevice
{
    if (!bluetoothDevice) {
        return NO;
    }
    return [self.address isEqualToString:bluetoothDevice.address];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[MDBluetoothDevice class]]) {
        return NO;
    }
    return [self isEqualToBluetoothDevice:object];
}

- (NSUInteger)hash
{
    return [self.address hash];
}

@end
