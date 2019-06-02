//
//  BETrustFactorDispatch_Bluetooth.h
//  BioEncrypt
//
//

/*!
 *  TrustFactor Dispatch Bluetooth is a rule that determines which classic bluetooth and BLE devices
 *  are connected to the user's phone.
 */

#import "BETrustFactorDatasets.h"
#import "BETrustFactorOutputObject.h"

@interface BETrustFactorDispatch_Bluetooth : NSObject

// Discovered BLE devices
+ (BETrustFactorOutputObject *)discoveredBLEDevice:(NSArray *)payload;

// Connected BLE devices
+ (BETrustFactorOutputObject *)connectedBLEDevice:(NSArray *)payload;

// Connected classic bluetooth devices
+ (BETrustFactorOutputObject *)connectedClassicDevice:(NSArray *)payload;

@end
