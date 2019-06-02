//
//  BETrustFactorDataset_Process.m
//  BioEncrypt
//
//  Created by Jason Sinchak on 7/17/15.
//

#import "BETrustFactorDataset_Process.h"
#import "ActiveProcess.h"

@implementation BETrustFactorDataset_Process : NSObject

#define sysCtlSz(nm,cnt,sz)   sysctl((int *)nm,cnt,NULL,sz,NULL,0)
#define sysCtl(nm,cnt,lst,sz) sysctl((int *)nm,cnt,lst, sz,NULL,0)


int readSys(int *, u_int, void *, size_t *);

// Return ourPID for TFs like debug

static int ourPID=0;

// Get self PID
+ (NSNumber *)getOurPID{
    
    // Check if we're populated, otherwise processInformation has not run yet (this would only happen if a TF seeking PID happens to run before any other regular process TFs)
    if (ourPID == 0) {
        [self getProcessInfo];
    }
    
    //return PID
    return [NSNumber numberWithInt:ourPID];
}

+ (NSArray *)getProcessInfo {
    
    // Get bundle name and set
    NSString* ourName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    // Get the list of processes and all information about them
    @try {
        // Make a new integer array holding all the kernel processes
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        
        // Make a new size of 4
        size_t miblen = 4;
        
        size_t size = 0;
        int st = sysCtl(mib, (int)miblen, NULL, &size);
        
        // Set up the processes and new process struct
        struct kinfo_proc *process = NULL;
        struct kinfo_proc *newprocess = NULL;
        
        // dD, while loop rnning through all the processes
        do {
            size += size / 10;
            newprocess = realloc(process, size);
            
            if (!newprocess) {
                if (process) free(process);
                // Error
                return nil;
            }
            
            process = newprocess;
            st = sysCtl(mib, (int)miblen, process, &size);
            
        } while (st == -1 && errno == ENOMEM);
        
        if (st == 0) {
            if (size % sizeof(struct kinfo_proc) == 0) {
                int nprocess = (int)(size / sizeof(struct kinfo_proc));
                
                if (nprocess) {
                    NSMutableArray *array = [[NSMutableArray alloc] init];
                    
                    for (int i = nprocess - 1; i >= 0; i--) {
                        
                        // Get the user ID for the process
                        struct kinfo_proc info;
                        size_t length = sizeof(struct kinfo_proc);
                        int mib[4] = { CTL_KERN, KERN_PROC, KERN_PROC_PID, (int)process[i].kp_proc.p_pid };
                        
                        if (sysCtl(mib, 4, &info, &length) < 0)
                            // Unknown value
                            continue;
                        
                        if (length == 0)
                            // Unknown value
                            continue;
                        
                        
                        /*// Set values
                         NSNumber *processID = [NSNumber numberWithInt:(int)process[i].kp_proc.p_pid];
                         NSString *processName = [[NSString alloc] initWithFormat:@"%s", process[i].kp_proc.p_comm];
                         NSNumber *processUID = [NSNumber numberWithInt:info.kp_eproc.e_ucred.cr_uid];
                         
                         //NSString *processPriority = [[NSString alloc] initWithFormat:@"%d", process[i].kp_proc.p_priority];
                         //NSDate   *processStartDate = [NSDate dateWithTimeIntervalSince1970:process[i].kp_proc.p_un.__p_starttime.tv_sec];
                         //NSString       *processStatus = [[NSString alloc] initWithFormat:@"%d", (int)process[i].kp_proc.p_stat];
                         //NSString       *processFlags = [[NSString alloc] initWithFormat:@"%d", (int)process[i].kp_proc.p_flag];
                         
                         // Check to make sure all values are valid (if not, make them)
                         if (processID == nil) {
                         // Invalid value
                         processID = 0;
                         }
                         if (processName == nil || processName.length <= 0) {
                         // Invalid value
                         processName = @"Unknown";
                         }
                         if (processPriority == nil || processPriority.length <= 0) {
                         // Invalid value
                         processPriority = @"Unknown";
                         }
                         if (processStartDate == nil) {
                         // Invalid value
                         processStartDate = [NSDate date];
                         }
                         
                         if (processStatus == nil || processStatus.length <= 0) {
                         // Invalid value
                         processStatus = @"Unknown";
                         }
                         if (processFlags == nil || processFlags.length <= 0) {
                         // Invalid value
                         processFlags = @"Unknown";
                         }
                         
                         
                         if (processUID == nil) {
                         // Invalid value
                         processUID = [NSNumber numberWithInt:(int)9999];
                         }
                         */
                        
                        
                        ActiveProcess *newProcess = [[ActiveProcess alloc] init];
                        
                        newProcess.id = [NSNumber numberWithInt:(int)process[i].kp_proc.p_pid];
                        newProcess.name = [NSString stringWithFormat:@"%s", process[i].kp_proc.p_comm];
                        newProcess.uid = [NSNumber numberWithInt:info.kp_eproc.e_ucred.cr_uid];
                        
                        
                        // Add the objects to the array
                        [array addObject:newProcess];
                        
                        //check if this is our process and record PID
                        if([ourName isEqualToString:newProcess.name]) {
                            ourPID = [newProcess.id intValue];
                        }
                    }
                    
                    // Make sure the array is usable
                    if (array.count <= 0) {
                        // Error, nothing in array
                        return nil;
                    }
                    
                    // Free the process
                    free(process);
                    
                    // Successful
                    // return
                    return array;
                }
            }
        }
        
        // Something failed
        return nil;
    }
    @catch (NSException * ex) {
        // Error
        return nil;
    }
    
}



@end
