//
//  UserDeviceTableViewCell.m
//  BioEncrypt
//
//  Created by Ivo Leko on 24/11/16.
//

@import BioEncrypt;
#import "UserDeviceTableViewCell.h"


@implementation UserDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    //configure circle view
    self.circularProgressView.circleWidth = 5.0;
    self.circularProgressView.circleColor = kCircularProgressEmptyColor;
    self.circularProgressView.circleProgressColor = kCircularProgressFillColor;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
