//
//  BETrustFactorStorage.h
//  BioEncrypt
//
//

#import <Foundation/Foundation.h>
#import "BEAssertionStore.h"

@interface BETrustFactorStorage : NSObject

// Singleton instance
+ (id)sharedStorage;

@property (atomic,retain) BEAssertionStore *currentStore;

// Get the assertion store
- (BEAssertionStore *)getAssertionStoreWithError:(NSError **)error;

// Set the asertion store
- (void)setAssertionStoreWithError:(NSError **)error;

// Assertion Store File Path
- (NSString *)assertionStoreFilePath;

// reset assertion store
- (void) resetAssertionStoreWithError: (NSError **) error;

// Store Path
@property (atomic,strong) NSString *storePath;

@end
