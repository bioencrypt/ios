//
//  BETrustFactorDatasets.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Datasets is designed to cache the results between the TrustFactor Dispatch Rule and
 *  BioEncrypt TrustFactor Dataset Category.
 */

// Constants
#import "BEConstants.h"

// Dataset Imports
#import <CoreMotion/CoreMotion.h>
@import CoreLocation;

// System Frameworks
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Helper class headers



@interface BETrustFactorDatasets : NSObject

#pragma mark - Singleton

// Singleton instance
+ (id)sharedDatasets;

// Singleton self-destruct (for demo)
+ (void)selfDestruct;

#pragma mark - Properties

// Device Configuration
@property (atomic, retain) NSNumber *hasPassword;

// Status bar
@property (atomic, retain) NSDictionary *statusBar;
@property (atomic) int statusBarDNEStatus;

//Location
@property (atomic, retain) CLLocation *location;
@property (atomic) int locationDNEStatus;

@property (atomic, retain) CLPlacemark *placemark;
@property (atomic) int placemarkDNEStatus;


// Magnetometer
@property (atomic, strong) NSArray *magneticHeading;
@property (atomic) int magneticHeadingDNEStatus;


// Activity
@property (atomic, retain) NSArray *previousActivities;
@property (atomic) int activityDNEStatus;

// Motion datasets (requires processing)
@property (atomic, retain) NSArray *gyroRollPitch;
@property (atomic, retain) NSArray *gyroRads;
@property (atomic) int gyroMotionDNEStatus;

@property (atomic, retain) NSArray *accelRads;
@property (atomic) int accelMotionDNEStatus;

@property (atomic, retain) NSArray *userMovementInfo;
@property (atomic) int userMovementDNEStatus;

// Motion results (post processing)
@property (atomic,retain) NSString *deviceOrientation;
@property (atomic, retain) NSString *userMovement;
@property (atomic, retain) NSNumber *gripMovement;

// Bluetooth BLE
@property (atomic, retain) NSArray *discoveredBLEDevices;
@property (atomic) int discoveredBLESDNEStatus;
@property (atomic, retain) NSArray *connectedBLEDevices;
@property (atomic) int connectedBLESDNEStatus;

// Bluetooth Classic
@property (atomic, retain) NSArray *connectedClassicBTDevices;
@property (atomic) int connectedClassicDNEStatus;

// WiFi
@property (atomic, retain) NSNumber *wifiEnabled;
@property (atomic, retain) NSDictionary *wifiData;
@property (atomic) int wifiConnected;
@property (atomic, retain) NSNumber *wifiSignal;
@property (atomic, retain) NSArray *wifiEncryption;


//Celluar
@property (atomic, retain) NSNumber *celluarSignalRaw;
@property (atomic, retain) NSString *carrierConnectionName;
@property (atomic, retain) NSString *carrierConnectionSpeed;
@property (atomic, retain) NSNumber *airplaneMode;
@property (atomic, retain) NSNumber *tethering;

// CPU
@property (atomic) float cpuUsage;

// Battery
@property (atomic, retain) NSString *batteryState;

// Time of day
@property (atomic) NSInteger hourOfDay;
@property (atomic) NSInteger dayOfWeek;
@property (nonatomic) NSInteger runTimeEpoch;

// App Info
@property (atomic, retain) NSArray *installedApps;

// Process Info
@property (atomic, retain) NSArray *runningProcesses;
@property (atomic, retain) NSNumber *ourPID;

// Routing Info
@property (atomic, retain) NSArray *networkRoutes;

// Interface Info
@property (atomic, retain) NSDictionary *interfaceBytes;

// Netstat Info
@property (atomic, retain) NSArray *netstatData;
@property (atomic) int netstatDataDNEStatus;

#pragma mark - Dataset methods

// Validate the given payload
- (BOOL)validatePayload:(NSArray *)payload;


// ** Device Config **
- (NSNumber *) getPassword;

// ** Status Bar **
- (NSDictionary *)getStatusBar;

// ** CPU **
- (float)getCPUUsage;

// ** BATTERY **
- (NSString *)getBatteryState;

// ** TIME **
- (NSString *)getTimeDateStringWithHourBlockSize:(NSInteger)blockSize withDayOfWeek:(BOOL)day;

// ** APPS **
- (NSArray *)getInstalledAppInfo;

// ** PROCESS **
- (NSArray *)getProcessInfo;
- (NSNumber *) getOurPID;

// ** ROUTE **
- (NSArray *)getRouteInfo;

// ** WIFI **
- (NSDictionary *)getWifiInfo;
- (NSNumber *)isWifiEnabled;
- (NSNumber *) getWifiSignal;
- (NSNumber *)isTethering;
- (NSArray *) getWifiEncryption;

// ** CELLUAR **
- (NSNumber *) getCelluarSignalRaw;
- (NSString *) getCarrierConnectionName;
- (NSString *) getCarrierConnectionSpeed;
- (NSNumber *) isAirplaneMode;

// ** NETWORKING **
- (NSArray *) getNetstatInfo;
- (NSDictionary *)getDataXferInfo;

// ** LOCATION **
- (CLLocation *)getLocationInfo;
- (CLPlacemark *)getPlacemarkInfo;
- (NSArray *)getMagneticHeadingsInfo;

// ** ACTIVITIES **
- (NSArray *)getPreviousActivityInfo;

// ** MOTION **

// Holds the datasets needed for processing
- (NSArray *)getGyroRadsInfo;
- (NSArray *)getUserMovementInfo;
- (NSArray *)getAccelRadsInfo;
- (NSArray *)getGyroPitchInfo;
//TODO: - (NSArray *)getHeadingsInfo;

// Holds the result of post-processing
- (NSString *)getDeviceOrientation;
- (NSNumber *)getGripMovement;
- (NSString *)getUserMovement;

// ** BLUETOOTH **
- (NSArray *)getDiscoveredBLEInfo;
- (NSArray *)getConnectedBLEInfo;
- (NSArray *)getClassicBTInfo;

@end
