//
//  DebugMenuViewController.m
//  BioEncrypt
//
//  Created by Ivo Leko on 11/12/16.
//


// RESideMenu
#import "RESideMenu.h"
#define hsb(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:1.0]


#import "DebugMenuViewController.h"
#import "UserDebugViewController.h"
#import "TransparentDebugViewController.h"
#import "SystemDebugViewController.h"
#import "ComputationInfoViewController.h"

@interface DebugMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;


@end

@implementation DebugMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // to avoid separator lines on empty cells
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    [self.tableView setTableFooterView:footer];
    
    
    // cells data
    self.titles = @[@"User Debug", @"Transparent Debug", @"System Debug", @"Score Debug", @"Wipe Profile"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0: {
            // User Debug
            
            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Debug" bundle:nil];

            // Create the user debug view controller
            UserDebugViewController *userDebugController = [mainStoryboard instantiateViewControllerWithIdentifier:@"userdebugviewcontroller"];

            // Present it
            [self presentViewController:userDebugController animated:YES completion:^{
                // Done presenting

                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];
            
            // Done
            break;
        }
        case 1: {
            // Transparent Auth

            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Debug" bundle:nil];

            // Create the user debug view controller
            TransparentDebugViewController *transparentDebugController = [mainStoryboard instantiateViewControllerWithIdentifier:@"transparentdebugviewcontroller"];

            // Present it
            [self presentViewController:transparentDebugController animated:YES completion:^{
                // Done presenting

                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];

            // Done
            break;
        }
        case 2: {
            // System Debug

            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Debug" bundle:nil];

            // Create the system debug view controller
            SystemDebugViewController *systemDebugController = [mainStoryboard instantiateViewControllerWithIdentifier:@"systemdebugviewcontroller"];


            // Present it
            [self presentViewController:systemDebugController animated:YES completion:^{
                // Done presenting

                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];

            break;
        }
        case 3: {
            // Computation Info
            
            // Get the storyboard
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Debug" bundle:nil];

            // Create the system debug view controller
            ComputationInfoViewController *computationInfoController = [mainStoryboard instantiateViewControllerWithIdentifier:@"computationinfoviewcontroller"];

            // Present it
            [self presentViewController:computationInfoController animated:YES completion:^{
                // Done presenting

                // Hide the side menu
                //[self.sideMenuViewController hideMenuViewController];
            }];

            break;
        }
        case 4: {
            // Reset Stores

            
            UIAlertController* alert = [UIAlertController
                                        alertControllerWithTitle:@"Wipe Profile"
                                        
                                        message:@"Are you sure you want to wipe the device profile? The demo will wipe all learned data."
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     
                                                                    
                                                                 }];
            
            UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Reset"
                                                                    style:UIAlertActionStyleDestructive
                                                                   handler:^(UIAlertAction * action) {
                                                                       // handle successful validation here
                                                                       NSLog(@"Chose to reset the store and the startup file");
                                                                       
                                                                       // Create an error
                                                                       NSError *error;
                                                                       
                                                                       [[BECoreDetection sharedDetection] resetStoreAndStartupWithError: &error];
                                                                       
                                                                   }];
            
            [alert addAction:cancelAction];
            [alert addAction:settingsAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            break;
        }
        default:
            // Do nothing
            [self.sideMenuViewController hideMenuViewController];
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Number of sections - only need 1
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    // Number of rows
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = hsb(192, 2, 95);
        cell.textLabel.highlightedTextColor = hsb(184, 10, 55);
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    // Titles of our rows
    
    cell.textLabel.text = self.titles[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    return cell;
}





@end
