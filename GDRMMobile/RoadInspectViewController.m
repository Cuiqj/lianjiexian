//
//  RoadInspectViewController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "InspectionConstructionViewController.h"

#import "RoadInspectViewController.h"
#import "InspectionPath.h"
#import "Global.h"
#import "CaseConstructionChangeBackViewController.h"
#import "TrafficRecordViewController.h"
#import "CaseViewController.h"
#import "CaseInfo.h"
#import "CaseProveInfo.h"
#import "Citizen.h"
#import "RoadSegment.h"
#import "CaseDeformation.h"
#import "InspectionRecord.h"
#import "LawbreakingAction.h"
#import "MaintainPlanCheck.h"
#import "ShiGongCheckViewController.h"
@class ServicesCheckViewController;
@interface RoadInspectViewController ()
@property (nonatomic,retain) NSMutableArray      *data;
@property (nonatomic,retain) UIPopoverController *pickerPopover;
@property (nonatomic,retain) NSString            * RecordID;
@property (nonatomic,retain) NSIndexPath         * selectedRecordIndex;

//判断当前显示的巡查是否是正在进行的巡查
@property (nonatomic,assign) BOOL isCurrentInspection;
- (void)loadInspectionInfo;
- (void)saveRemark;
@end

@implementation RoadInspectViewController
@synthesize pathView            = _pathView;
@synthesize labelInspectionInfo = _labelInspectionInfo;
@synthesize textViewRemark      = _textViewRemark;
@synthesize tableRecordList     = _tableRecordList;
@synthesize labelRemark         = _labelRemark;
@synthesize inspectionSeg       = _inspectionSeg;
@synthesize textCheckTime       = _textCheckTime;
@synthesize textStationName     = _textStationName;
@synthesize inspectionID        = _inspectionID;
//@synthesize inspectRecordID = _inspectRecordID;
@synthesize isCurrentInspection = _isCurrentInspection;
@synthesize state               = _state;
@synthesize pickerPopover       = _pickerPopover;
@synthesize textCheckStatus     = _textCheckStatus;
@synthesize mysegue             = _mysegue;

InspectionCheckState inspectionState;

- (void)viewDidLoad
{
    self.state               = kRecord;
    UIFont *segFont          = [UIFont boldSystemFontOfSize:14.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:segFont
                                                           forKey:UITextAttributeFont];
    [self.inspectionSeg setTitleTextAttributes:attributes
                                      forState:UIControlStateNormal];
    
    [super viewDidLoad];
    
    UIStoryboard *secondStoryboard = [UIStoryboard storyboardWithName:@"SecondStoryboard" bundle:nil];
    
    ServicesCheckViewController *servicesCheckVC = [secondStoryboard instantiateViewControllerWithIdentifier:@"servicesCheckVC"];
    self.mysegue =[[UIStoryboardSegue alloc] initWithIdentifier:@"toServicesCheck" source:self destination:servicesCheckVC];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    self.inspectionID=[[NSUserDefaults standardUserDefaults] valueForKey:INSPECTIONKEY];
    self.isCurrentInspection = YES;
    BOOL isJiangzhong        = [[[AppDelegate App].projectDictionary objectForKey:@"projectname"] isEqualToString:@"zhongjiang"];
    if (([self.inspectionID isEmpty] || self.inspectionID==nil) && !isJiangzhong) {
        //    添加出行前检查
        [self performSegueWithIdentifier:@"toNewInspection" sender:nil];
    } else {
        [self loadInspectionInfo];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [self setTextViewRemark:nil];
    [self setTableRecordList:nil];
    [self setLabelRemark:nil];
    [self setLabelInspectionInfo:nil];
    [self setPathView:nil];
    [self setUiButtonAddNew:nil];
    [self setUiButtonSave:nil];
    [self setUiButtonDeliver:nil];
    [self setPickerPopover:nil];
    [self setInspectionSeg:nil];
    [self setTextCheckTime:nil];
    [self setTextStationName:nil];
    [self setTextCheckStatus:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSString *segueIdentifer=[segue identifier];
    if ([segueIdentifer isEqualToString:@"toAddNewInspectionRecord"]) {
        AddNewInspectRecordViewController *newRCVC = segue.destinationViewController;
        newRCVC.inspectionID                       = self.inspectionID;
        newRCVC.delegate                           = self;
    } else if ([segueIdentifer isEqualToString:@"toNewInspection"]) {
        NewInspectionViewController *niVC=[segue destinationViewController];
        niVC.delegate = self;
    } else if ([segueIdentifer isEqualToString:@"toInspectionOut"]) {
        InspectionOutViewController *ioVC=[segue destinationViewController];
        ioVC.delegate = self;
    } else if ([segueIdentifer isEqualToString:@"toCounstructionChangeBack"]){
        CaseConstructionChangeBackViewController *caseVC = segue.destinationViewController;
        [caseVC setRel_id:self.inspectionID];
    } else if ([segueIdentifer isEqualToString:@"toTrafficRecord"]){
        TrafficRecordViewController *trVC = segue.destinationViewController;
        [trVC setRel_id:self.inspectionID];
        [trVC setRoadVC:self];
    } else if ([segueIdentifer isEqualToString:@"inspectToCaseView"]){
        CaseViewController *caseVC = segue.destinationViewController;
        [caseVC setInspectionID:self.inspectionID];
        [caseVC setRoadInspectVC:self];
    }else if ([segue.identifier isEqualToString:@"toUnderBridgeCheck"]) {
        // segue.destinationViewController：获取连线时所指的界面（VC）
        AttachmentViewController *receive = segue.destinationViewController;
        //receive.name = @"Garvey";
        //receive.age = 110;
        InspectionRecord *record          = [InspectionRecord lastRecordsForInspection:self.inspectionID];
        // NSString *constructionId= self.RecordID;
        [receive setValue:record.myid forKey:@"constructionId"];
    }else if ([segueIdentifer isEqualToString:@"insepectToAdminisCaseView"]){
        CaseViewController *caseVC = segue.destinationViewController;
        [caseVC setInspectionID:self.inspectionID];
        [caseVC setRoadInspectVC:self];
    }else if ([segueIdentifer isEqualToString:@"inspectToShiGongCheck"]){
        ShiGongCheckViewController *ShiGongVC = segue.destinationViewController;
        [ShiGongVC setInspectionID:self.inspectionID];
        [ShiGongVC setRoadInspectVC:self];
    }else if ([segueIdentifer isEqualToString:@"inspectToBaoxianCase"]){
        BaoxianCaseViewController * baoxiancase = segue.destinationViewController;
        [baoxiancase setInspectionID:self.inspectionID];
        [baoxiancase setRoadInspectVC:self];
    }/*else if ([segueIdentifer isEqualToString:@"toConstruction"]){
        InspectionConstructionViewController * construction = [[InspectionConstructionViewController alloc]init];
        [self.navigationController popToViewController:construction animated:YES];
    }*/
}
-(void) setxxx:(NSString *)inspectRecordID{
    //return nil;
    self.RecordID = inspectRecordID;
}
#pragma mark - TableView delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifer=@"InspectionRecordCell";
    InspectionRecordCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    if (self.state == kRecord) {
        InspectionRecord *record=[self.data objectAtIndex:indexPath.row];
        self.RecordID            = record.myid;
        cell.labelRemark.text    = record.remark;
        NSInteger stationStartM  = record.station.integerValue%1000;
        NSInteger stationStartKM = record.station.integerValue/1000;
        NSString *stationString=[NSString stringWithFormat:@"K%02d+%03d处",stationStartKM,stationStartM];
        cell.labelStation.hidden = NO;
        if(record.station.integerValue>0){
            cell.labelStation.text = stationString;
        }else{
            cell.labelStation.text=@"";
        }
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:DATE_FORMAT_HH_MM_COLON];
        cell.labelTime.text=[dateFormatter stringFromDate:record.start_time];
    } else {
        self.RecordID         = nil;
        InspectionPath *path  = [self.data objectAtIndex:indexPath.row];
        cell.labelRemark.text = path.stationname;
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:DATE_FORMAT_HH_MM_COLON];
        cell.labelTime.text      = [dateFormatter stringFromDate:path.checktime];
        cell.labelStation.text   = @"";
        cell.labelStation.hidden = YES;
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    id obj=[self.data objectAtIndex:indexPath.row];
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    [context deleteObject:obj];
    [self.data removeObjectAtIndex:indexPath.row];
    [[AppDelegate App] saveContext];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [tableView endUpdates];
    
    //add by lxm
    //清除巡查描述内容
    self.textViewRemark.text=@"";
    self.RecordID = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.state == kRecord) {
        InspectionRecord *record=[self.data objectAtIndex:indexPath.row];
        self.textViewRemark.text = record.remark;
        self.RecordID            = record.myid;
        self.selectedRecordIndex = indexPath;
    } else {
        InspectionPath *path = [self.data objectAtIndex:indexPath.row];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.textCheckTime.text = [dateFormatter stringFromDate:path.checktime];
        
        NSString *tmp         = [path.stationname substringToIndex:2];
        NSString *stationName = path.stationname;
        if ([tmp isEqualToString:@"经过"] || [tmp isEqualToString:@"回到"]) {
            self.textCheckStatus.text = tmp;
            stationName               = [path.stationname substringFromIndex:[tmp length]];
        }
        NSRange found = [stationName rangeOfString:@"沿途状况正常"];
        if (found.location != NSNotFound) {
            stationName   = [stationName substringToIndex:found.location];
        }
        self.textStationName.text = stationName;
    }
}

#pragma mark - InspectionHandler

- (void)reloadRecordData{
    if (self.state == kRecord) {
        self.data=[[InspectionRecord recordsForInspection:self.inspectionID] mutableCopy];
        [self.pathView setHidden:YES];
        [self.view sendSubviewToBack:self.pathView];
    } else {
        self.data=[[InspectionPath pathsForInspection:self.inspectionID] mutableCopy];
        [self.pathView setHidden:NO];
        [self.view bringSubviewToFront:self.pathView];
    }
    [self.tableRecordList reloadData];
}

- (void)setInspectionDelegate:(NSString *)aInspectionID{
    self.inspectionID = aInspectionID;
    [self loadInspectionInfo];
}

- (void)popBackToMainView{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addObserverToKeyBoard{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
-(void)toConstruction:(NSString *)str{
    UIStoryboard *mainStoryboard =[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    //实例化Identifier为"construction"的视图控制器
    InspectionConstructionViewController * construction = [mainStoryboard instantiateViewControllerWithIdentifier:@"construction"];
    [construction setRoadVC:self];
    //为视图控制器设置过渡类型
//    construction.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    //为视图控制器设置显示样式
//    construction.modalPresentationStyle = UIModalPresentationFullScreen;
    //显示视图
    [self.navigationController pushViewController:construction animated:YES];
}

#pragma mark - own methods
//软键盘隐藏，恢复左下scrollview位置
- (void)keyboardWillHide:(NSNotification *)aNotification{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    if (self.state == kRecord) {
        CGRect newFrame           = self.textViewRemark.frame;
        newFrame.origin.y         = 454;
        newFrame.size.height      = 230;
        //    CGFloat offset=self.textViewRemark.frame.origin.y-newFrame.origin.y;
        self.textViewRemark.frame = newFrame;
        
        CGRect viewFrame   = self.view.frame;
        viewFrame.origin.y = 60;
        self.view.frame    = viewFrame;
    }
    if(self.selectedRecordIndex.row){
        [self saveRemark];
    }
    [UIView commitAnimations];
}

//软键盘出现，上移scrollview至左上，防止编辑界面被阻挡
- (void)keyboardWillShow:(NSNotification *)aNotification{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    if (self.state == kRecord) {
        NSValue *keyboardRectAsObject=[[aNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        CGRect keyboardRect;
        [keyboardRectAsObject getValue:&keyboardRect];
        
        CGRect newFrame    = self.textViewRemark.frame;
        CGRect viewFrame   = self.view.frame;
        viewFrame.origin.y = keyboardEndFrame.size.height*-1+100;
        newFrame.origin.y  = 66;
        //newFrame.size.height = self.view.frame.size.height - (self.view.frame.origin.y + newFrame.origin.y) - keyboardEndFrame.size.width-5;
        //CGFloat offset=self.textViewRemark.frame.origin.y-newFrame.origin.y;
        NSLog(@"gao :%f;kuan:%f",newFrame.size.height,newFrame.size.width );
        CGFloat shadw             = 0.0;
        //self.inspectionSeg.alpha=shadw;
        // self.view.frame=viewFrame;
        self.textViewRemark.frame = newFrame;
        [self.view bringSubviewToFront:self.textViewRemark];
    }
    [UIView commitAnimations];
}


- (IBAction)btnSaveRemark:(UIButton *)sender {
    if (self.state == kRecord) {
        [self saveRemark];
    } else {
        if (![self.textCheckTime.text isEmpty] && ![self.textStationName.text isEmpty] && ![self.textCheckStatus.text isEmpty]) {
            
            NSIndexPath *index = [self.tableRecordList indexPathForSelectedRow];
            InspectionPath *newPath;
            if (index==nil) {
                newPath = [InspectionPath newDataObjectWithEntityName:@"InspectionPath"];
                [self.data addObject:newPath];
            } else {
                newPath = [self.data objectAtIndex:index.row];
            }
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            newPath.checktime    = [dateFormatter dateFromString:self.textCheckTime.text];
            newPath.stationname  = self.textStationName.text;
            newPath.inspectionid = self.inspectionID;
            [[AppDelegate App] saveContext];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否生成巡查记录?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
            [alert show];
            
        }
        [self reloadRecordData];
    }
    [self.view endEditing:YES];
}
- (IBAction)btnToFujian:(id)sender{
    
    /*if(self.constructionID == nil || [self.constructionID isEmpty]){
     UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择一条物料检查记录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alter show];
     return;
     }*/
    UIStoryboard *board            = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AttachmentViewController *next = [board instantiateViewControllerWithIdentifier:@"AttachmentViewController"];
    [next setValue:self.RecordID forKey:@"constructionId"];
    [self.navigationController pushViewController:next animated:YES];
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        //过站记录生成巡查记录
        InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
        inspectionRecord.relationid     = @"0";
        inspectionRecord.inspection_id  = self.inspectionID;
        inspectionRecord.roadsegment_id = @"0";
        
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        inspectionRecord.start_time=[dateFormatter dateFromString:self.textCheckTime.text];
        [dateFormatter setDateFormat:DATE_FORMAT_HH_MM];
        
        NSString *timeString=[dateFormatter stringFromDate:inspectionRecord.start_time];
        
        NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"Systype" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code_name == %@ && type_value == %@",@"过站状况", self.textCheckStatus.text]];
        NSArray *result     = [context executeFetchRequest:fetchRequest error:nil];
        NSString *strFormat = @"%@ %@";
        if (result && [result count]>0) {
            NSString *remark = [[result objectAtIndex:0] remark];
            if (![remark isEmpty]) {
                strFormat = [NSString stringWithFormat:@"%@ %@", @"%@", [remark stringByReplacingOccurrencesOfString:@"[站]" withString:@"%@"]];
            }
        }
        NSString *remark=[NSString stringWithFormat:strFormat, timeString, self.textStationName.text];
        inspectionRecord.remark = remark;
        [[AppDelegate App] saveContext];
        [self reloadRecordData];
    }else{
        //[alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    
}

- (void)saveRemark{
    if (![self.textViewRemark.text isEmpty]) {
        //通过tv 确定选择项
        /*
         NSIndexPath *indexPath=[self.tableRecordList indexPathForSelectedRow];
         if (indexPath!=nil) {
         InspectionRecord *record=[self.data objectAtIndex:indexPath.row];
         record.remark = self.textViewRemark.text;
         [[AppDelegate App] saveContext];
         [self.tableRecordList beginUpdates];
         [self.tableRecordList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
         [self.tableRecordList endUpdates];
         }
         */
        //通过记录选择项
        InspectionRecord *record=[self.data objectAtIndex:self.selectedRecordIndex.row];
        record.remark = self.textViewRemark.text;
        [[AppDelegate App] saveContext];
        [self.tableRecordList beginUpdates];
        [self.tableRecordList reloadRowsAtIndexPaths:@[self.selectedRecordIndex] withRowAnimation:UITableViewRowAnimationMiddle];
        [self.tableRecordList endUpdates];
    }
}

- (IBAction)btnInpectionList:(id)sender {
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        InspectionListViewController *acPicker=[self.storyboard instantiateViewControllerWithIdentifier:@"InspectionList"];
        acPicker.delegate = self;
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:acPicker];
        [self.pickerPopover setPopoverContentSize:CGSizeMake(270, 352)];
        [self.pickerPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        acPicker.popover = self.pickerPopover;
    }
}
- (IBAction)btnAddNew:(id)sender {
    if (self.state == kRecord) {
        [self performSegueWithIdentifier:@"toAddNewInspectionRecord" sender:nil];
    } else {
        for (UITextField *textField in self.pathView.subviews) {
            if ([textField isKindOfClass:[UITextField class]]) {
                textField.text = @"";
            }
        }
        NSIndexPath *index = [self.tableRecordList indexPathForSelectedRow];
        if (index) {
            [self.tableRecordList deselectRowAtIndexPath:index animated:YES];
        }
    }
}

- (IBAction)btnDeliver:(UIButton *)sender {
    if (self.isCurrentInspection) {
        [self performSegueWithIdentifier:@"toInspectionOut" sender:nil];
    } else {
        self.isCurrentInspection = YES;
        [UIView transitionWithView:self.view
                          duration:0.3
                           options:UIViewAnimationCurveLinear
                        animations:^{
                            CGRect rect     = self.uiButtonDeliver.frame;
                            rect.size.width = 72;
                            [self.uiButtonDeliver setFrame:rect];
                            [sender setTitle:@"交班" forState:UIControlStateNormal];
                            [self.uiButtonAddNew setAlpha:1.0];
                            [self.uiButtonSave setAlpha:1.0];
                        }
                        completion:^(BOOL finish){
                            [self.uiButtonSave setEnabled:YES];
                            [self.uiButtonAddNew setEnabled:YES];
                        }];
        self.inspectionID=[[NSUserDefaults standardUserDefaults] valueForKey:INSPECTIONKEY];
        [self loadInspectionInfo];
    }
}

- (IBAction)segSwitch:(id)sender {
    //add by 李晓明 2013.05.09
    //选择switch的时候，取消焦点
    [self.textViewRemark resignFirstResponder];
    if (self.inspectionSeg.selectedSegmentIndex == 0) {
        self.state = kRecord;
    } else {
        self.state    = kPath;
        self.RecordID = nil;
    }
    [self reloadRecordData];
}

- (IBAction)selectionStation:(id)sender {
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        InspectionCheckPickerViewController *icPicker=[self.storyboard instantiateViewControllerWithIdentifier:@"InspectionCheckPicker"];
        icPicker.pickerState = kStation;
        inspectionState      = kStation;
        icPicker.delegate    = self;
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:icPicker];
        [self.pickerPopover presentPopoverFromRect:[sender frame] inView:self.pathView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        icPicker.pickerPopover = self.pickerPopover;
    }
}

- (IBAction)selectTime:(id)sender {
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        DateSelectController *datePicker=[self.storyboard instantiateViewControllerWithIdentifier:@"datePicker"];
        datePicker.delegate   = self;
        datePicker.pickerType = 1;
        [datePicker showdate:self.textCheckTime.text];
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:datePicker];
        CGRect rect = [self.view convertRect:[sender frame] fromView:self.pathView];
        [self.pickerPopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        datePicker.dateselectPopover = self.pickerPopover;
    }
}

- (IBAction)selectCheckStatus:(id)sender{
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        InspectionCheckPickerViewController *icPicker=[self.storyboard instantiateViewControllerWithIdentifier:@"InspectionCheckPicker"];
        icPicker.pickerState = kStationCheckStatus;
        inspectionState      = kStationCheckStatus;
        icPicker.delegate    = self;
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:icPicker];
        [self.pickerPopover presentPopoverFromRect:[sender frame] inView:self.pathView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        icPicker.pickerPopover = self.pickerPopover;
    }
}

- (void)loadInspectionInfo{
    NSArray *temp=[Inspection inspectionForID:self.inspectionID];
    if (temp.count>0) {
        Inspection *inspection=[temp objectAtIndex:0];
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        self.labelInspectionInfo.text=[[NSString alloc] initWithFormat:@"%@   %@   巡查车辆:%@   巡查人:%@   记录人:%@",[formatter stringFromDate:inspection.date_inspection],inspection.weather,inspection.carcode,inspection.inspectionor_name,inspection.recorder_name];
    }
    for (UITextField *textField in self.pathView.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            textField.text = @"";
        }
    }
    NSIndexPath *index = [self.tableRecordList indexPathForSelectedRow];
    if (index) {
        [self.tableRecordList deselectRowAtIndexPath:index animated:YES];
    }
    self.textViewRemark.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self reloadRecordData];
}

- (void)setCurrentInspection:(NSString *)inspectionID{
    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationCurveLinear
                    animations:^{
                        CGRect rect     = self.uiButtonDeliver.frame;
                        rect.size.width = 126;
                        [self.uiButtonDeliver setFrame:rect];
                        [self.uiButtonDeliver setTitle:@"返回当前巡查" forState:UIControlStateNormal];
                        [self.uiButtonAddNew setAlpha:0.0];
                        [self.uiButtonSave setAlpha:0.0];
                    }
                    completion:^(BOOL finish){
                        [self.uiButtonSave setEnabled:NO];
                        [self.uiButtonAddNew setEnabled:NO];
                    }];
    self.isCurrentInspection = NO;
    self.inspectionID        = inspectionID;
    [self loadInspectionInfo];
}

- (void)setCheckText:(NSString *)checkText{
    if (self.state == kPath) {
        if (inspectionState == kStationCheckStatus) {
            self.textCheckStatus.text = checkText;
        }else{
            self.textStationName.text = checkText;
        }
    }
}

- (void)setDate:(NSString *)date{
    self.textCheckTime.text = date;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return NO;
}
/*这是西部沿海的
- (void) createRecodeByCaseID:(NSString *)caseID{
    if ([caseID isEmpty]) {
        return;
    }
    CaseInfo *caseInfo              = [CaseInfo caseInfoForID:caseID];
    CaseProveInfo *proveInfo        = [CaseProveInfo proveInfoForCase:caseID];
    NSString *desc                  = [LawbreakingAction LawbreakingActionCaptionForID:proveInfo.case_desc_id];
    //CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:caseID];
    Citizen *citizen                = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:caseID];
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    inspectionRecord.roadsegment_id = caseInfo.roadsegment_id;
    inspectionRecord.location       = caseInfo.place;
    inspectionRecord.station        = caseInfo.station_start;
    inspectionRecord.inspection_id  = self.inspectionID;
    inspectionRecord.relationid     = @"0";
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    inspectionRecord.start_time = caseInfo.happen_date;
    
    [dateFormatter setDateFormat:DATE_FORMAT_HH_MM_COLON];
    NSString *timeString=[dateFormatter stringFromDate:inspectionRecord.start_time];
    NSMutableString *remark=[[NSMutableString alloc] initWithFormat:@"%@ 巡至%@往%@方向K%@+%@m处时，发现%@驾驶%@%@在%@发生交通事故，",timeString, [RoadSegment roadNameFromSegment:caseInfo.roadsegment_id], caseInfo.side, [caseInfo station_start_km], [caseInfo station_start_m], citizen.party, citizen.automobile_number, citizen.automobile_pattern, caseInfo.place];
    [remark appendFormat:@"%@接报，%@到场，",timeString,timeString];
    //[remark appendFormat:@"经现场勘验检查认定%@的事实为,",desc]; //NSString [alloc stringByAppendingFormat:@"经现场勘验检查认定（案由）的事实为,"
    [remark appendString:@"经现场勘验检查认定"];
    [remark appendString:desc];
    [remark appendString:@"的事实为,"];
    if ([caseInfo.fleshwound_sum intValue]==0 && [caseInfo.badwound_sum intValue]==0 && [caseInfo.death_sum intValue]==0) {
        [remark appendString:@"无人员伤亡，"];
    }else{
        [remark appendFormat:@"轻伤%@人，重伤%@人，死亡%@人，", caseInfo.fleshwound_sum, caseInfo.badwound_sum, caseInfo.death_sum];
    }
    NSArray *deformArray=[CaseDeformation deformationsForCase:caseID forCitizen:citizen.automobile_number];
    if (deformArray.count>0) {
        NSString *deformsString=@"";
        float   all = 0;
        for (CaseDeformation *deform in deformArray) {
            NSString *roadSizeString=[deform.rasset_size stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([roadSizeString isEmpty]) {
                roadSizeString=@"";
            } else {
                roadSizeString=[NSString stringWithFormat:@"（%@）",roadSizeString];
            }
            NSString *remarkString=[deform.remark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([remarkString isEmpty]) {
                remarkString=@"";
            } else {
                remarkString=[NSString stringWithFormat:@"（%@）",remarkString];
            }
            NSString *quantity=[[NSString alloc] initWithFormat:@"%.2f",deform.quantity.floatValue];
            NSCharacterSet *zeroSet=[NSCharacterSet characterSetWithCharactersInString:@".0"];
            all += deform.total_price.floatValue;
            quantity=[quantity stringByTrimmingTrailingCharactersInSet:zeroSet];
            deformsString=[deformsString stringByAppendingFormat:@"、%@%@%@%@%@",deform.roadasset_name,roadSizeString,quantity,deform.unit,remarkString];
        }
        NSCharacterSet *charSet=[NSCharacterSet characterSetWithCharactersInString:@"、"];
        deformsString=[deformsString stringByTrimmingCharactersInSet:charSet];
        //[deformsString appendFormat:@",%@。",[[NSString alloc] initWithFormat:@"%.2f",all]];
        [remark appendFormat:@"损坏路产如下：%@。",deformsString];
        [remark appendFormat:@"共计金额%@元。",[[NSString alloc] initWithFormat:@"%.2f",all]];
        
        // [remark stringByAppendingFormat:@"%@接报，%@到场，",timeString,timeString];
    } else {
        [remark appendString:@"无路产损坏。"];
    }
    [remark appendFormat:@"现场开具路产文书由事主签认。%@拖车到场，%@交警到场，%@处理完毕，已拍照，已报监控。",timeString,timeString,timeString];
    [remark appendFormat:@"已立案处理（案号：%@高赔（%@）第（%@）号）。", [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.case_mark2, [caseInfo full_case_mark3]];
    
    
    NSMutableString *adminis_remark=[[NSMutableString alloc] initWithFormat:@"%@,%@发现%@%@%@%@在%@%@K%@+%@m %@处%@%@。现场已制作法律文书由施工负责人签认，已拍照取证，已报监控中心。",timeString, caseInfo.case_type, citizen.address,citizen.org_name,citizen.org_principal_duty,citizen.party,  [RoadSegment roadNameFromSegment:caseInfo.roadsegment_id], caseInfo.side, [caseInfo station_start_km], [caseInfo station_start_m],caseInfo.place, desc,caseInfo.peccancy_type];
    //[adminis_remark appendFormat:@"已立案处理（案号：%@高赔（%@）第（%@）号）。", [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.case_mark2, [caseInfo full_case_mark3]];
    if(caseInfo.case_type_id.intValue==11){
        
        inspectionRecord.remark = remark;
    }else{
        inspectionRecord.remark = adminis_remark;
    }
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
}
*/
- (void) createRecodeByCaseID:(NSString *)caseID{
    if ([caseID isEmpty]) {
        return;
    }
    CaseInfo *caseInfo = [CaseInfo caseInfoForID:caseID];
    //CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:caseID];
    Citizen *citizen = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:caseID];
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    inspectionRecord.roadsegment_id= caseInfo.roadsegment_id;
    inspectionRecord.location= caseInfo.place;
    inspectionRecord.station = caseInfo.station_start;
    inspectionRecord.inspection_id = self.inspectionID;
    inspectionRecord.relationid = @"0";
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    inspectionRecord.start_time = caseInfo.happen_date;
    
    [dateFormatter setDateFormat:DATE_FORMAT_HH_MM];
    NSString *timeString=[dateFormatter stringFromDate:inspectionRecord.start_time];
//    NSMutableString *remark=[[NSMutableString alloc] initWithFormat:@"%@巡查至%@往%@方向K%@+%@处，发现%@驾驶%@%@在%@发生交通事故，",timeString, [RoadSegment roadNameFromSegment:caseInfo.roadsegment_id], caseInfo.side, [caseInfo station_start_km], [caseInfo station_start_m], citizen.party, citizen.automobile_number, citizen.automobile_pattern, caseInfo.place];
//    当班人员立即做好安全措施，临时封闭超车道，快车道及行车道正常通行。经了解：粤A12345小轿车行驶至K...+...m处因（操作不当、车辆故障、车轮爆胎撞向左侧（护栏、防撞墙）发生交通事故，现场无人员伤亡，车辆一般损坏，（有、无）损坏公路路产：经与当事人现场勘察损坏路产如下：单面波形钢板xxx片、立柱xxx跟、防阻块xxx个，索赔金额xxx元整车辆一般损坏，报监控中心通知交警及拯救到场处理。xxx时xxx分交警到达现场、xxx时xxx分拯救到达现场、xxx时xxx分事故处理完毕，回收交安设施解封超车道，交通恢复正常，报监控中心后做好记录继续巡查。（赔补偿案件制作）
    
    NSMutableString *remark=[[NSMutableString alloc] initWithFormat:@"%@ 巡查至%@K%@+%@处，发现%@发生交通事故，当班人员立即做好安全措施，临时封闭%@,其他行车道正常通行。经了解：%@行驶至K%@+%@处因%@发生交通事故，",timeString,caseInfo.side,[caseInfo station_start_km], [caseInfo station_start_m],caseInfo.place,caseInfo.place,citizen.automobile_number,[caseInfo station_start_km],[caseInfo station_start_m],caseInfo.case_reason];
    [remark appendString:@"现场"];
    if ([caseInfo.fleshwound_sum intValue]==0 && [caseInfo.badwound_sum intValue]==0 && [caseInfo.death_sum intValue]==0) {
        [remark appendString:@"无人员伤亡，"];
    }else{
        if(caseInfo.fleshwound_sum.integerValue != 0){
            [remark appendFormat:@"轻伤%@人，",caseInfo.fleshwound_sum];
        }
        if (caseInfo.badwound_sum.integerValue != 0) {
            [remark appendFormat:@"重伤%@人，",caseInfo.badwound_sum];
        }
        if (caseInfo.death_sum.integerValue != 0) {
            [remark appendFormat:@"死亡%@人，", caseInfo.death_sum];
        }
    }
    NSString * Car_bad_desc = citizen.bad_desc;
    if (![Car_bad_desc containsString:@"损坏"]) {
        Car_bad_desc = [Car_bad_desc stringByAppendingFormat:@"损坏"];
    }
    if ([Car_bad_desc isEqualToString:@"损毁损坏"]) {
        Car_bad_desc = @"损毁";
    }
    
    [remark appendFormat:@"车辆%@，",Car_bad_desc];
    NSArray *deformArray=[CaseDeformation deformationsForCase:caseID forCitizen:citizen.automobile_number];
    if (deformArray.count>0) {
        NSString *deformsString=@"";
        for (CaseDeformation *deform in deformArray) {
            NSString *roadSizeString=[deform.rasset_size stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([roadSizeString isEmpty]) {
                roadSizeString=@"";
            } else {
                roadSizeString=[NSString stringWithFormat:@"（%@）",roadSizeString];
            }
            NSString *remarkString=[deform.remark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([remarkString isEmpty]) {
                remarkString=@"";
            } else {
                remarkString=[NSString stringWithFormat:@"（%@）",remarkString];
            }
            NSString *quantity=[[NSString alloc] initWithFormat:@"%.2f",deform.quantity.floatValue];
            //                    NSCharacterSet *zeroSet=[NSCharacterSet characterSetWithCharactersInString:@".0"];
            //                    quantity=[quantity stringByTrimmingTrailingCharactersInSet:zeroSet];
            for(int i =0;i<3;i++){
                NSString *last = [quantity substringFromIndex:quantity.length-1];
                if([last isEqualToString:@"0"] || [last isEqualToString:@"."]){
                    quantity = [quantity substringToIndex:quantity.length-1];
                }else{
                    break;
                }
            }
            deformsString=[deformsString stringByAppendingFormat:@"、%@%@%@%@%@",deform.roadasset_name,roadSizeString,quantity,deform.unit,remarkString];
        }
        NSCharacterSet *charSet=[NSCharacterSet characterSetWithCharactersInString:@"、"];
        deformsString=[deformsString stringByTrimmingCharactersInSet:charSet];
        [remark appendFormat:@"有损坏公路路产：经与当事人现场勘察损坏路产如下：%@，",deformsString];
    } else {
        [remark appendString:@"无路产损坏，"];
    }
    NSArray *deformations = [CaseDeformation deformationsForCase:caseID];
    double summary=[[deformations valueForKeyPath:@"@sum.total_price.doubleValue"] doubleValue];
    [remark appendFormat:@"索赔金额%.2f元整车辆%@，报监控中心通知交警及拯救到场处理。xxx时xxx分交警到达现场、xxx时xxx分拯救到达现场、xxx时xxx分事故处理完毕，回收交安设施解封%@，交通恢复正常，报监控中心后做好记录继续巡查。",summary,Car_bad_desc,caseInfo.place];
    
//    [remark appendFormat:@"回收交安设施解封%@，交通恢复正常，报监控中心后做好记录继续巡查。",caseInfo.place];
    
//    [remark appendFormat:@"已立案处理（案号：%@高赔（%@）第（%@）号）。", [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.case_mark2, [caseInfo full_case_mark3]];
    inspectionRecord.remark=remark;
    
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
}

- (void) createRecodeByShiGongCheckID:(NSString *)shiGongCheckID{
    if ([shiGongCheckID isEmpty]) {
        return;
    }
    CaseInfo *caseInfo       = [CaseInfo caseInfoForID:shiGongCheckID];
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:shiGongCheckID];
    NSString *desc           = [LawbreakingAction LawbreakingActionCaptionForID:proveInfo.case_desc_id];
    //CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:caseID];
    Citizen *citizen         = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:shiGongCheckID];
    MaintainPlanCheck *checkInfo=[[MaintainPlanCheck maintainCheckForID:shiGongCheckID] objectAtIndex:0];
    
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    /*
     inspectionRecord.roadsegment_id = caseInfo.roadsegment_id;
     inspectionRecord.location       = caseInfo.place;
     inspectionRecord.station        = caseInfo.station_start;
     inspectionRecord.inspection_id  = self.inspectionID;
     inspectionRecord.relationid     = @"0";
     
     
     NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
     [dateFormatter setLocale:[NSLocale currentLocale]];
     inspectionRecord.start_time = caseInfo.happen_date;
     
     [dateFormatter setDateFormat:DATE_FORMAT_HH_MM_COLON];
     NSString *timeString=[dateFormatter stringFromDate:inspectionRecord.start_time];
     NSMutableString *remark=[[NSMutableString alloc] initWithFormat:@"%@巡至%@往%@方向K%@+%@m处时，发现%@驾驶%@%@在%@发生交通事故，",timeString, [RoadSegment roadNameFromSegment:caseInfo.roadsegment_id], caseInfo.side, [caseInfo station_start_km], [caseInfo station_start_m], citizen.party, citizen.automobile_number, citizen.automobile_pattern, caseInfo.place];
     [remark appendFormat:@"%@接报，%@到场，",timeString,timeString];
     inspectionRecord.remark = remark;
     */
    inspectionRecord.start_time = checkInfo.check_date;
    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
    [formater setLocale:[NSLocale currentLocale]];
    formater.dateFormat=@"hh:mm";
    NSString * remark=[formater stringFromDate:checkInfo.check_date];
    remark=[ NSString stringWithFormat:@"%@ 检查%@",  remark  ,checkInfo.checkitem1];
    inspectionRecord.remark        = remark ;
    inspectionRecord.inspection_id = self.inspectionID;
    inspectionRecord.relationid    = @"0";
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
}
//构造物检查的照片
- (NSArray *)inspectionphoto:(NSString *)myid{
    return [[CasePhoto casePhotos:myid]mutableCopy];
}
//构造物检查描述
- (void)createRecodeInspectionConstruction:(InspectionConstruction *)inspectionconstruction{
    NSArray * array  = [self inspectionphoto:inspectionconstruction.myid];
    NSString *remark;
    if ([array count] > 0) {
        for (int i = 0; i< [array count]; i++) {
            CasePhoto * casePhoto = [array objectAtIndex:i];
//            if ([casePhoto.remark containsString:@"情况正常。"]) {
//                continue;
//            }else{
//                remark = casePhoto.remark;       //            构造物巡查描述
//            }
            remark = [[NSUserDefaults standardUserDefaults]objectForKey:casePhoto.myid];
            if (remark.length>0) {
                break;
            }
        }
    }
    //有异常才显示巡查
    if (remark.length || ([remark containsString:@"K"] && [remark containsString:@"M"])) {
        InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
        inspectionRecord.myid           = inspectionconstruction.myid;
        if ([remark containsString:@"K"] && [remark containsString:@"M"]) {
            NSRange rangek = [remark rangeOfString:@"K"];
            NSRange rangem = [remark rangeOfString:@"M"];
            NSRange range =  NSMakeRange(rangek.location+1,rangem.location -rangek.location -1);
            NSString * station = [[remark substringWithRange:range]stringByReplacingOccurrencesOfString:@"+" withString:@""] ;
            inspectionRecord.station = @([station integerValue]);
        }else if([remark containsString:@"+"]){
            NSArray * Numarray = [remark componentsSeparatedByString:@"+"];
            NSString * station = [NSString stringWithFormat:@"%ld%3ld",[Numarray[0] integerValue],[Numarray[1] integerValue]];
            inspectionRecord.station = @([station integerValue]);
        }else{
            inspectionRecord.station = nil;
        }
        inspectionRecord.roadsegment_id = @"0";
        //    inspectionRecord.fix            = inspectionconstruction.fix;
        inspectionRecord.inspection_id  = self.inspectionID;
        inspectionRecord.relationid     = @"0";
        //    inspectionRecord.start_time     = inspectionconstruction.happentime;
        //    inspectionRecord.station        = inspectionconstruction.station;
        //    NSString* stationString         = [NSString stringWithFormat:@"K%d+%dM", inspectionconstruction.station.integerValue/1000, inspectionconstruction.station.integerValue%1000];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        NSString *timeStr = [dateFormatter stringFromDate:inspectionconstruction.inspectiondate];
        inspectionRecord.remark = [NSString stringWithFormat:@"%@%@",timeStr,remark];
//        [dateFormatter setDateFormat:@"HH:mm"];
//        NSString *timestartStr = [dateFormatter stringFromDate:inspectionconstruction.timestart1];
        inspectionRecord.start_time = inspectionconstruction.timestart1;
        [[AppDelegate App] saveContext];
        [self reloadRecordData];
    }
}
- (void) createRecodeByTrafficRecord:(TrafficRecord *)trafficRecord{
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    //要把交通事故的照片带过来
    inspectionRecord.myid           = trafficRecord.myid;
    inspectionRecord.roadsegment_id = @"0";
    inspectionRecord.fix            = trafficRecord.fix;
    inspectionRecord.inspection_id  = self.inspectionID;
    inspectionRecord.relationid     = @"0";
    inspectionRecord.start_time     = trafficRecord.happentime;
    inspectionRecord.station        = trafficRecord.station;
    NSString* stationString         = [NSString stringWithFormat:@"K%d+%dM", trafficRecord.station.integerValue/1000, trafficRecord.station.integerValue%1000];
    NSString *remark                = @"";
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    NSString *timeStr = [dateFormatter stringFromDate:inspectionRecord.start_time];
    if ([trafficRecord.infocome isEqualToString:@"交警"]) {
        //        remark = [NSString stringWithFormat:@"%@接交警报%@K%@路段有交通事故，路政人员立即前往。", timeStr, inspectionRecord.fix, trafficRecord.station];
        remark = [NSString stringWithFormat:@"%@ 接交警报方向%@发现交通事故", timeStr, stationString];
    }else if ([trafficRecord.infocome isEqualToString:@"监控"]) {
        remark = [NSString stringWithFormat:@"%@ 接监控中心报方向%@发现交通事故，", timeStr, stationString];
    }else if ([trafficRecord.infocome isEqualToString:@"路政"]) {
        //        remark = [NSString stringWithFormat:@"%@巡查至%@K%@路段发现有交通事故。", timeStr, inspectionRecord.fix, trafficRecord.station];
        remark = [NSString stringWithFormat:@"%@ 巡查至方向%@发现交通事故，", timeStr, stationString];
    }
    
    if (trafficRecord.car) {
        remark = [remark stringByAppendingFormat:@"肇事车辆：%@", trafficRecord.car];
    }
    
    if (trafficRecord.traffic_flow) {
        remark = [remark stringByAppendingFormat:@"，交通状况：%@", trafficRecord.traffic_flow];
    }
    
    if (trafficRecord.car_type) {
        remark = [remark stringByAppendingFormat:@"，车型：%@", trafficRecord.car_type];
    }
    
    if (trafficRecord.infocome) {
        remark = [remark stringByAppendingFormat:@"，事故消息来源：%@", trafficRecord.infocome];
    }
    
    if (trafficRecord.case_reason) {
        remark = [remark stringByAppendingFormat:@"，事故原因：%@", trafficRecord.case_reason];
    }
    
    if (trafficRecord.fix) {
        remark = [remark stringByAppendingFormat:@"，事故方向：%@", trafficRecord.fix];
    }
    
    if (stationString) {
        remark = [remark stringByAppendingFormat:@"，事故发生地点（桩号）：%@", stationString];
    }
    
    if (trafficRecord.property) {
        remark = [remark stringByAppendingFormat:@"，事故性质：%@", trafficRecord.property];
    }
    
    if (trafficRecord.type) {
        remark = [remark stringByAppendingFormat:@"，事故分类：%@", trafficRecord.type];
    }
    
    if (trafficRecord.roadsituation) {
        remark = [remark stringByAppendingFormat:@"，事故封道情况：%@", trafficRecord.roadsituation];
    }
    
    if (trafficRecord.wdsituation) {
        remark = [remark stringByAppendingFormat:@"，事故伤亡情况：%@", trafficRecord.wdsituation];
    }
    
    if (trafficRecord.lost) {
        remark = [remark stringByAppendingFormat:@"，路产损失金额：%@", trafficRecord.lost];
    }
    
    if (trafficRecord.isend) {
        remark = [remark stringByAppendingFormat:@"，是否结案：%@", trafficRecord.isend];
    }
    
    if (trafficRecord.paytype) {
        remark = [remark stringByAppendingFormat:@"，索赔方式：%@", trafficRecord.paytype];
    }
    
    if (trafficRecord.zjstart) {
        remark = [remark stringByAppendingFormat:@"，拯救处理开始时间：%@", [dateFormatter stringFromDate:trafficRecord.zjstart]];
    }
    
    if (trafficRecord.zjend) {
        remark = [remark stringByAppendingFormat:@"，拯救处理结束时间：%@", [dateFormatter stringFromDate:trafficRecord.zjend]];
    }
    
    if (trafficRecord.zjend) {
        remark = [remark stringByAppendingFormat:@"，拯救处理结束时间：%@", [dateFormatter stringFromDate:trafficRecord.zjend]];
    }
    
    if (trafficRecord.clstart) {
        remark = [remark stringByAppendingFormat:@"，事故处理开始时间：%@", [dateFormatter stringFromDate:trafficRecord.clstart]];
    }
    
    if (trafficRecord.clend ) {
        remark = [remark stringByAppendingFormat:@"，事故处理结束时间：%@", [dateFormatter stringFromDate:trafficRecord.clend]];
    }
    
    if (trafficRecord.remark) {
        remark = [remark stringByAppendingFormat:@"，备注：%@", trafficRecord.remark];
    }
    
    remark                  = [remark stringByAppendingFormat:@"。"];
    inspectionRecord.remark = remark;
    
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
}
- (void) createRecodeByDynamicInfo:(RoadWayClosed *)DynamicInfo{
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    inspectionRecord.roadsegment_id = DynamicInfo.roadsegment_id;    inspectionRecord.fix = DynamicInfo.fix;
    inspectionRecord.inspection_id  = self.inspectionID;
    inspectionRecord.relationid     = DynamicInfo.myid;//@"0";
    inspectionRecord.start_time     = DynamicInfo.time_start;
    inspectionRecord.station        = DynamicInfo.station_start;
    //NSString* stationString = [NSString stringWithFormat:@"K%d+%dM", DynamicInfo.station_start.integerValue/1000, DynamicInfo.station_start.integerValue%1000];
    NSString *remark                = DynamicInfo.closed_reason;
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    
    inspectionRecord.remark = remark;
    
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
}
- (void) createRecodeByBaoxianCase:(NSString *)caseID{
    if ([caseID isEmpty]) {
        return;
    }
    CaseInfo *caseInfo              = [CaseInfo caseInfoForID:caseID];
    CaseProveInfo *proveInfo        = [CaseProveInfo proveInfoForCase:caseID];
    NSString *desc                  = [LawbreakingAction LawbreakingActionCaptionForID:proveInfo.case_desc_id];
    //CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:caseID];
    Citizen *citizen                = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:caseID];
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    inspectionRecord.roadsegment_id = caseInfo.roadsegment_id;
    inspectionRecord.location       = caseInfo.place;
    inspectionRecord.station        = caseInfo.station_start;
    inspectionRecord.inspection_id  = self.inspectionID;
    inspectionRecord.relationid     = @"0";
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    inspectionRecord.start_time = caseInfo.happen_date;
    
    [dateFormatter setDateFormat:DATE_FORMAT_HH_MM_COLON];
    NSString *timeString=[dateFormatter stringFromDate:inspectionRecord.start_time];
    NSMutableString *remark=[[NSMutableString alloc] initWithFormat:@"%@ 巡至%@往%@方向K%@+%@m处时，发生",timeString, [RoadSegment roadNameFromSegment:caseInfo.roadsegment_id], caseInfo.side, [caseInfo station_start_km], [caseInfo station_start_m]];
    //[remark appendFormat:@"%@接报，%@到场，",timeString,timeString];
    //[remark appendFormat:@"经现场勘验检查认定%@的事实为,",desc]; //NSString [alloc stringByAppendingFormat:@"经现场勘验检查认定（案由）的事实为,"
    //[remark appendString:@"经现场勘验检查认定"];
    [remark appendString:desc];
    NSArray *deformArray=[CaseDeformation deformationsForCase:caseID forCitizen:@"保险案件"];
    if (deformArray.count>0) {
        NSString *deformsString=@"";
        float   all = 0;
        for (CaseDeformation *deform in deformArray) {
            NSString *roadSizeString=[deform.rasset_size stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([roadSizeString isEmpty]) {
                roadSizeString=@"";
            } else {
                roadSizeString=[NSString stringWithFormat:@"（%@）",roadSizeString];
            }
            NSString *remarkString=[deform.remark stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([remarkString isEmpty]) {
                remarkString=@"";
            } else {
                remarkString=[NSString stringWithFormat:@"（%@）",remarkString];
            }
            NSString *quantity=[[NSString alloc] initWithFormat:@"%.2f",deform.quantity.floatValue];
            //                    NSCharacterSet *zeroSet=[NSCharacterSet characterSetWithCharactersInString:@".0"];
            //                    quantity=[quantity stringByTrimmingTrailingCharactersInSet:zeroSet];
            for(int i =0;i<3;i++){
                NSString *last = [quantity substringFromIndex:quantity.length-1];
                if([last isEqualToString:@"0"] || [last isEqualToString:@"."]){
                    quantity = [quantity substringToIndex:quantity.length-1];
                }else{
                    break;
                }
            }
            all += deform.total_price.floatValue;
//            quantity=[quantity stringByTrimmingTrailingCharactersInSet:zeroSet];
            deformsString=[deformsString stringByAppendingFormat:@"、%@%@%@%@%@",deform.roadasset_name,roadSizeString,quantity,deform.unit,remarkString];
        }
        NSCharacterSet *charSet=[NSCharacterSet characterSetWithCharactersInString:@"、"];
        deformsString=[deformsString stringByTrimmingCharactersInSet:charSet];
        //[deformsString appendFormat:@",%@。",[[NSString alloc] initWithFormat:@"%.2f",all]];
        [remark appendFormat:@"路产损失如下：%@。",deformsString];
        [remark appendFormat:@"共计金额%@元。",[[NSString alloc] initWithFormat:@"%.2f",all]];
        
        // [remark stringByAppendingFormat:@"%@接报，%@到场，",timeString,timeString];
    } else {
        [remark appendString:@"无路产损坏。"];
    }
    //[remark appendFormat:@"现场开具路产文书由事主签认。%@拖车到场，%@交警到场，%@处理完毕，已拍照，已报监控。",timeString,timeString,timeString];
    //[remark appendFormat:@"已立案处理（案号：%@高赔（%@）第（%@）号）。", [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.case_mark2, [caseInfo full_case_mark3]];
    
    
    //NSMutableString *adminis_remark=[[NSMutableString alloc] initWithFormat:@"%@,%@发现%@%@%@%@在%@%@K%@+%@m %@处%@%@。现场已制作法律文书由施工负责人签认，已拍照取证，已报监控中心。",timeString, caseInfo.case_type, citizen.address,citizen.org_name,citizen.org_principal_duty,citizen.party,  [RoadSegment roadNameFromSegment:caseInfo.roadsegment_id], caseInfo.side, [caseInfo station_start_km], [caseInfo station_start_m],caseInfo.place, desc,caseInfo.peccancy_type];
    //[adminis_remark appendFormat:@"已立案处理（案号：%@高赔（%@）第（%@）号）。", [[AppDelegate App].projectDictionary objectForKey:@"cityname"], caseInfo.case_mark2, [caseInfo full_case_mark3]];
    inspectionRecord.remark = remark;
    
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
    
}
- (void) createRecodeByServicesCheck:(ServiceManage  *)ServicesCheck{
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    inspectionRecord.roadsegment_id = @"0";//DynamicInfo.roadsegment_id;
    inspectionRecord.fix            = @"";//DynamicInfo.fix;
    inspectionRecord.inspection_id  = self.inspectionID;
    inspectionRecord.relationid     = @"0";//DynamicInfo.myid;//@"0";
    inspectionRecord.start_time     = ServicesCheck.checkdate;
    inspectionRecord.station        = 0;//DynamicInfo.station_start;
    //NSString* stationString = [NSString stringWithFormat:@"K%d+%dM", DynamicInfo.station_start.integerValue/1000, DynamicInfo.station_start.integerValue%1000];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *remark=[NSString stringWithFormat:@"%@ 当班巡至（粤高速）S32往西%@，服务区加油站、停车场、卫生间卫生良好。",[dateFormatter stringFromDate:ServicesCheck.checkdate],ServicesCheck.servicename];
    inspectionRecord.remark = remark;
    
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
    
}
- (void) createRecodeByShiGongCheck:(NSString *)shiGongCheckID withRemark:(NSString *)Remark{
    if ([shiGongCheckID isEmpty]) {
        return;
    }
    CaseInfo *caseInfo       = [CaseInfo caseInfoForID:shiGongCheckID];
    CaseProveInfo *proveInfo = [CaseProveInfo proveInfoForCase:shiGongCheckID];
    NSString *desc           = [LawbreakingAction LawbreakingActionCaptionForID:proveInfo.case_desc_id];
    //CaseProveInfo *caseProveInfo = [CaseProveInfo proveInfoForCase:caseID];
    Citizen *citizen         = [Citizen citizenForCitizenName:nil nexus:@"当事人" case:shiGongCheckID];
    MaintainPlanCheck *checkInfo=[[MaintainPlanCheck maintainCheckForID:shiGongCheckID] objectAtIndex:0];
    
    InspectionRecord *inspectionRecord=[InspectionRecord newDataObjectWithEntityName:@"InspectionRecord"];
    
    inspectionRecord.start_time    = checkInfo.check_date;
    inspectionRecord.remark        = Remark;
    inspectionRecord.inspection_id = self.inspectionID;
    inspectionRecord.relationid    = @"0";
    [[AppDelegate App] saveContext];
    [self reloadRecordData];
}
@end
