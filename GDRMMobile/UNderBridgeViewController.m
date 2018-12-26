//
//  UNderBridgeViewController.m
//  YUNWUMobile
//
//  Created by admin on 2018/8/13.
//

#import "UNderBridgeViewController.h"
#import "DateSelectController.h"
#import "UserPickerViewController.h"
#import "UserInfo.h"
#import "BridgeSpaceCheckSpecial.h"
#import "BridgeSpaceCheckSpecialB.h"
#import "BridgePickerViewController.h"
#import "OrgInfo.h"
#import "InspectionConstructionCell.h"

@interface UNderBridgeViewController ()
@property (nonatomic,retain) BridgeSpaceCheckSpecialB * CheckSpecialB;
@property (nonatomic,retain) NSString * caseID;

@property (nonatomic,retain) NSMutableArray * DataArray;
@end


@implementation UNderBridgeViewController
NSInteger currentTag;
NSInteger status;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.Managedtext.enabled = NO;
//    self.RoadNametext.enabled = NO;
//    self.Usernametext.enabled = NO;
    status = 0;
    [self loadinfo];
    NSArray * array= [BridgeSpaceCheckSpecialB BridgeSpaceCheckSpecialBforArray];
    self.DataArray = [NSMutableArray arrayWithArray:array];
//    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
//    [context deleteObject:self.DataArray[0]];
    self.ListTableView.delegate = self;
    self.ListTableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadinfo{
    [self.LabelCheckDemand setHidden:YES];
    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
    self.Managedtext.text = [[OrgInfo orgInfoForOrgID:[UserInfo userInfoForUserID:currentUserID].organization_id] valueForKey:@"orgname"];
    self.Usernametext.text = [[UserInfo userInfoForUserID:currentUserID] valueForKey:@"username"];
    self.RoadNametext.text = @"";
    self.Ckecktimestarttext.text = @"";
    self.onetext.text = @"";
    self.twotext.text = @"";
    self.threetext.text = @"";
    self.fourtext.text = @"";
    self.fivetext.text = @"";
    self.sixtext.text = @"";
    self.seventext.text = @"";
    self.eighttext.text = @"";
    self.ninetext.text = @"";
    self.tentext.text = @"";
    self.eleventext.text = @"";
    self.Endtimetext.text = @"";
}
- (void)loadCaseIDinfo{
    self.RoadNametext.text = self.CheckSpecialB.road_name;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日HH时mm分"];
    self.Ckecktimestarttext.text = [dateFormatter stringFromDate:self.CheckSpecialB.check_date];
    self.Endtimetext.text = [dateFormatter stringFromDate:self.CheckSpecialB.finish_date];
    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
    self.Managedtext.text = [[OrgInfo orgInfoForOrgID:[UserInfo userInfoForUserID:currentUserID].organization_id] valueForKey:@"orgname"];
    self.Usernametext.text = self.CheckSpecialB.check_user;
    self.onetext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"1"];
    self.twotext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"2"];
    self.threetext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"3"];
    self.fourtext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"4"];
    self.fivetext.text =[self returnresultwithcaseID:self.caseID addsmallID:@"5"];
    self.sixtext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"6"];
    self.seventext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"7"];
    self.eighttext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"8"];
    self.ninetext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"9"];
    self.tentext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"10"];
    self.eleventext.text = [self returnresultwithcaseID:self.caseID addsmallID:@"11"];
}
- (NSString *)returnresultwithcaseID:(NSString *)caseID  addsmallID:(NSString *)smallID{
    BridgeSpaceCheckSpecial * special = [BridgeSpaceCheckSpecial BridgeSpaceCheckSpecialForCase:caseID addforb_id:smallID];
    if ([special.check_result isEqualToString:@"符合要求"]) {
        return nil;
    }
    return special.check_result;
//    NSArray * array = [BridgeSpaceCheckSpecial caseBridgeSpaceCheckSpecialForCase:caseID];
//    for (int i = 0; i< array.count; i++) {
//        BridgeSpaceCheckSpecial * checkDetail = (BridgeSpaceCheckSpecial *)array[i];
//        if ([checkDetail.b_id isEqualToString:smallID]) {
//            if ([checkDetail.check_result isEqualToString:@"符合要求"]){
//                return nil;
//            }
//            return checkDetail.check_result;
//        }
//    }
    return nil;
}
- (void)saveDataInfo{
    if(self.caseID != nil){
        [self saveBridgeSpaceCheckSpecialInfo];
        NSDateFormatter * formator =[[NSDateFormatter alloc]init];
        [formator setLocale:[NSLocale currentLocale]];
        [formator setDateFormat:@"yyyy年MM月dd日HH时mm分"];
        if (self.Ckecktimestarttext.text.length) {
            self.CheckSpecialB.check_date = [formator dateFromString:self.Ckecktimestarttext.text];
        }
        if (self.Endtimetext.text.length) {
            self.CheckSpecialB.finish_date = [formator dateFromString:self.Endtimetext.text];
        }
        if (self.RoadNametext.text.length) {
            self.CheckSpecialB.road_name = self.RoadNametext.text;
        }
        if (self.Usernametext.text.length) {
            self.CheckSpecialB.check_user = self.Usernametext.text;
        }
        [[AppDelegate App]saveContext];
        if (status == 0) {
            [self.DataArray addObject:self.CheckSpecialB];
            status = 1;
        }
    }
}
//保存11项检查数据
- (void)saveBridgeSpaceCheckSpecialInfo{
    NSString * oneresult = self.onetext.text.length ? self.onetext.text :@"符合要求";
    NSString * tworesult = self.twotext.text.length ? self.twotext.text :@"符合要求";
    NSString * threeresult = self.threetext.text.length ? self.threetext.text :@"符合要求";
    NSString * fourresult = self.fourtext.text.length ? self.fourtext.text :@"符合要求";
    NSString * fiveresult = self.fivetext.text.length ? self.fivetext.text :@"符合要求";
    NSString * sixresult = self.sixtext.text.length ? self.sixtext.text :@"符合要求";
    NSString * sevenresult = self.seventext.text.length ? self.seventext.text :@"符合要求";
    NSString * eightresult = self.eighttext.text.length ? self.eighttext.text :@"符合要求";
    NSString * nineresult = self.ninetext.text.length ? self.ninetext.text :@"符合要求";
    NSString * tenresult = self.tentext.text.length ? self.tentext.text :@"符合要求";
    NSString * elevenresult = self.eleventext.text.length ? self.eleventext.text :@"符合要求";
    [self saveDetailDataInfo:self.caseID addforb_id:@"1" addresult:oneresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"2" addresult:tworesult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"3" addresult:threeresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"4" addresult:fourresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"5" addresult:fiveresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"6" addresult:sixresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"7" addresult:sevenresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"8" addresult:eightresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"9" addresult:nineresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"10" addresult:tenresult];
    [self saveDetailDataInfo:self.caseID addforb_id:@"11" addresult:elevenresult];
}

- (void)saveDetailDataInfo:(NSString *)caseID addforb_id:(NSString *)smallID addresult:(NSString * )result{
    BridgeSpaceCheckSpecial * special = [BridgeSpaceCheckSpecial BridgeSpaceCheckSpecialForCase:caseID addforb_id:smallID];
    if (!special.check_result.length) {
        special = [BridgeSpaceCheckSpecial newDataObjectWithEntityNameforcaseID:caseID addBiaoShiID:smallID addresult:result];
    }
//    special.b_id = smallID;
    NSLog(@"%@----%@",smallID,special.b_id);
    special.check_result = result;
    [[AppDelegate App] saveContext];
}
- (IBAction)RoadNameTextClick:(id)sender {
    if ([self.pickerPopover isPopoverVisible]){
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        BridgePickerViewController * icPicker = [[BridgePickerViewController alloc] initWithStyle:UITableViewStylePlain];
        icPicker.tableView.frame = CGRectMake(0, 0, 200, 243);
        icPicker.pickerState     =  0;
        icPicker.delegate        = self;
        UITextField  * textfield = (UITextField *)sender;
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:icPicker];
        [self.pickerPopover setPopoverContentSize:CGSizeMake(200, 243)];
        [self.pickerPopover presentPopoverFromRect:textfield.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        icPicker.pickerPopover = self.pickerPopover;
    }
}
- (void)setBridge:(NSString *)aBridgeID roadName:(NSString *)raBridgeName{
    self.RoadNametext.text = raBridgeName;
//    self.birdgeID = aBridgeID;
}
- (IBAction)ManagedClick:(id)sender {
    
}
- (IBAction)timeSelectClick:(id)sender {
    UIStoryboard *MainStoryboard            = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    DateSelectController * datePicker = [MainStoryboard instantiateViewControllerWithIdentifier:@"datePicker"];
    UITextField * textField = sender;
    CGRect frame = textField.frame;
    if(self.Ckecktimestarttext == sender){
        currentTag = 888;
    }else{
        currentTag = 666;
        frame = CGRectMake(frame.origin.x+100,frame.origin.y,frame.size.width,frame.size.height);
    }
    datePicker.delegate = self;
    datePicker.pickerType=1;
    // [datePicker showdate:self.textDate.text];
    self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:datePicker];
    [self.pickerPopover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    datePicker.dateselectPopover= self.pickerPopover;
}
- (void)setDate:(NSString *)date{
    NSDateFormatter * formator =[[NSDateFormatter alloc]init];
    [formator setLocale:[NSLocale currentLocale]];
    [formator setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSDate * showdate =[formator dateFromString:date];
    if (currentTag == 888) {
        self.CheckSpecialB.check_date = [formator dateFromString:date];
        [formator setDateFormat:@"yyyy年MM月dd日HH时mm分"];
        self.Ckecktimestarttext.text = [formator stringFromDate:self.CheckSpecialB.check_date];
        self.Ckecktimestarttext.text = [formator stringFromDate:showdate];
    }else if (currentTag == 666){
        self.CheckSpecialB.finish_date = [formator dateFromString:date];
        [formator setDateFormat:@"yyyy年MM月dd日HH时mm分"];
        self.Endtimetext.text =[formator stringFromDate:showdate];
    }
}
    
- (IBAction)UsernameSelectClick:(id)sender {
    UITextField * field = (UITextField *)sender;
    currentTag = field.tag;
    if ([self.pickerPopover isPopoverVisible]) {
        [self.pickerPopover dismissPopoverAnimated:YES];
    } else {
        UserPickerViewController *acPicker=[[UserPickerViewController alloc] init];
        acPicker.delegate = self;
        self.pickerPopover=[[UIPopoverController alloc] initWithContentViewController:acPicker];
        [self.pickerPopover setPopoverContentSize:CGSizeMake(140, 200)];
        UITextField * textfield = (UITextField *)sender;
        CGRect frame = CGRectMake(textfield.frame.origin.x-200, textfield.frame.origin.y, textfield.frame.size.width-30, textfield.frame.size.height);
        [self.pickerPopover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        acPicker.pickerPopover=self.pickerPopover;
    }
}
- (void)setUser:(NSString *)name andUserID:(NSString *)userID{
    self.CheckSpecialB.check_user = userID;
    self.Usernametext.text = name;
}

- (IBAction)addinfoClick:(id)sender {
    [self loadinfo];
    self.caseID = nil;
    status = 0;
}

- (IBAction)BtnSaveClick:(id)sender {
    if (!self.RoadNametext.text.length) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请选择检查路段名称再保存" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([self.caseID isEmpty] || self.caseID == nil) {
        self.CheckSpecialB = [BridgeSpaceCheckSpecialB newDataObjectWithEntityName];
        self.caseID = self.CheckSpecialB.myid;
    }
    self.CheckSpecialB = [BridgeSpaceCheckSpecialB BridgeSpaceCheckSpecialBforcaseID:self.caseID];
    [self saveDataInfo];
    [[AppDelegate App] saveContext];
    [self.ListTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.DataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"BridgeSpaceCheckSpecialB";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    BridgeSpaceCheckSpecialB * checkSpecialbcell = (BridgeSpaceCheckSpecialB *)self.DataArray[indexPath.row];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MM月dd日"];
    NSString * str = [formatter stringFromDate:checkSpecialbcell.check_date];
    if (!str.length) {
        str = @"";
    }
    // cell.textLabel.text=[formatter stringFromDate:constructionInfo.inspectiondate];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",checkSpecialbcell.road_name,str];
    cell.textLabel.backgroundColor=[UIColor clearColor];
    cell.detailTextLabel.text = checkSpecialbcell.check_user;
    if (checkSpecialbcell.isuploaded.boolValue) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.CheckSpecialB = (BridgeSpaceCheckSpecialB *)self.DataArray[indexPath.row];
    self.caseID = self.CheckSpecialB.myid;
    status = 1;
    [self loadCaseIDinfo];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    //删除数据库数据            检查内容删除
    id obj=[self.DataArray objectAtIndex:indexPath.row];
    BridgeSpaceCheckSpecialB * specialb = (BridgeSpaceCheckSpecialB *)self.DataArray[indexPath.row];
    NSArray * array = [BridgeSpaceCheckSpecial caseBridgeSpaceCheckSpecialForCase:specialb.myid];
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    [context deleteObject:obj];
    for (int i = 0; i < [array count]; i++) {
        [context deleteObject:array[i]];
    }
    [self.DataArray removeObjectAtIndex:indexPath.row];
    [[AppDelegate App] saveContext];
    //删除tableviewcell
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [tableView endUpdates];
    
}

@end
