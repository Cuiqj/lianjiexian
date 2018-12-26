//
//  HomePageController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HomePageController.h"
#import "OrgInfo.h"
#import "UserInfo.h"
#import "ServicesCheckViewController.h"
#import "CarCheckViewController.h"
#import "ZLYHRoadAssetCheckViewController.h"
#import "OMGToast.h"
#import "InspectInMapViewCOntroller.h"
#import "JAProductTakeViewController.h"
#import "TrafficAssistVC.h"
#import "PropertyRepairVC.h"
#import "UNderBridgeViewController.h"

@interface HomePageController ()
- (void) loadUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *repairNoteBtn;
@property (weak, nonatomic) IBOutlet UIButton *jiaoAnTakeBtn;
@property (nonatomic,retain) UIPopoverController *popover;
@property (weak, nonatomic) IBOutlet UIButton *trafficAssistBtn;
@property (weak, nonatomic) IBOutlet UIButton *zlyhBtn;
@end

@implementation HomePageController
@synthesize labelOrgShortName;
@synthesize labelCurrentUser;
@synthesize popover;

- (void) loadUserLabel {
    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
    NSString *currentUserName=[[UserInfo userInfoForUserID:currentUserID] valueForKey:@"username"];
    if (currentUserName==nil) {
        currentUserName = @"";
    }
    self.labelCurrentUser.text=[[NSString alloc] initWithFormat:@"操作员：%@",currentUserName];
    self.labelOrgShortName.text = [[OrgInfo orgInfoForOrgID:[UserInfo userInfoForUserID:currentUserID].organization_id] valueForKey:@"orgshortname"];
}

//监测是否设置当前机构，否则弹出机构选择菜单
- (void)viewDidAppear:(BOOL)animated{
    [self loadUserLabel];
    if ([UserInfo allUserInfo].count <= 0) {
        OrgSyncViewController *osVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrgSyncVC"];
        osVC.modalPresentationStyle = UIModalPresentationFormSheet;
        osVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        osVC.delegate=self;
        [self presentModalViewController:osVC animated:YES];
    } else {
        NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
        if (currentUserID == nil || [currentUserID isEmpty]) {
            [self performSegueWithIdentifier:@"toLogin" sender:nil];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"toLogin"]) {
        LoginViewController *lvc=[segue destinationViewController];
        lvc.delegate=self;
    } else if ([[segue identifier] isEqualToString:@"toLogoutView"]){
        LogoutViewController *lvc=[segue destinationViewController];
        lvc.delegate=self;
        self.popover = [(UIStoryboardPopoverSegue *) segue popoverController];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewDidUnload {
    [self setLabelOrgShortName:nil];
    [self setLabelCurrentUser:nil];
    [self setPopover:nil];
    [super viewDidUnload];
}

- (void)reloadUserLabel{
    [self loadUserLabel];
}

- (void)pushLoginView{
    [self performSegueWithIdentifier:@"toLogin" sender:nil];
}

- (IBAction)btnLogOut:(UIBarButtonItem *)sender {
    if ([self.popover isPopoverVisible]) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [self performSegueWithIdentifier:@"toLogoutView" sender:nil];
    }
}

- (IBAction)btnServicesCheck:(UIButton *)sender {
    UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    ServicesCheckViewController *servicesCheckVC = [secondStoryboard instantiateViewControllerWithIdentifier:@"servicesCheckVC"];
    
    
    [self.navigationController pushViewController:servicesCheckVC animated:YES];
}


- (void)logOut{
    [self.popover dismissPopoverAnimated:YES];
    NSString *inspectionID=[[NSUserDefaults standardUserDefaults] valueForKey:INSPECTIONKEY];
    if (![inspectionID isEmpty] && inspectionID!=nil) {
        void(^ShowAlert)(void)=^(void){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误" message:@"当前还有未完成的巡查，请先交班再切换用户。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        };
        MAINDISPATCH(ShowAlert);
    } else {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:USERKEY];
        [self loadUserLabel];
        [self performSegueWithIdentifier:@"toLogin" sender:nil];
    }
}

- (void)inspectionDeliver{
    [self.popover dismissPopoverAnimated:YES];
    NSString *inspectionID=[[NSUserDefaults standardUserDefaults] valueForKey:INSPECTIONKEY];
    if ([inspectionID isEmpty] || inspectionID == nil) {
        void(^ShowAlert)(void)=^(void){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误" message:@"没有正在进行的巡查，无法交班。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        };
        MAINDISPATCH(ShowAlert);
    } else {
        [self performSegueWithIdentifier:@"toInspectionOutFromMain" sender:nil];
    }
}
//iOS7适配
-(void)viewDidLoad{
    //self.UIGouzhaowujianchabutton.alpha=0.0;//隐藏构造物检查模块入口 广珠西的没有构造物检查
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
        self.tabBarController.tabBar.translucent = NO;
    }
    
    [self.btnToMapView addTarget:self action:@selector(toMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnToMapView setHidden:YES];
    [self.zlyhBtn setHidden:YES];
    [self.jiaoAnTakeBtn setHidden:YES];
    [self.trafficAssistBtn setHidden:YES];
    [self.repairNoteBtn setHidden:YES];
    
    [self.CheckCar setHidden:YES];
    
    [self.jiaoAnTakeBtn addTarget:self action:@selector(toJiaoAn) forControlEvents:UIControlEventTouchUpInside];
    [self.trafficAssistBtn addTarget:self action:@selector(toTrafficAssist) forControlEvents:UIControlEventTouchUpInside];
    [self.repairNoteBtn addTarget:self action:@selector(toPropertyRepair) forControlEvents:UIControlEventTouchUpInside];
    
    [self composingButton];
}
- (void)composingButton{
    
    [self.RoadWorkButton setHidden:YES];
    [self.TrafficButton setHidden:YES];
    [self.AdminstrativeButton setHidden:YES];
    [self.EmergencySafeguardButton setHidden:YES];
    [self.BaoXianButton setHidden:YES];
    [self.CarCheckButton setHidden:YES];
    [self.LawButton setHidden:YES];
    [self.UIGouzhaowujianchabutton setHidden:YES];
    [self.UnderBridegeCheck setHidden:YES];
    [self.caseButton setFrame:CGRectMake(self.view.frame.size.width/2-110, self.view.frame.size.height/11*6,220,80)];
    [self.InspectionButton setFrame:CGRectMake(self.view.frame.size.width/2-410, self.view.frame.size.height/11*6,220,80)];
    [self.DataSynchButton setFrame:CGRectMake(self.view.frame.size.width/2+190, self.view.frame.size.height/11*6,220,80)];
    
}
-(void)toJiaoAn{
    JAProductTakeViewController *jap=[[JAProductTakeViewController alloc]init];
    [self.navigationController pushViewController:jap animated:YES];
}
-(void)toTrafficAssist{
    TrafficAssistVC *trafficassistVC=[[TrafficAssistVC alloc]init];
    [self.navigationController pushViewController:trafficassistVC animated:YES];
}
-(void)toPropertyRepair{
    PropertyRepairVC *propertyRepair=[[PropertyRepairVC alloc] init];
    [self.navigationController pushViewController:propertyRepair animated:YES];
}
-(void)toMap:(UIButton*)btn{
    InspectInMapViewCOntroller *destVC=[[InspectInMapViewCOntroller alloc] init];
    destVC.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController pushViewController:destVC animated:YES];
}

- (IBAction)btnCarcheck:(id)sender {
    UIStoryboard *second=[UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    CarCheckViewController *CarCheckVC=[second instantiateViewControllerWithIdentifier:@"CarCheckViewController"];
    ZLYHRoadAssetCheckViewController *zlyh=[[ZLYHRoadAssetCheckViewController alloc]init];
    //[self.navigationController pushViewController:zlyh animated:YES];
    [self.navigationController pushViewController:CarCheckVC animated:YES];
}

- (IBAction)btnYZDN:(UIButton *)sender {
    ZLYHRoadAssetCheckViewController *zlyh=[[ZLYHRoadAssetCheckViewController alloc]init];
    [self.navigationController pushViewController:zlyh animated:YES];
}

- (IBAction)UnderBridegeCheckClick:(id)sender {
    UNderBridgeViewController * underbridge = [[UNderBridgeViewController alloc]init];
    underbridge.view.backgroundColor=[UIColor whiteColor];
    [self.navigationController pushViewController:underbridge animated:YES];
}
@end
