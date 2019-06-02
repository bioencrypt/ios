//
//  BETrustFactorDispatch_Bluetooth.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_Bluetooth.h"

// Private APIs
//#import "BluetoothManager.h"
//#import "BluetoothDevice.h"

@implementation BETrustFactorDispatch_Bluetooth

// Check which classic bluetooth devices are connected
+ (BETrustFactorOutputObject *)connectedClassicDevice:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];

    
    // Check if error was determined by BT callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  connectedClassicDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  connectedClassicDNEStatus] != DNEStatus_expired ){
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  connectedClassicDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Try to get current bluetooth devices
    NSArray *bluetoothDevices = [[BETrustFactorDatasets sharedDatasets] getClassicBTInfo];
    
    // Check if error was determined after call to dataset helper (e.g., timer expired)
    if ([[BETrustFactorDatasets sharedDatasets]  connectedClassicDNEStatus] != DNEStatus_ok ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  connectedClassicDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check the array
    if (!bluetoothDevices || bluetoothDevices == nil || bluetoothDevices.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all found devices information
    for (NSString *mac in bluetoothDevices) {
        
        [outputArray addObject:mac];
    }

    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

// Check connected BLE devices
+ (BETrustFactorOutputObject *)connectedBLEDevice:(NSArray *)payload {
    
    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Check if error was determined by BT callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  connectedBLESDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  connectedBLESDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  connectedBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Try to get current bluetooth devices
    NSArray *bluetoothDevices = [[BETrustFactorDatasets sharedDatasets]  getConnectedBLEInfo];
    
    // Check if error was determined after call to dataset helper (e.g., timer expired)
    if ([[BETrustFactorDatasets sharedDatasets]  connectedBLESDNEStatus] != DNEStatus_ok){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  connectedBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Check the array
    if (!bluetoothDevices || bluetoothDevices == nil || bluetoothDevices.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all found devices information
    for (NSString *deviceUUID in bluetoothDevices) {
        
        [outputArray addObject:deviceUUID];
    }
    
    
    // Modified to only use the first one as this is likely the fastest responder all the time
    //[outputArray addObject:[bluetoothDevices objectAtIndex:0]];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
}



// Check which BLE devices get discovered
+ (BETrustFactorOutputObject *)discoveredBLEDevice:(NSArray *)payload {

    // Create the trustfactor output object
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] initWithCapacity:payload.count];
    
    // Check if error was determined by BT callback in app delegate, except expired, if it expired during a previous TF we still want to try again
    
    if ([[BETrustFactorDatasets sharedDatasets]  discoveredBLESDNEStatus] != DNEStatus_ok && [[BETrustFactorDatasets sharedDatasets]  discoveredBLESDNEStatus] != DNEStatus_expired ){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  discoveredBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    // Try to get current bluetooth devices
    NSArray *bluetoothDevices = [[BETrustFactorDatasets sharedDatasets]  getDiscoveredBLEInfo];
    
    // Check if error was determined after call to dataset helper (e.g., timer expired)
    if ([[BETrustFactorDatasets sharedDatasets]  discoveredBLESDNEStatus] != DNEStatus_ok){
        
        // Set the DNE status code to what was previously determined
        [trustFactorOutputObject setStatusCode:[[BETrustFactorDatasets sharedDatasets]  discoveredBLESDNEStatus]];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }

    // Check the array
    if (!bluetoothDevices || bluetoothDevices == nil || bluetoothDevices.count < 1) {
        // Current Processes array is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_nodata];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    // Run through all found devices information
    for (NSString *deviceUUID in bluetoothDevices) {
        
        [outputArray addObject:deviceUUID];
    }

    
    // Modified to only use the first one as this is likely the fastest responder all the time
    //[outputArray addObject:[bluetoothDevices objectAtIndex:0]];
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    // Return the trustfactor output object
    return trustFactorOutputObject;
    
}

@end
