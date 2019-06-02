//
//  UserDeviceTableViewCell.h
//  BioEncrypt
//
//  Created by Ivo Leko on 24/11/16.
//

#import <UIKit/UIKit.h>
#import "CircularProgressView.h"

@interface UserDeviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet CircularProgressView *circularProgressView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;



@end
