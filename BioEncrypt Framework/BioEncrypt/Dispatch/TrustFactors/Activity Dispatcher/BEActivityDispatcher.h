//
//  BEActivityDispatcher.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>

// Location
#import <CoreLocation/CoreLocation.h>

// Motion
#import <CoreMotion/CoreMotion.h>

// BLE Bluetotoh
#import <CoreBluetooth/CoreBluetooth.h>



@interface BEActivityDispatcher : NSObject <CLLocationManagerDelegate,  CBCentralManagerDelegate> {
    
    // Gryo information
    NSMutableArray *pitchRollArray;
    NSMutableArray *gyroRadsArray;
    NSMutableArray *accelRadsArray;
    NSMutableArray *headingsArray;
    
    // Magnetometer
    NSMutableArray *magneticHeadingArray;
    
    
    // Bluetooth Manager
    CBCentralManager *mgr;
    CFAbsoluteTime startTime;
    
    // Bluetooth Devices
    NSMutableArray *discoveredBLEDevices;
    NSMutableArray *connectedBLEDevices;
    NSMutableArray *connectedClassicBTDevices;
    
    // complete motion object (because we need lot of data from inside)
    NSMutableArray *motionArray;
    
}

// Location manager
@property (strong, atomic) CLLocationManager *locationManager;

// Kick off all Core Detection Activities
- (void)runCoreDetectionActivities;

// Start Bluetooth
- (void)startBluetooth;

// Start location
- (void)startLocation;

// Start Activity
- (void)startActivity;

// Start Motion
- (void)startMotion;

// Start Motion
- (void)startNetstat;

@end
