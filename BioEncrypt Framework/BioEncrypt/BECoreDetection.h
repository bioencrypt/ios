//
//  CoreDetection.h


/*!
 *  Core Detection is the main class of BioEncrypt (accessed by singleton) that combines all information about gathered by the checks, including: parsing the policy, running the policy, computing the output, and providing output about the checks.
 */

@import UIKit;
#import <Foundation/Foundation.h>


// TrustScore Computation
#import "BETrustScoreComputation.h"

//permissions
#import "BEPermissionRequest.h"

#import "BEStartup.h"




typedef enum {
    CoreDetectionRequirement_LocationPermission = 0,
    CoreDetectionRequirement_ActivityPermission,
    CoreDetectionRequirement_PasswordSetUp,
    CoreDetectionRequirement_BiometricsApproval,
    CoreDetectionRequirement_FinishedInitialisation
} CoreDetectionRequirement;

typedef enum {
    BiometricResultType_Error = 0,
    BiometricResultType_Success,
    BiometricResultType_UserCanceled,
    BiometricResultType_FailedAuth,
    BiometricResultType_DuplicateItem,
    BiometricResultType_ItemNotFound
    
} BiometricResultType;

@protocol CoreDetectionDelegate <NSObject>

- (void) coreDetectionRequires: (CoreDetectionRequirement ) requirement;

@end


@interface BECoreDetection : NSObject

/*!
 *  Shared Instance of Core Detection - Singleton pattern to avoid running multiple concurrent checks
 *
 *  @return CoreDetection
 */
+ (BECoreDetection *)sharedDetection;


#pragma mark - Core Detection

/*!
 *  CoreDetectionBlock is used as the callback block for CoreDetection
 *
 *  @param success            Identifies whether Core Detection succeeded in computing the results or not
 *  @param computationResults TrustScoreComputation object that gives more information about the computation results
 *  @param error              Error gives more information about the computation and what happened during computation
 */
typedef void (^coreDetectionBlock)(BOOL success, BETrustScoreComputation *computationResults, NSError *error);

typedef void (^BiometricBlock)(BiometricResultType biometricResult, NSError *error);



/*!
 *  Perform Core Detection with a policy object and get the block callback when it completes
 *
 *  @param callback CoreDetectionBlock
 *  @warning TODO: Change the way errors are passed
 */
- (void)performCoreDetectionWithCallback:(coreDetectionBlock)callback;


- (void) initializeCoreDetectionFromViewController: (UIViewController *) viewController error: (NSError **) error;

- (void) acceptActivityPermission:(BOOL) accept;
- (void) acceptLocationPermission:(BOOL) accept;
- (void) setUpPassword: (NSString *) password withError: (NSError **) error;
- (void) enableBiometrics: (BOOL) enable withError: (NSError **) error;


- (void) tryToLoginWithBiometricMessage: (NSString *) message callback: (BiometricBlock) callback;

- (void) tryToLoginWithPassword: (NSString *) passwordAttempt callback: (coreDetectionBlock) callback;

- (BOOL) isInitialisationFinished;

- (void) resetStoreAndStartupWithError: (NSError **) error;


/*!
 *  Get the last computation results
 *
 *  @return TrustScoreComputation object
 */
- (BETrustScoreComputation *)getLastComputationResults;


- (BEPolicy *) getCurrentPolicyWithError: (NSError **) error;

- (BEStartup *) getStartupError: (NSError **) error;


- (BOOL) faceIDAvailable;

#pragma mark - Properties

/*!
 *  Get/set the current computation results
 */
@property (atomic, retain) BETrustScoreComputation *computationResults;

@property (nonatomic, weak) id <CoreDetectionDelegate> delegate;

@end
