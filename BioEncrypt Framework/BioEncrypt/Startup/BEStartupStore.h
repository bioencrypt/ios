//
//  BEStartupStore.h
//  BioEncrypt
//
//  Created by Kramer on 2/18/16.
//

#import <Foundation/Foundation.h>

// Startup file
#import "BEStartup.h"

// Run History Object
#import "BEHistoryObject.h"

// Transparent Auth Object
#import "BETransparentAuth_Object.h"

// Core Detection
#import "BECoreDetection.h"

// TrustScore Computation
@class BETrustScoreComputation;

@interface BEStartupStore : NSObject

// Singleton instance
+ (id)sharedStartupStore;

/* Properties */

// Current state
@property (nonatomic,retain) NSString *currentState;
// Current startup store
@property (nonatomic,retain) BEStartup *currentStartupStore;

/* Getter */
// Get the startup file
- (BEStartup *)getStartupStore:(NSError **)error;


/* Setter */
// Set the startup file
- (BOOL)setStartupStoreWithError:(NSError **)error;

/* Getter */
// Set the run history object
- (void)setStartupFileWithComputationResult:(BETrustScoreComputation *)computationResults withError:(NSError **)error;

/* Helper */
// Startup File Path
- (NSString *)startupFilePath;

// Create a new startup file (first time)
- (void) createNewStartupFileWithError:(NSError **)error;

// first update startup with password, returns masterKeyString
- (NSString *) updateStartupFileWithPassoword: (NSString *)password withError:(NSError **)error;
- (void) updateStartupFileWithBiometricPassoword: (NSString *)password masterKey: (NSData *) decryptedMasterKey withError:(NSError **)error;


- (void) updateStartupFileWithEmail:(NSString *)email withError:(NSError **)error;

// Reset Startup Store (remove startup file if exists, reset local attributes)
- (void) resetStartupStoreWithError: (NSError **) error;


@end
