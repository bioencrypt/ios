//
//  BEPolicyParser.h
//  BioEncrypt
//
//

/*!
 *  BioEncrypt parser analyzes the plist given and puts it into our policy.
 *
 */

#import <Foundation/Foundation.h>
#import "BEPolicy.h"

@interface BEPolicyParser : NSObject

// Singleton instance
+ (id)sharedPolicy;

@property (atomic,retain) BEPolicy *currentPolicy;

/* Getter */
// Get the policy file
- (BEPolicy *)getPolicy:(NSError **)error;

/* Setter */
// Set new policy file to be ready for next run
- (BOOL)saveNewPolicy:(BEPolicy *)policy withError:(NSError **)error;

/* Helper */
// Parse a policy jsonObject
- (BEPolicy *)parsePolicyJSONobject:(NSDictionary *) jsonParsed withError:(NSError **)error;

// manually get policy from the bundle
- (BEPolicy *)loadPolicyFromMainBundle:(NSError **) error;

//remove any downloaded policy
- (void) removePolicyFromDocuments: (NSError **) error;

@end
