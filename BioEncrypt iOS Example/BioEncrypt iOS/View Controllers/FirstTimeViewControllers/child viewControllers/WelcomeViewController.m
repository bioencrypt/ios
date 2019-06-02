//
//  WelcomeViewController.m
//  BioEncrypt
//
//  Created by Ivo Leko on 06/05/16.
//

@import BioEncrypt;
#import "WelcomeViewController.h"

@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelWelcomeTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelWelcomeDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonContinue;
@property (weak, nonatomic) IBOutlet UIView *viewLogoAndLabelsHolder;

- (IBAction)pressedContinue:(id)sender;


@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewLogoAndLabelsHolder.alpha = 0;
    self.buttonContinue.alpha = 0;

    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated {
    [self loadUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) loadUI {
    
    //load title and description from policy
    NSError *error;
    BEPolicy *policy = [[BECoreDetection sharedDetection] getCurrentPolicyWithError: &error];
    
    if (error) {
        //some strange error occured
        [self showAlertWithTitle:@"Error" andMessage:error.localizedDescription];
    }
    
    self.labelWelcomeTitle.text = policy.welcome[@"title"];
    self.labelWelcomeDescription.text = policy.welcome[@"description"];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.viewLogoAndLabelsHolder.alpha = 1;
        self.buttonContinue.alpha = 1;
    }];
}


- (IBAction)pressedContinue:(id)sender {
    self.completionBlock(YES);
    self.completionBlock = nil;
}




@end
