//
//  TrafficAssistVC.m
//  YUNWUMobile
//
//  Created by admin on 2018/2/8.
//
//

#import "TrafficAssistVC.h"
#import "JAPTakeMainVC.h"
@interface TrafficAssistVC ()<UIViewControllerAnimatedTransitioning,UIViewControllerContextTransitioning>

@end

@implementation TrafficAssistVC
/*
 -(void)loadView{
 [super loadView];
 UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 scrollView.backgroundColor=[UIColor whiteColor];
 self.view                = scrollView;
 }
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gggg) name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gggg) name:UIKeyboardDidHideNotification object:nil];
    UIBarButtonItem *add=[[UIBarButtonItem alloc]initWithTitle:@"新增" style:UIBarButtonSystemItemAdd target:self action:@selector(btnAdd)];
    self.navigationItem.rightBarButtonItem = add;
}
-(void)btnAdd{
    JAPTakeMainVC *vc2=[[JAPTakeMainVC alloc]init];
    vc2.modalPresentationStyle                   = UIModalPresentationFormSheet;
    vc2.preferredContentSize                     = CGSizeMake(600, 500);
    vc2.popoverPresentationController.sourceView = self.view;
    vc2.popoverPresentationController.sourceRect = self.view.bounds;
    //vc2.delegate=self.delegate;
    [vc2 setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:vc2 animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    //为了将两种动画的逻辑分开，变得更加清晰，我们分开书写逻辑，
//    switch (_type) {
//        case XWPresentOneTransitionTypePresent:
//            [self presentAnimation:transitionContext];
//            break;
//            
//        case XWPresentOneTransitionTypeDismiss:
//            [self dismissAnimation:transitionContext];
//            break;
//    }
    [self presentAnimation:transitionContext];
}
//实现present动画逻辑代码
- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
}
//实现dismiss动画逻辑代码
- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext{
    
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
