//
//  BETrustFactorDispatchBioEncrypt.m
//  BioEncrypt
//
//

#import "BETrustFactorDispatch_BioEncrypt.h"
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#include <CommonCrypto/CommonCrypto.h>
#include <objc/objc.h>
#include <objc/runtime.h>
#include <stdio.h>
#include <string.h>

@implementation BETrustFactorDispatch_BioEncrypt

#define sysCtlSz(nm,cnt,sz)   sysctl((int *)nm,cnt,NULL,sz,NULL,0)
#define sysCtl(nm,cnt,lst,sz) sysctl((int *)nm,cnt,lst, sz,NULL,0)

#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21
struct encryption_info_command
{
    uint32_t cmd;
    uint32_t cmdsize;
    uint32_t cryptoff;
    uint32_t cryptsize;
    uint32_t cryptid;
};
#endif


// Provisioning (returns nothing if not found)
+ (BETrustFactorOutputObject *)tamper:(NSArray *)payload {
    
    // This will crash the app if its connected to a debugger
    //[self denyAttach];
    
    BETrustFactorOutputObject *trustFactorOutputObject = [[BETrustFactorOutputObject alloc] init];
    
    // Set the default status code to OK (default = DNEStatus_ok)
    [trustFactorOutputObject setStatusCode:DNEStatus_ok];
    
    // Create the output array
    NSMutableArray *outputArray = [[NSMutableArray alloc] init];
    
    // Validate the payload
    if (![[BETrustFactorDatasets sharedDatasets] validatePayload:payload]) {
        // Payload is EMPTY
        
        // Set the DNE status code to NODATA
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        // Return with the blank output object
        return trustFactorOutputObject;
    }
    
    /* Removed due to iOS 9
     
     // debugger check
     int debugCheck = [self debuggerCheck];
     
     // Check the result
     if(debugCheck>1){
     [outputArray addObject:@"debuggerFound"];
     }else if(debugCheck==-1){ //Error
     
     [trustFactorOutputObject setStatusCode:DNEStatus_error];
     return trustFactorOutputObject;
     }
     */
    
    // binary check
    //NSString *checksum = [self binaryChecksum];
    
    // if bad checksum
    //if(checksum != nil){
    //    [outputArray addObject:checksum];
    //}
    int hookResult = [self checkAddress];
    if(hookResult>1) {
        
        //Method imp changed
        [outputArray addObject:@"hook detected"];
        
    }else if(hookResult==-1){ //Error
        [trustFactorOutputObject setStatusCode:DNEStatus_error];
        
        return trustFactorOutputObject;
    }
    
    // Iterate through payload names and look for bad modules
    uint32_t count = _dyld_image_count();
    
    for (NSString *badModule in payload) {
        
        for(uint32_t i = 0; i < count; i++)
        {
            //Name of image (includes full path)
            const char *dyld = _dyld_get_image_name(i);
            
            if(!strstr(dyld,[badModule cStringUsingEncoding:NSASCIIStringEncoding])) {
                continue;
            }
            else {
                //NSLog([NSString stringWithFormat:@"%s",dyld]);
                // make sure we don't add more than one instance of the module
                if (![outputArray containsObject:[@"dyldFound_" stringByAppendingString:badModule]]){
                    
                    // Add the module to the output array
                    [outputArray addObject:[@"dyldFound_" stringByAppendingString:badModule]];
                }
                
            }
        }
    }
    
    // Set the trustfactor output to the output array (regardless if empty)
    [trustFactorOutputObject setOutput:outputArray];
    
    return trustFactorOutputObject;
}

// Check for hook
// static int checkAddress __attribute__((always_inline));
+(int) checkAddress{
    Dl_info info;
    const char * class = "BETrustFactorDispatch_BioEncrypt";
    const char * method = "tamper:";
    IMP imp = class_getMethodImplementation(objc_getClass(class), sel_registerName(method));
    if (dladdr(imp, &info)){
        //do checks
        if([[NSString stringWithFormat:@"%s",info.dli_fname] containsString:@"libobjc.A.dylib"]){
            return 1;
        }else{
            return 2;
        }
    } else { //Error
        return -1;
    }
}


/* Removed due to iOS 9
 
 // Check for debugger
 + (int)debuggerCheck{
 
 #define DBGCHK_P_TRACED 0x00000800
 
 // Current process name
 int ourPID = [[[BETrustFactorDatasets sharedDatasets] getOurPID] intValue];
 
 if (ourPID == 0){ //something is wrong, didn't find our PID
 return -1;
 }
 
 //this is for testing, may use later

 
 //check for P_TRACE
 
 size_t sz = sizeof(struct kinfo_proc);
 
 struct kinfo_proc info;
 
 memset(&info, 0, sz);
 
 int    name[4];
 
 name [0] = CTL_KERN;
 name [1] = KERN_PROC;
 name [2] = KERN_PROC_PID;
 name [3] = ourPID;
 
 if (sysCtl(name,4,&info,&sz) != 0){
 return -1; //something is wrong
 }
 
 
 if (info.kp_proc.p_flag & DBGCHK_P_TRACED) {
 
 //NSLog(@"being debuged");
 return DBGCHK_P_TRACED;
 
 }
 else{
 return 0;
 }
 
 }
 
 */

// Deny debug attach
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif  // !defined(PT_DENY_ATTACH)

+(void)denyAttach
{
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

//
//// Check for patch
//+(NSString*)binaryChecksum {
//
//    const char * originalSignature = "098f66dd20ec8a1ceb355e36f2ea2ab5";
//    const struct mach_header * header;
//    Dl_info dlinfo;
//
//    // Define main
//    int main (int argc, char *argv[]);
//    //
//    if (dladdr(main, &dlinfo) == 0 || dlinfo.dli_fbase == NULL)
//        return nil; // Can't find symbol for main
//    //
//    header = dlinfo.dli_fbase;  // Pointer on the Mach-O header
//    struct load_command * cmd = (struct load_command *)(header + 1); // First load command
//    // Now iterate through load command
//    //to find __text section of __TEXT segment
//    for (uint32_t i = 0; cmd != NULL && i < header->ncmds; i++) {
//
//        //check for encrypt
//        if (cmd->cmd == LC_ENCRYPTION_INFO) {
//            // Define the info from the crypt command
//            struct encryption_info_command *crypt_cmd = (struct encryption_info_command *) cmd;
//            // Check if binary encryption is enabled
//            if (crypt_cmd->cryptid < 1) {
//                // Encryption information is invalid
//                // Return Pirated
//                return [NSString stringWithFormat:@"%d",LC_ENCRYPTION_INFO];
//            }
//        }
//
//        // Try to compute checksum
//        if (cmd->cmd == LC_SEGMENT) {
//
//            // __TEXT load command is a LC_SEGMENT load command
//            struct segment_command * segment = (struct segment_command *)cmd;
//
//            if (!strcmp(segment->segname, "__TEXT")) {
//                // Stop on __TEXT segment load command and go through sections
//                // to find __text section
//                struct section * section = (struct section *)(segment + 1);
//                for (uint32_t j = 0; section != NULL && j < segment->nsects; j++) {
//                    if (!strcmp(section->sectname, "__text"))
//                        break; //Stop on __text section load command
//                    section = (struct section *)(section + 1);
//                }
//
//                // Get here the __text section address, the __text section size
//                // and the virtual memory address so we can calculate
//                // a pointer on the __text section
//                int textSectionAddr = (int)section->addr;
//                int textSectionSize = (int)section->size;
//                int vmaddr = (int)segment->vmaddr;
//                char * textSectionPtr = (char *)(uintptr_t)((int)header + (int)textSectionAddr - (int)vmaddr);
//
//                // Calculate the signature of the data,
//                // store the result in a string
//                // and compare to the original one
//                unsigned char digest[CC_MD5_DIGEST_LENGTH];
//                char signature[2 * CC_MD5_DIGEST_LENGTH];            // will hold the signature
//                CC_MD5(textSectionPtr, textSectionSize, digest);     // calculate the signature
//                for (int i = 0; i < sizeof(digest); i++)             // fill signature
//                    sprintf(signature + (2 * i), "%02x", digest[i]);
//
//                // They do not match
//                if(strcmp(originalSignature, signature) != 0){
//                    return [NSString stringWithUTF8String:signature];
//
//                } else {
//                    return nil;
//                }
//            }
//        }
//
//        cmd = (struct load_command *)((uint8_t *)cmd + cmd->cmdsize);
//    }
//
//    return nil;
//}

@end
