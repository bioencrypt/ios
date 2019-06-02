//
//  UserDeviceInformationViewController.m
//  BioEncrypt
//
//  Created by Ivo Leko on 24/11/16.
//

@import BioEncrypt;
#import "UserDeviceInformationViewController.h"
#import "UserDeviceTableViewCell.h"
#import "DetailInfoViewController.h"

static NSString *CellIdentifier = @"USER_DEVICE_CELL";


@interface UserDeviceInformationViewController ()


// header of list
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMainIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelMainTitle;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;

//tableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end

@implementation UserDeviceInformationViewController

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - view-lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    
    //register UITableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:@"UserDeviceTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    
    //header update
    if (self.informationType == InformationTypeUser) {
        self.labelMainTitle.text = @"User Security";
        self.imageViewMainIcon.image = [UIImage imageNamed:@"user_dark"];
    }
    else {
        self.labelMainTitle.text = @"Device Security";
        self.imageViewMainIcon.image = [UIImage imageNamed:@"device_dark"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableView delegate and datasource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfSubClassResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UserDeviceTableViewCell *cell = (UserDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //basic cell configuration
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    //fill a data
    BESubClassResult_Object *resultObject = self.arrayOfSubClassResults[indexPath.row];
    cell.labelTitle.text = resultObject.subClassTitle;
    
    // If it is COMPLETE then don't show on this screen, only show problems
    if ([[resultObject.subClassStatusText uppercaseString] isEqualToString:@"COMPLETE"] ||[[resultObject.subClassStatusText uppercaseString] isEqualToString:@"EXPIRED"]){
        cell.labelStatus.text = @"";
        
        //increase size of title
        cell.labelTitle.font = [UIFont fontWithName:cell.labelTitle.font.fontName size:22.0];
    }
    else {
        cell.labelStatus.text = [resultObject.subClassStatusText uppercaseString];
        cell.labelTitle.font = [UIFont fontWithName:cell.labelTitle.font.fontName size:20.0];
    }

    
    //"TRUSTED" is yellow, all other states are red
    if ([cell.labelStatus.text isEqualToString:@"COMPLETE"]){
        cell.labelStatus.textColor = kStatusTrustedColor;
    }
    else {
        cell.labelStatus.textColor = kStatusUnTrustedColor;
    }
    

    //icon
    cell.imageViewIcon.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)resultObject.subClassIconID]];
    
    
    //progress
    cell.circularProgressView.progress = resultObject.trustPercent;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailInfoViewController *detail = [[DetailInfoViewController alloc] init];
    detail.subClassResultObject = self.arrayOfSubClassResults[indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
}






@end
