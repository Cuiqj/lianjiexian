//
//  ServicesCheckViewController.m
//  GDRMMobile
//
//  Created by xiaoxiaojia on 17/5/3.
//
//

#import "ServicesCheckViewController.h"
#import "ServiceOrg.h"
#import "ServiceManage.h"
#import "ServiceManageDetail.h"
#import "ServiceCheckItems.h"
#import "DateSelectController.h"
#import "ListSelectViewController.h"
#import "UserInfo.h"
#import "OrgInfo.h"

#import "NameimageViewController.h"

typedef   enum {
    kCHECKDATE = 0,
    kSERVICENAME,
    kCHECKFUZEREN,
    kTARGET,
    kITEM
}TextType ;
@interface ServicesCheckViewController (){
    NSMutableArray *serviceCheckList, *checkDetailList;
    NSString *serviceCheckID,*checkDetailID;
    //UIPopoverController *popoverController;
    TextType textTagFlag;
    NSString *selectedTarget;
    NSInteger leftOrRight;
}
@property (nonatomic,retain) UIPopoverController *popoverController;
@property (nonatomic,retain) NSDate              *checktime;
@property (nonatomic,strong) ServiceManage        *serviceCheck;
@property (nonatomic,strong) ServiceManageDetail *serviceCheckDetail;
@end

@implementation ServicesCheckViewController
@synthesize popoverController,checktime,serviceCheck,serviceCheckDetail,inspectionID,roadinspectVC;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.textchecktime.tag                                  = kCHECKDATE;
    self.textservicename.tag                                = kSERVICENAME;
    self.textcheck_fuzeren.tag                              = kCHECKFUZEREN;
    self.texttarget.tag                                     = kTARGET;
    self.textitem.tag                                       = kITEM;
    self.LeftTableView.allowsMultipleSelectionDuringEditing = YES;
    self.navigationItem.title=@"服务区检查";
    serviceCheckList=[[ServiceManage allServiceManage] mutableCopy];
    
    checkDetailList                                         = [[ServiceManageDetail ServiceManageDetailForID:serviceCheckID] mutableCopy];
    leftOrRight                                             = 0;
    [self.checkDetailView setHidden:YES];
    // Do any additional setup after loading the view.
    CGRect frame = self.textservice_fuzeren.frame;
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(frame.origin.x- frame.size.width/4, frame.origin.y + 80,150, 30)];
    button.tag = 222;
    [self.serviceCheckView addSubview:button];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [button setTitle:@"去手写签名" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(imagebuttonClick:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)imagebuttonClick:(UIButton *)button{
    if ([self.serviceCheck.imageid isEqualToString:@"0"]){
        self.serviceCheck.imageid =[NSString randomID];
    }
    NameimageViewController * nameimage = [[NameimageViewController alloc] init];
    nameimage.imageID = self.serviceCheck.imageid;
    [self.navigationController pushViewController:nameimage animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillDisappear:(BOOL)animated{
    if (serviceCheckID !=nil&&
        self.roadinspectVC ) {
        if (serviceCheckID !=nil) {
            [self.roadinspectVC createRecodeByServicesCheck:self.serviceCheck];
            
        }
    }
    self.roadinspectVC = nil;
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([tableView isEqual:self.LeftTableView]){
        return  [serviceCheckList count];
    }else{
        return [checkDetailList count];
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * leftIdentitf=@"leftcell";
    static NSString * rightIdentitf=@"righttcell";
    if([tableView isEqual:self.LeftTableView]){
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:leftIdentitf];
        if(!cell){
            cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:leftIdentitf];
            ServiceManage *servicecheck=[serviceCheckList objectAtIndex:indexPath.row];
            cell.textLabel.text = [ServiceOrg ServiceOrgNameforServiceNameID:servicecheck.servicename];
            NSDateFormatter *formator=[[NSDateFormatter alloc] init];
            [formator setLocale:[NSLocale currentLocale]];
            [formator setDateFormat:@"yyyy年MM月dd日 hh:mm"];
            cell.detailTextLabel.text=[formator stringFromDate:servicecheck.checkdate];
            if(servicecheck.isuploaded.boolValue){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        return  cell;
    }else{
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:rightIdentitf];
        if(!cell){
            cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:rightIdentitf];
            ServiceManageDetail *detail =[checkDetailList objectAtIndex:indexPath.row];
            cell.textLabel.text = detail.target;
            cell.detailTextLabel.text=[NSString stringWithFormat:@"%@ %@分（总分：%@分）",detail.item,detail.grade,detail.score];
            if(detail.isuploaded.boolValue){
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        return  cell;
    }
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(NSString*) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.RightTableView]) {
        ServiceManageDetail *Detail=[checkDetailList objectAtIndex:indexPath.row];
        BOOL isPromulgated = Detail.isuploaded.boolValue;
        if (isPromulgated) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"删除失败" message:@"已上传信息，不能直接删除" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            [alert show];
        } else {
            if([checkDetailID isEqualToString:Detail.myid]){[self cleanCheckDetailView];}
            NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
            [context deleteObject:Detail];
            [checkDetailList removeObject:Detail];
            [[AppDelegate App] saveContext];
        }
        
    }else{
        ServiceManage *Check=[serviceCheckList objectAtIndex:indexPath.row];
        BOOL isPromulgated = Check.isuploaded.boolValue;
        if (isPromulgated) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"删除失败" message:@"已上传信息，不能直接删除" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
            [alert show];
            return;
        } else {
            if([serviceCheckID isEqualToString:Check.myid]){[self cleanServiceCheckView];}
            NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
            NSArray *subDetailArray = [ServiceManageDetail ServiceManageDetailForID:Check.myid];
            for( ServiceManageDetail *obj in subDetailArray){
                [checkDetailList removeObject:obj];
                [context deleteObject:obj];
            }
            [self.RightTableView reloadData];
            [context deleteObject:Check];
            [serviceCheckList removeObject:Check];
            [[AppDelegate App] saveContext];
        }
        
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [tableView endUpdates];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:self.LeftTableView]){
        [self.checkDetailView setHidden:YES];
        [self.serviceCheckView setHidden:NO];
        checkDetailID     = nil;
        leftOrRight       = 0;
        serviceCheckID=[[serviceCheckList objectAtIndex:indexPath.row] valueForKey:@"myid"];
        self.serviceCheck = [serviceCheckList objectAtIndex:indexPath.row];
        [self loadServiceCheck:[serviceCheckList objectAtIndex:indexPath.row]];
        checkDetailList = [[ServiceManageDetail ServiceManageDetailForID:serviceCheckID] mutableCopy];
        [self.RightTableView reloadData];
    }else{
        [self.checkDetailView setHidden:NO];
        [self.serviceCheckView setHidden:YES];
        checkDetailID           = [[checkDetailList objectAtIndex:indexPath.row] valueForKey:@"myid"];
        leftOrRight             = 1;
        self.serviceCheckDetail = [checkDetailList objectAtIndex:indexPath.row];
        [self loadCheckDeatail:[checkDetailList objectAtIndex:indexPath.row]];
    }
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if([tableView isEqual:self.LeftTableView]){
        return @"考核主表";
    }
    else{
        return @"考核内容";
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)btnSave:(id)sender {
    switch (leftOrRight) {
        case 0:{
            if(self.serviceCheck==nil){
                self.serviceCheck=(ServiceManage *) [NSManagedObject newDataObjectWithEntityName:@"ServiceManage" ];
                serviceCheckID = self.serviceCheck.myid;
                self.serviceCheck.imageid = @"0";
                self.serviceCheck.service_type = @(2);
            }
            [self saveServiceCheck];
        }
            break;
        case 1:{
            if( self.serviceCheckDetail==nil){
                self.serviceCheckDetail=(ServiceManageDetail *) [NSManagedObject newDataObjectWithEntityName:@"ServiceManageDetail" ];
                self.serviceCheckDetail.parent_id = serviceCheckID;
                checkDetailID                     = self.serviceCheckDetail.myid;
            }
            [self saveCheckDeatail];
        }
            break;
        default:
            break;
    }
    [self saveCheckDeatail];
    
}

- (IBAction)btnToAttach:(id)sender {
    if( serviceCheckID == nil || [ serviceCheckID isEmpty]){
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择一条记录" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alter show];
        return;
    }
    UIStoryboard *board            = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    AttachmentViewController *next = [board instantiateViewControllerWithIdentifier:@"AttachmentViewController"];
    [next setValue:serviceCheckID forKey:@"constructionId"];
    [self.navigationController pushViewController:next animated:YES];
    
}

- (IBAction)btnNew:(id)sender {
    [self btnSave:nil];
    switch (leftOrRight) {
        case 0:{
            [self cleanServiceCheckView];
        }break;
        case 1:{
            [self cleanCheckDetailView];
        }break;
        default:
            break;
    }
    
    self.serviceCheckDetail = nil;
    
}
- (void) cleanServiceCheckView{
    self.serviceCheck = nil;
    self.textchecktime.text=@"";
    self.textservicename.text=@"";
    self.textservice_fuzeren.text=@"";
    self.textcheck_fuzeren.text=@"";
    //清理imageview   显示image的
}
- (void) cleanCheckDetailView{
    self.serviceCheckDetail = nil;
    self.texttarget.text=@"";
    self.textitem.text=@"";
    self.textgrade.text=@"";
    self.textremark.text=@"";
    self.labelstandard.text=@"";
    self.labelscore.text=@"";
}

- (IBAction)textToued:(UITextField *)sender {
    textTagFlag                             = sender.tag;
    UIStoryboard *MainStoryboard            = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ListSelectViewController * listPickerVC = [MainStoryboard instantiateViewControllerWithIdentifier:@"ListSelectPoPover"];
    switch (sender.tag) {
        case kCHECKDATE:{
            DateSelectController *datePicker = [MainStoryboard instantiateViewControllerWithIdentifier:@"datePicker"];
            datePicker.delegate              = self;
            datePicker.pastDate=[NSDate date];
            datePicker.pickerType            = 1;
            if([self.popoverController isPopoverVisible]) [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:datePicker];
            [self.popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            datePicker.dateselectPopover = self.popoverController;
            
            
        }break;
        case kCHECKFUZEREN:{
            listPickerVC.data=[[UserInfo allUserInfo] valueForKeyPath:@"account"];
            listPickerVC.delegate = self;
            if([self.popoverController isPopoverVisible]) [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:listPickerVC];
            [self.popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            listPickerVC.pickerPopover = self.popoverController;
        }break;
        case kSERVICENAME:{
            listPickerVC.data=[[ServiceOrg allServiceOrg] valueForKeyPath:@"name"];
            listPickerVC.delegate = self;
            if([self.popoverController isPopoverVisible]) [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:listPickerVC];
            [self.popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            listPickerVC.pickerPopover = self.popoverController;
        }break;
        case kTARGET:{
            // listPickerVC.data=[NSArray arrayWithObject: [NSSet setWithArray:[ServiceCheckItems allServiceCheckItemsTarget]] ] ;
            listPickerVC.delegate = self;
            listPickerVC.data     = [ServiceCheckItems allServiceCheckItemsTarget];
            if([self.popoverController isPopoverVisible]) [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:listPickerVC];
            [self.popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            listPickerVC.pickerPopover = self.popoverController;
        }break;
        case kITEM:{
            listPickerVC.data=[ServiceCheckItems serviceCheckItemsItemForTarget:selectedTarget];
            listPickerVC.delegate = self;
            
            if([self.popoverController isPopoverVisible]) [self.popoverController dismissPopoverAnimated:YES];
            self.popoverController=[[UIPopoverController alloc] initWithContentViewController:listPickerVC];
            [self.popoverController presentPopoverFromRect:[sender frame] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
            listPickerVC.pickerPopover = self.popoverController;
        }break;
        default:
            break;
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (id object in [self.view subviews]) {
        if ([object isKindOfClass:[UITextField class]]) {
            [(UITextField*)object resignFirstResponder];
        }
    }
}
#pragma mark - 回收任何空白区域键盘事件
- (void)setUpForDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view addGestureRecognizer:singleTapGR];
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view removeGestureRecognizer:singleTapGR];
                }];
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    //此method会将self.view里所有的subview的first responder都resign掉
    [self.view endEditing:YES];
}

- (IBAction)btnEdit:(id)sender {
    if(serviceCheckID==nil){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先选择检查单位" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    leftOrRight             = 1;
    self.serviceCheckDetail = nil;
    self.texttarget.text=@"";
    self.textitem.text=@"";
    self.textgrade.text=@"";
    self.textremark.text=@"";
    self.labelstandard.text=@"";
    self.labelscore.text=@"";
    [self.checkDetailView setHidden:NO];
    [self.serviceCheckView setHidden:YES];
    self.serviceCheckDetail = nil;
    
}
- (void) setSelectData:(NSString *)data{
    switch (textTagFlag) {
        case kCHECKDATE:{
            
        }break;
        case kCHECKFUZEREN:{
            self.textcheck_fuzeren.text = data;
        }break;
        case kSERVICENAME:{
            self.textservicename.text = data;
            self.serviceCheck.servicename = [ServiceOrg allServiceOrg_NameIDforname:data];
        }break;
        case kTARGET:{
            self.texttarget.text = data;
            selectedTarget       = data;
        }break;
        case kITEM:{
            self.textitem.text      = data;
            ServiceCheckItems *item=[ServiceCheckItems serviceCheckItemsItemForTarget:selectedTarget andItems:data];
            self.labelstandard.text = item.standard;
            self.labelscore.text    = [ NSString stringWithFormat:@"(总分%@)",item.score];
        }break;
        default:
            break;
    }
}
- (void) setPastDate:(NSDate *)date withTag:(int)tag{
    NSDateFormatter *formator=[[NSDateFormatter alloc] init];
    [formator setLocale:[NSLocale currentLocale]];
    [formator setDateFormat:@"yyyy年MM月dd日 hh:mm"];
    self.textchecktime.text=[formator stringFromDate:date];
    self.checktime = date;
}
- (void)addimageviewforname{
    UIButton * btn = [self.serviceCheckView viewWithTag:222];
    CGRect frame = btn.frame;
    NSArray *pathArray=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[pathArray objectAtIndex:0];
    NSString *Path=[NSString stringWithFormat:@"CasePhoto/%@",self.serviceCheck.imageid];
    Path = [documentPath stringByAppendingPathComponent:Path];
//    NSString * Name = @"ServiceManage.jpg";
//    NSString * filePath=[Path stringByAppendingPathComponent:Name];
    //现场平面图。 图片路径
    UIImage * image;
    if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        image = [[UIImage alloc] initWithContentsOfFile:Path];
    }
    else{
        self.serviceCheck.imageid = @"0";
        return;
    }
    UIImageView * imageview = [[UIImageView alloc] initWithImage:image];
    imageview.frame = CGRectMake(frame.origin.x -80, frame.origin.y+60, image.size.width, image.size.height);
    imageview.tag = 555;
    [self.serviceCheckView addSubview:imageview];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (serviceCheckID.length>0) {
        [self loadServiceCheck:self.serviceCheck];
    }
}
- (void) loadServiceCheck:(ServiceManage*)servicecheck{
    NSDateFormatter *formator=[[NSDateFormatter alloc] init];
    [formator setLocale:[NSLocale currentLocale]];
    [formator setDateFormat:@"yyyy年MM月dd日 hh:mm"];
    serviceCheckID                = servicecheck.myid;
    checktime                     = servicecheck.checkdate;
    self.textchecktime.text=[formator stringFromDate: servicecheck.checkdate];
    self.textservicename.text     = [ServiceOrg ServiceOrgNameforServiceNameID:servicecheck.servicename];
    self.textservice_fuzeren.text = servicecheck.service_fuzeren;
    self.textcheck_fuzeren.text   = servicecheck.check_fuzeren;
    if (![self.serviceCheck.imageid isEqual:@"0"]) {
        UIView * view = [self.serviceCheckView viewWithTag:555];
        if (view) {
            [view removeFromSuperview];
        }
        [self addimageviewforname];
    }
}
- (void) loadCheckDeatail:(ServiceManageDetail*)checkdetail{
    NSDateFormatter *formator=[[NSDateFormatter alloc] init];
    [formator setLocale:[NSLocale currentLocale]];
    [formator setDateFormat:@"yyyy年MM月dd日 hh:mm"];
    self.texttarget.text    = checkdetail.target;
    self.textitem.text      = checkdetail.item;
    self.labelstandard.text = checkdetail.standard;
    self.textgrade.text  =[NSString stringWithFormat:@"%@", checkdetail.grade];
    self.labelscore.text    = [NSString stringWithFormat:@"(总分%@)", checkdetail.score];
    self.textremark.text    = checkdetail.remark;
    
}
- (void) saveServiceCheck{
    self.serviceCheck.checkdate       = checktime;
    self.serviceCheck.servicename     = [ServiceOrg allServiceOrg_NameIDforname:self.textservicename.text];
    self.serviceCheck.service_fuzeren = self.textservice_fuzeren.text;
    self.serviceCheck.check_fuzeren   = self.textcheck_fuzeren.text;
    self.serviceCheck.org_id=[[OrgInfo orgInfoForSelected] valueForKey:@"myid"];
    [[AppDelegate App]saveContext];
    serviceCheckList=[[ServiceManage allServiceManage] mutableCopy];
    [self.LeftTableView reloadData];
}
- (void) saveCheckDeatail{
    self.serviceCheckDetail.target   = self.texttarget.text;
    self.serviceCheckDetail.item     = self.textitem.text;
    self.serviceCheckDetail.grade    = @(self.textgrade.text.integerValue);
    self.serviceCheckDetail.remark   = self.textremark.text;
    self.serviceCheckDetail.standard = self.labelstandard.text;
    
    NSString *str      = self.labelscore.text;
    NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    NSInteger number;
    [scanner scanInteger:&number];
    self.serviceCheckDetail.score=[NSNumber numberWithInteger: number];
    [[AppDelegate App] saveContext];
    checkDetailList = [[ServiceManageDetail ServiceManageDetailForID:serviceCheckID] mutableCopy];
    [self.RightTableView reloadData];
}


@end
