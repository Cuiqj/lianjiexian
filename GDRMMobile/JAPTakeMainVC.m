//
//  JAPTakeMainVC.m
//  YUNWUMobile
//
//  Created by admin on 2018/2/6.
//
//

#import "JAPTakeMainVC.h"
#import "IQKeyboardManager.h"
@interface JAPTakeMainVC ()

@end

@implementation JAPTakeMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [IQKeyboardManager sharedManager].toolbarTintColor=[UIColor redColor];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
