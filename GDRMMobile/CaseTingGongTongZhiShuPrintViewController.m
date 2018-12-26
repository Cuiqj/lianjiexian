//
//  CaseTingGongTongZhiShuPrintViewController.m
//  GDRMMobile
//
//  Created by xiaoxiaojia on 17/1/16.
//
//


#import "CaseTingGongTongZhiShuPrintViewController.h"
#import "AtonementNotice.h"
#import "CaseDeformation.h"
#import "CaseProveInfo.h"
#import "Citizen.h"
#import "CaseInfo.h"
#import "RoadSegment.h"
#import "OrgInfo.h"
#import "UserInfo.h"
#import "NSNumber+NumberConvert.h"
#import "Systype.h"
#import "MatchLaw.h"
#import "MatchLawDetails.h"
#import "LawItems.h"
#import "LawbreakingAction.h"
#import "Laws.h"
#import "FileCode.h"
#import "StopNotice.h"
#import "MaintainPlan.h"
#import "MaintainPlanCheck.h"

static NSString * xmlName = @"TingGongTongZhiShu";

@interface CaseTingGongTongZhiShuPrintViewController ()
@property (nonatomic,retain) AtonementNotice *notice;
@property (nonatomic,retain) StopNotice *stopNoticeInfo;
@property (nonatomic, retain) NSString *autoNumber;
@property (nonatomic,strong) UIPopoverController *pickerPopover;

- (void)generateDefaultsForNotice:(AtonementNotice *)notice;
@end

@implementation CaseTingGongTongZhiShuPrintViewController

@synthesize caseID = _caseID;
@synthesize notice = _notice;

- (void)viewDidLoad{
    [super setCaseID:self.caseID];
    NSString * strtemp = [[AppDelegate App] serverAddress];
    
    if ([strtemp isEqualToString:@"http://219.131.172.163:81/irmsdatagy/"]) {
//        xmlName = @"GYAtonementNoticeTable";
    }
    [self LoadPaperSettings:xmlName];
    CGRect viewFrame = CGRectMake(0.0, 0.0, VIEW_FRAME_WIDTH, VIEW_FRAME_HEIGHT);
    self.view.frame = viewFrame;
    /*modify by lxm 不能实时更新*/
    if (![self.caseID isEmpty]) {
        self.stopNoticeInfo = [StopNotice stopNoticeInfoForCheckID:self.caseID];
        if(self.stopNoticeInfo==nil){
            self.stopNoticeInfo =[StopNotice newDataObjectWithEntityName:@"StopNotice"];
            self.stopNoticeInfo.maintainPlanCheck_id=self.caseID;
        }
        //[self generateDefaultInfo:self.stopNoticeInfo];
        [self pageLoadInfo];
    }
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)pageLoadInfo{
    
    StopNotice *stopNoticeInfo = [StopNotice stopNoticeInfoForCheckID:self.caseID];
    self.textnumber.text=stopNoticeInfo.number;
    
    // self.textproject_address.text=RectificationNoticeInfo.project_address;
    //self.textconstruct_org.text=RectificationNoticeInfo.construct_org;
    
    MaintainPlanCheck *iPlanCheck= [[MaintainPlanCheck maintainCheckForID:self.caseID] objectAtIndex:0];
    //MaintainPlan *iPlan=  [MaintainPlan maintainPlanInfoForID:self.maintainplanID];
    MaintainPlan *iPlan=  [MaintainPlan maintainPlanInfoForID:iPlanCheck.maintainPlan_id];
    self.textproject_address.text=iPlan.project_address;
    self.textconstruct_org.text=iPlan.construct_org;
    
    self.textdisobey_item.text=stopNoticeInfo.disobey_item;
    //self.textalter_item.text=RectificationNoticeInfo.alter_item;
    self.textobey_tiao.text=stopNoticeInfo.obey_tiao;
    self.textobey_kuan.text=stopNoticeInfo.obey_kuan;
    self.textmoney.text=stopNoticeInfo.money;
    self.textchinese_money.text=stopNoticeInfo.chinese_money;
    self.textrecorder.text=stopNoticeInfo.recorder;
    self.textcitizen.text=stopNoticeInfo.citizen;
    //self.textsend_date.text=RectificationNoticeInfo.send_date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    // self.textsend_date.text = [dateFormatter stringFromDate:self.stopNoticeInfo.send_date];
    
    
}
- (void)pageSaveInfo{
    //案由
    self.stopNoticeInfo.number = [self.textnumber.text isEqualToString:@""]?@"0":self.textnumber.text;
    self.stopNoticeInfo.disobey_item=[self.textdisobey_item.text isEqualToString:@"0"]?@"0":self.textdisobey_item.text;
    //self.stopNoticeInfo.alter_item=self.textalter_item.text;
    self.stopNoticeInfo.obey_tiao=[self.textobey_tiao.text isEqualToString:@""]?@"0":self.textobey_tiao.text;
    self.stopNoticeInfo.obey_kuan=[self.textobey_kuan.text isEqualToString:@""]?@"0":self.textobey_kuan.text;
    self.stopNoticeInfo.money=[self.textmoney.text isEqualToString:@""]?@"0":self.textmoney.text;
    self.stopNoticeInfo.chinese_money=self.textchinese_money.text;
    self.stopNoticeInfo.recorder=self.textrecorder.text;
    self.stopNoticeInfo.citizen=self.textcitizen.text;
    //self.RectificationNoticeInfo.send_date=sel
    [[AppDelegate App] saveContext];
    
}

-(NSURL *)toFullPDFWithPath:(NSString *)filePath{
    [self pageSaveInfo];
    if (![filePath isEmpty]) {
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawStaticTable:xmlName];
        [self drawDateTable:xmlName withDataModel:self.stopNoticeInfo];
        UIGraphicsEndPDFContext();
        
        return [NSURL fileURLWithPath:filePath];
    } else {
        return nil;
    }
}

-(NSURL *)toFormedPDFWithPath:(NSString *)filePath{
    [self pageSaveInfo];
    if (![filePath isEmpty]) {
        NSString *formatFilePath = [NSString stringWithFormat:@"%@.format.pdf", filePath];
        CGRect pdfRect=CGRectMake(0.0, 0.0, paperWidth, paperHeight);
        UIGraphicsBeginPDFContextToFile(formatFilePath, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(pdfRect, nil);
        [self drawDateTable:xmlName withDataModel:self.stopNoticeInfo];
        UIGraphicsEndPDFContext();
        
        return [NSURL fileURLWithPath:formatFilePath];
    } else {
        return nil;
    }
}


#pragma mark - prepare for Segue
//初始化各弹出选择页面
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSString *segueIdentifier= [segue identifier];
    if ([segueIdentifier isEqualToString:@"toDateTimePicker"]) {
        DateSelectController *dsVC=segue.destinationViewController;
        dsVC.dateselectPopover=[(UIStoryboardPopoverSegue *) segue popoverController];
        dsVC.delegate=self;
        dsVC.pickerType=1;
        dsVC.textFieldTag = self.textsend_date.tag;
        dsVC.datePicker.maximumDate=[NSDate date];
        [dsVC showPastDate:[NSDate date]];
    }else if ([segueIdentifier isEqualToString:@"toDateTimePicker2"]) {
        DateSelectController *dsVC=segue.destinationViewController;
        dsVC.dateselectPopover=[(UIStoryboardPopoverSegue *) segue popoverController];
        dsVC.delegate=self;
        dsVC.pickerType=1;
        dsVC.textFieldTag = self.textsend_date.tag;
        dsVC.datePicker.maximumDate=[NSDate date];
        [dsVC showPastDate:[NSDate date]];
    }
     
}

//时间选择
- (IBAction)selectDateAndTime:(id)sender{
    UITextField* textField = (UITextField* )sender;
    switch (textField.tag) {
        case 100:
            [self performSegueWithIdentifier:@"toDateTimePicker" sender:self];
            break;
        case 101:
            [self performSegueWithIdentifier:@"toDateTimePicker" sender:self];
            break;
        default:
            [self performSegueWithIdentifier:@"toDateTimePicker" sender:self];
            break;
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 100:
        case 101:
        case 200:
        case 201:
        case 202:
            return NO;
            break;
        default:
            return YES;
            break;
    }
}

- (void)setPastDate:(NSDate *)date withTag:(int)tag{
    
    self.stopNoticeInfo.send_date = date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    self.textsend_date.text = [dateFormatter stringFromDate:date];
    
}

- (IBAction)userSelect:(UITextField *)sender {
    //self.textFieldTag = sender.tag;
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        UserPickerViewController *acPicker=[[UserPickerViewController alloc] init];
        acPicker.delegate=self;
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:acPicker];
        [self.pickerPopover setPopoverContentSize:CGSizeMake(140, 200)];
        [self.pickerPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        acPicker.pickerPopover=self.pickerPopover;
    }
}

- (void)setUser:(NSString *)name andUserID:(NSString *)userID{
    //    if (self.textFieldTag == 200) {
    //        self.textprover1.text = name;
    //        self.textprover1_duty.text = [UserInfo orgAndDutyForUserName:name];
    //    }else if (self.textFieldTag == 201){
    //        self.textprover2.text = name;
    //        self.textprover2_duty.text = [UserInfo orgAndDutyForUserName:name];
    //    }else if (self.textFieldTag == 202){
    //        self.textrecorder.text = name;
    //        self.textrecorder_duty.text = [UserInfo orgAndDutyForUserName:name];
    //    }
    self.textrecorder.text=name;
}

@end
