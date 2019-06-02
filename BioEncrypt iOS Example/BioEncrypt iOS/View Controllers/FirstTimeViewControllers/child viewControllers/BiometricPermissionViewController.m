//
//  BiometricPermissionViewController.m
//  BioEncrypt
//
//  Created by Ivo Leko on 30/10/16.
//

@import BioEncrypt;
#import "BiometricPermissionViewController.h"

@interface BiometricPermissionViewController ()


- (IBAction)pressedAccept:(id)sender;
- (IBAction)pressedDecline:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *labelDescription;



@end

@implementation BiometricPermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  

    if (![[BECoreDetection sharedDetection] faceIDAvailable]) {
        self.titleLabel.text = @"Fingerprint Authentication";
        self.labelDescription.text = @"On supported iOS devices TouchID can be employed for fingerprint authentication. BioEncrypt can request fingerprint authentication under specific circumstances.  If you are currently using TouchID to unlock your device pressing \"continue\" below will prompt for your fingerprint. Declining TouchID will result in password use.";
    } else {
        self.titleLabel.text = @"Facial Authentication";
        self.labelDescription.text = @"On supported iOS devices FaceID can be employed for facial authentication. BioEncrypt can request facial authentication under specific circumstances.  If you are currently using FaceID to unlock your device pressing \"continue\" below will prompt for your fingerprint. Declining FaceID will result in password use.";
    }
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressedAccept:(id)sender {
    self.completionBlock(true);
}

- (IBAction)pressedDecline:(id)sender {
    self.completionBlock(false);
}







@end
