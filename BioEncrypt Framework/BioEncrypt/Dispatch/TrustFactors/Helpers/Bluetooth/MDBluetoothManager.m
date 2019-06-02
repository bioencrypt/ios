//
//  MDBluetoothManager.m
//  BeeTee
//
//  Created by Michael Dorner on 02.01.15.
//  Copyright (c) 2015 Michael Dorner. All rights reserved.
//

#import "MDBluetoothManager.h"

#import <dlfcn.h>

@interface MDBluetoothManager ()

@property (strong, nonatomic) NSMutableArray* internalDiscoveredBluetoothDevices;
@property (strong, nonatomic) NSMutableArray* observers;
@property (retain, nonatomic) id internalBluetoothManager;
@property (assign, nonatomic) BOOL scanRequested;
@property (assign, nonatomic, readwrite) BOOL isScanning;

- (void)bluetoothPowerChanged:(NSNotification*)notification;
- (void)bluetoothAvailabilityChanged:(NSNotification*)notification;
- (void)bluetoothDeviceDiscovered:(NSNotification*)notification;
- (void)bluetoothDeviceRemoved:(NSNotification*)notification;

- (instancetype)init;

@end

@implementation MDBluetoothManager

+ (MDBluetoothManager*)sharedInstance
{
    static MDBluetoothManager* bluetoothManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Get the bluetoothManager class from a string
        Class bluetoothManagerClass = NSClassFromString(@"BluetoothManager");
        
        // Check if the class exists
        if (bluetoothManagerClass == nil) {
            
            NSString *bluetoothLoadPath = [NSString stringWithFormat:@"/System/Library/Priv%@Manager.framework/Bluetooth%@", @"ateFrameworks/Bluetooth",@"Manager"];
            
            const char* path = [bluetoothLoadPath UTF8String];
            
            // Open the BluetoothManager private framework with dlopen
            void *handle = dlopen(path, RTLD_NOW);
            
            // Check if it was able to open
            if (handle) {
                
                // Get the class again
                bluetoothManagerClass = NSClassFromString(@"BluetoothManager");
                
                // Make sure it's valid
                assert(bluetoothManagerClass);
            }
        }
        
        // Create the bluetoothmanager class sharedInstance
        [bluetoothManagerClass sharedInstance];
        
        // Set the sharedInstance of this class
        bluetoothManager = [[MDBluetoothManager alloc] init];
    });
    
    return bluetoothManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _internalDiscoveredBluetoothDevices = [[NSMutableArray alloc] init];
        _observers = [[NSMutableArray alloc] init];
        
        // Get the bluetoothManager class from a string
        Class bluetoothManagerClass = NSClassFromString(@"BluetoothManager");
        
        // Check if the class exists
        if (bluetoothManagerClass == nil) {
            
            NSString *bluetoothLoadPath = [NSString stringWithFormat:@"/System/Library/Priv%@Manager.framework/Bluetooth%@", @"ateFrameworks/Bluetooth",@"Manager"];
            
            const char* path = [bluetoothLoadPath UTF8String];
            
            // Open the BluetoothManager private framework with dlopen
            void *handle = dlopen(path, RTLD_NOW);
            
            // Check if it was able to open
            if (handle) {
                
                // Get the class again
                bluetoothManagerClass = NSClassFromString(@"BluetoothManager");
                
                // Make sure it's valid
                assert(bluetoothManagerClass);
            }
        }
        
        // Create the bluetoothmanager class sharedInstance
        _internalBluetoothManager = [bluetoothManagerClass sharedInstance];
        
        _scanRequested = NO;
    }
    
    [self addNotification];
    
    return self;
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothPowerChanged:)
     name:@"BluetoothPowerChangedNotification"
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothAvailabilityChanged:)
     name:@"BluetoothAvailabilityChangedNotification"
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothDeviceDiscovered:)
     name:@"BluetoothDeviceDiscoveredNotification"
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(bluetoothDeviceRemoved:)
     name:@"BluetoothDeviceRemovedNotification"
     object:nil];
    
    // all available notifications belonging to BluetoothManager I could figure
    // out - not used and therefore implemented in this demo app
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(bluetoothConnectabilityChanged:)
     name:@"BluetoothConnectabilityChangedNotification" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(bluetoothDeviceUpdated:)
     name:@"BluetoothDeviceUpdatedNotification" object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(bluetoothDiscoveryStateChanged:)
     name:@"BluetoothDiscoveryStateChangedNotification" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(bluetoothDeviceDiscovered:)
     name:@"BluetoothDeviceDiscoveredNotification" object:nil];
     
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(bluetoothDeviceConnectSuccess:)
     name:@"BluetoothDeviceConnectSuccessNotification" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(bluetoothConnectionStatusChanged:)
     name:@"BluetoothConnectionStatusChangedNotification" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(bluetoothDeviceDisconnectSuccess:)
     name:@"BluetoothDeviceDisconnectSuccessNotification" object:nil];
     */
    
    // this helped me very much to figure out the methods mentioned the lines
    // above
    /*
     // credits to http://stackoverflow.com/a/3738387/1864294 :
     CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(),
     NULL,
     notificationCallback,
     NULL,
     NULL,
     CFNotificationSuspensionBehaviorDeliverImmediately);
     */
}

void notificationCallback(CFNotificationCenterRef center, void* observer,
                          CFStringRef name, const void* object,
                          CFDictionaryRef userInfo)
{
    if ([(__bridge NSString*)name characterAtIndex:0] == 'B') { // notice only notification they are associated with the
        // BluetoothManager.framework
        NSLog(@"Callback detected: \n\t name: %@ \n\t object:%@", name, object);
    }
}

#pragma mark - class methods

- (BOOL)bluetoothIsAvailable
{
    // Get the selector
    SEL selector = NSSelectorFromString(@"enabled");
    
    // Check if the class responds
    if ([_internalBluetoothManager respondsToSelector:selector]) {
        
        // Create the invocation
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
        
        // Set the selector
        [invocation setSelector:selector];
        
        // Set the target
        [invocation setTarget:_internalBluetoothManager];
        
        // Call the method
        [invocation invoke];
        
        // Get the value
        BOOL returnValue;
        
        // Get the return value
        [invocation getReturnValue:&returnValue];
        
        // Return the bool value
        return returnValue;
        
    }
    
    // Default to NO
    return NO;
}

- (void)turnBluetoothOn
{
    if (![self bluetoothIsPowered]) {
        
        // Get the selector
        SEL selector = NSSelectorFromString(@"setPowered:");
        
        // Check if the class responds
        if ([_internalBluetoothManager respondsToSelector:selector]) {
            
            // Create the invocation
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
            
            // Set the selector
            [invocation setSelector:selector];
            
            // Set the target
            [invocation setTarget:_internalBluetoothManager];
            
            // Set the argument
            BOOL funcArg = YES;
            [invocation setArgument:&funcArg atIndex:2];
            
            // Call the method
            [invocation invoke];
            
        }
    }
}

- (BOOL)bluetoothIsPowered
{
    // Get the selector
    SEL selector = NSSelectorFromString(@"powered");
    
    // Check if the class responds
    if ([_internalBluetoothManager respondsToSelector:selector]) {
        
        // Create the invocation
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
        
        // Set the selector
        [invocation setSelector:selector];
        
        // Set the target
        [invocation setTarget:_internalBluetoothManager];
        
        // Call the method
        [invocation invoke];
        
        // Get the value
        BOOL returnValue;
        
        // Get the return value
        [invocation getReturnValue:&returnValue];
        
        // Return the bool value
        return returnValue;
        
    }
    
    // Default to NO
    return NO;
}

- (void)turnBluetoothOff
{
    if ([self bluetoothIsPowered]) {
        // Get the selector
        SEL selector = NSSelectorFromString(@"setPowered:");
        
        // Check if the class responds
        if ([_internalBluetoothManager respondsToSelector:selector]) {
            
            // Create the invocation
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
            
            // Set the selector
            [invocation setSelector:selector];
            
            // Set the target
            [invocation setTarget:_internalBluetoothManager];
            
            // Set the argument
            BOOL funcArg = NO;
            [invocation setArgument:&funcArg atIndex:2];
            
            // Call the method
            [invocation invoke];
            
        }
        
        // Remove all Bluetooth devices
        [self.internalDiscoveredBluetoothDevices removeAllObjects];
    }
}

- (void)startScan
{
    if ([self bluetoothIsPowered]) {
        
        // Get the selector
        SEL selector = NSSelectorFromString(@"setDeviceScanningEnabled:");
        
        // Check if the class responds
        if ([_internalBluetoothManager respondsToSelector:selector]) {
            
            // Create the invocation
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
            
            // Set the selector
            [invocation setSelector:selector];
            
            // Set the target
            [invocation setTarget:_internalBluetoothManager];
            
            // Set the argument
            BOOL funcArg = YES;
            [invocation setArgument:&funcArg atIndex:2];
            
            // Call the method
            [invocation invoke];
            
        }
        
        // Get the selector
        selector = NSSelectorFromString(@"scanForServices:");
        
        // Check if the class responds
        if ([_internalBluetoothManager respondsToSelector:selector]) {
            
            // Create the invocation
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                        [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
            
            // Set the selector
            [invocation setSelector:selector];
            
            // Set the target
            [invocation setTarget:_internalBluetoothManager];
            
            // Set the argument
            float funcArg = 0xFFFFFFFF;
            [invocation setArgument:&funcArg atIndex:2];
            
            // Call the method
            [invocation invoke];
            
        }
        
    }
}

- (BOOL)isScanning
{
    // Get the selector
    SEL selector = NSSelectorFromString(@"deviceScanningEnabled");
    
    // Check if the class responds
    if ([_internalBluetoothManager respondsToSelector:selector]) {
        
        // Create the invocation
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
        
        // Set the selector
        [invocation setSelector:selector];
        
        // Set the target
        [invocation setTarget:_internalBluetoothManager];
        
        // Call the method
        [invocation invoke];
        
        // Get the value
        BOOL returnValue;
        
        // Get the return value
        [invocation getReturnValue:&returnValue];
        
        // Return the bool value
        return returnValue;
        
    }
    
    // Default to NO
    return NO;
}

- (void)endScan
{
    // Get the selector
    SEL selector = NSSelectorFromString(@"setDeviceScanningEnabled:");
    
    // Check if the class responds
    if ([_internalBluetoothManager respondsToSelector:selector]) {
        
        // Create the invocation
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
        
        // Set the selector
        [invocation setSelector:selector];
        
        // Set the target
        [invocation setTarget:_internalBluetoothManager];
        
        // Set the argument
        BOOL funcArg = NO;
        [invocation setArgument:&funcArg atIndex:2];
        
        // Call the method
        [invocation invoke];
        
    }
    
    [self.internalDiscoveredBluetoothDevices removeAllObjects];
}

- (NSArray*)discoveredBluetoothDevices
{
    return [self.internalDiscoveredBluetoothDevices copy]; // make it immutable
}

- (NSArray*)connectedDevices {
    
    // Get the selector
    SEL selector = NSSelectorFromString(@"connectedDevices");
    
    // Check if the class responds
    if ([_internalBluetoothManager respondsToSelector:selector]) {
        
        NSArray * __unsafe_unretained tempConnectedDevices;
        
        
        // Create the invocation
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[_internalBluetoothManager class] instanceMethodSignatureForSelector:selector]];
        
        // Set the selector
        [invocation setSelector:selector];
        
        // Set the target
        [invocation setTarget:_internalBluetoothManager];
        
        // Call the method
        [invocation invoke];
        
        // get devices
        [invocation getReturnValue:&tempConnectedDevices];
        
        NSMutableArray *arrayM = [[NSMutableArray alloc] init];
        
        for (id device in tempConnectedDevices) {
            MDBluetoothDevice *deviceB = [[MDBluetoothDevice alloc] initWithBluetoothDevice:device];
            [arrayM addObject:deviceB];
        }
        
        return [NSArray arrayWithArray:arrayM];
    }
    
    return @[];
}

#pragma mark - Observer methods

- (void)registerObserver:(id<MDBluetoothObserverProtocol>)observer
{
    [self.observers addObject:observer];
}

- (void)unregisterObserver:(id<MDBluetoothObserverProtocol>)observer
{
    [self.observers removeObject:observer];
}

#pragma mark - Bluetooth notifications

- (void)bluetoothPowerChanged:(NSNotification*)notification
{
    NSLog(@"bluetoothPowerChanged");
    
    for (id<MDBluetoothObserverProtocol> observer in [self.observers copy]) {
        if (observer) {
            [observer receivedBluetoothNotification:MDBluetoothPowerChangedNotification];
        }
    }
}

- (void)bluetoothAvailabilityChanged:(NSNotification*)notification
{
    NSLog(@"bluetoothAvailabilityChanged");
    for (id<MDBluetoothObserverProtocol> observer in [self.observers copy]) {
        if (observer) {
            [observer receivedBluetoothNotification:MDBluetoothAvailabilityChangedNotification];
        }
    }
}

- (void)bluetoothDeviceDiscovered:(NSNotification*)notification
{
    NSLog(@"bluetoothDeviceDiscovered");
    
    MDBluetoothDevice* bluetoothDevice = [[MDBluetoothDevice alloc] initWithBluetoothDevice:(id)[notification object]];
    [self.internalDiscoveredBluetoothDevices addObject:bluetoothDevice];
    
    for (id<MDBluetoothObserverProtocol> observer in [self.observers copy]) {
        if (observer) {
            [observer receivedBluetoothNotification:MDBluetoothDeviceDiscoveredNotification];
        }
    }
}

- (void)bluetoothDeviceRemoved:(NSNotification*)notification
{
    NSLog(@"bluetoothDeviceRemoved");
    MDBluetoothDevice* bluetoothDevice = [[MDBluetoothDevice alloc] initWithBluetoothDevice:(id)[notification object]];
    [self.internalDiscoveredBluetoothDevices removeObject:bluetoothDevice];
    
    for (id<MDBluetoothObserverProtocol> observer in [self.observers copy]) {
        if (observer) {
            [observer receivedBluetoothNotification:MDBluetoothDeviceRemovedNotification];
        }
    }
}

@end
