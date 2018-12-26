//
//  JAProductTakeViewController.m
//  YUNWUMobile
//
//  Created by admin on 2018/2/6.
//
//

#import "JAProductTakeViewController.h"
#import "JAPTakeMainVC.h"
@interface JAProductTakeViewController ()

@end

@implementation JAProductTakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnNewTake:(UIButton *)sender {
    [self btnToMainVC];
}
- (void)btnToMainVC {
     JAPTakeMainVC *vc2=[[JAPTakeMainVC alloc]init];
        //[((RoadInspectViewController*)self.delegate) presentViewController: vc2 animated:YES completion:nil];// vc2 animated:YES];
        //[ ((RoadInspectViewController*)self.delegate) presentModalViewController:vc2 animated:YES] ;
        //UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:vc2];
        //vc2.inspectionID=self.inspectionID;
        vc2.modalPresentationStyle = UIModalPresentationFormSheet;
        vc2.preferredContentSize = CGSizeMake(600, 500);
        vc2.popoverPresentationController.sourceView =self.view;
        vc2.popoverPresentationController.sourceRect =self.view.bounds;
        //vc2.delegate=self.delegate;
        [self presentViewController:vc2 animated:YES completion:nil];
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
