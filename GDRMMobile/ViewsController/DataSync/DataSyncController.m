//
//  ServerSettingController.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-2-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "OrgSyncViewController.h"
#import "UserInfo.h"

#import "DataSyncController.h"
#import "OMGToast.h"
#import "InitBasicData.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
@interface  DataSyncController()<UIAlertViewDelegate,OrgSetDelegate>
@property (retain, nonatomic) DataDownLoad *dataDownLoader;
@property (retain, nonatomic) DataUpLoad   *dataUploader;
- (void)upLoadFinished;
- (void)downLoadFinished;
@end

@implementation DataSyncController
@synthesize uibuttonInit   = _uibuttonInit;
@synthesize uibuttonReset  = _uibuttonReset;
@synthesize uibuttonUpload = _uibuttonUpload;
@synthesize dataDownLoader = _dataDownLoader;
@synthesize dataUploader   = _dataUploader;

- (DataUpLoad *)dataUploader{
    _dataUploader = nil;
    if (_dataUploader == nil) {
        _dataUploader = [[DataUpLoad alloc] init];
    }
    return _dataUploader;
}

//获取基础数据
- (DataDownLoad *)dataDownLoader{
    _dataDownLoader = nil;
    if (_dataDownLoader == nil) {
        _dataDownLoader = [[DataDownLoad alloc] init];
    }
    return _dataDownLoader;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [self setDataDownLoader:nil];
    [self setDataUploader:nil];
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    self.versionName.text = VERSION_NAME;
    self.versionTime.text = VERSION_TIME;
    NSString *imagePath=[[NSBundle mainBundle] pathForResource:@"小按钮" ofType:@"png"];
    UIImage *btnImage=[[UIImage imageWithContentsOfFile:imagePath] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    [self.uibuttonInit setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.uibuttonReset setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.uibuttonUpload setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.uibuttonResetForm setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.updateDocFormatBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.UpdateVersionBtn setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.ChangeOrganization setBackgroundImage:btnImage forState:UIControlStateNormal];
//    [self.ChangeOrganization setHidden:YES];      //切换机构
    [self.updateDocFormatBtn setHidden:YES];   //更新文书
//    [self.uibuttonReset setHidden:YES];   //设置服务器参数
    [self.uibuttonResetForm setHidden:YES];    //还原文书格式配置设置
//    [self.UpdateVersionBtn setHidden:YES];      //检查版本更新
    [self.ChangeOrganization setFrame:self.uibuttonResetForm.frame];
    [self.ChangeOrganization setTitle:@"清除数据" forState:UIControlStateNormal];
    
    imagePath=[[NSBundle mainBundle] pathForResource:@"服务器参数设置 -bg" ofType:@"png"];
    self.view.layer.contents=(id)[[UIImage imageWithContentsOfFile:imagePath] CGImage];
    self.updateDocFormatBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    self.updateDocFormatBtn.frame = CGRectMake(self.uibuttonResetForm.frame.origin.x, self.uibuttonResetForm.frame.origin.y+30, self.uibuttonResetForm.frame.size.width, self.uibuttonResetForm.frame.size.height);
    //[self.updateDocFormatBtn addTarget:self action:@selector(btnUpdateDocFormat:) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"设置服务器参数(请不要随意修改)"]];
    [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, 7)];
    [_setServerBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
    ////////////////////
    UITapGestureRecognizer * openOrCloseDocFormatDebugGes =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(isDebuging:)];
    openOrCloseDocFormatDebugGes.numberOfTouchesRequired = 2;
    openOrCloseDocFormatDebugGes.numberOfTapsRequired    = 6;
    openOrCloseDocFormatDebugGes.delegate                = self;
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:openOrCloseDocFormatDebugGes];
    ////////////////////
    [super viewDidLoad];
}
//双击666 开启调试文书模式 hhhhh
- (void)isDebuging:(UITapGestureRecognizer *)sender{
    if (sender.numberOfTapsRequired == 6 && sender.numberOfTouchesRequired==2) {
        
        NSUserDefaults *defaultdata=[NSUserDefaults standardUserDefaults];
        if([defaultdata boolForKey:@"isDebugingDocFormat"]){
            [defaultdata setBool:![defaultdata boolForKey:@"isDebugingDocFormat"] forKey:@"isDebugingDocFormat"];
            [OMGToast showWithText:@"已关闭文书调试模式" bottomOffset:100 duration:3];
            NSLog(@"已关闭文书调试模式");
        }
        else{
            [defaultdata setBool:![defaultdata boolForKey:@"isDebugingDocFormat"] forKey:@"isDebugingDocFormat"];
            [OMGToast showWithText:@"已开启文书调试模式" bottomOffset:100 duration:3];
            NSLog(@"已开启文书调试模式");
        }
        
    }
}


- (void)viewDidUnload
{
    
    [self setUibuttonInit:nil];
    [self setUibuttonReset:nil];
    [self setUibuttonUpload:nil];
    [self setDataDownLoader:nil];
    [self setDataUploader:nil];
    [self setSetServerBtn:nil];
    [self setVersionName:nil];
    [self setVersionTime:nil];
    [self setUibuttonResetForm:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (IBAction)btnInitData:(id)sender {        //获取基础数据
//    NSString *currentOrgID=[[NSUserDefaults standardUserDefaults] stringForKey:ORGKEY];
    [self.dataDownLoader startDownLoad:@"13822"];
    //[[[InitBasicData alloc]init] start];
}

- (IBAction)btnUpLoadData:(UIButton *)sender {          //上传业务数据
    [self.view endEditing:YES];
    NSString *inspectionID=[[NSUserDefaults standardUserDefaults] valueForKey:INSPECTIONKEY];
    if (![inspectionID isEmpty] && inspectionID!=nil) {
        void(^ShowAlert)(void)=^(void){
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误" message:@"当前还有未完成的巡查，请先交班再上传业务数据。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        };
        MAINDISPATCH(ShowAlert);
    } else {
        if ([WebServiceHandler isServerReachable]) {
            [self.dataUploader uploadData];
        }
    }
}



- (IBAction)btnUpdateDocFormat:(UIButton *)sender {
    if ([WebServiceHandler isServerReachable]){
        NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString * libPath=[libPaths objectAtIndex:0 ];
        NSString * settingPath=[libPath stringByAppendingString:@"/Settings.plist"];
        NSPropertyListFormat format1;
        NSError *err;
        NSData* settingPlistData=[[NSFileManager defaultManager] contentsAtPath:settingPath];
        NSDictionary * settingDict=(NSDictionary*)[NSPropertyListSerialization propertyListWithData:settingPlistData options:NSPropertyListMutableContainersAndLeaves format:&format1 error:&err ];
        NSArray * docArray=[[settingDict objectForKey:@"FileToTableMapping"] allValues];
        NSString* succed=@"ok";
        NSString*failDocNames=@"";
        for(NSString *docXMlName in docArray){
            NSArray *paths             = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            NSString *libraryDirectory = [paths objectAtIndex:0];
            NSString *temp=[docXMlName stringByAppendingString:@".xml"];
            NSString *destPath=[libraryDirectory stringByAppendingPathComponent:temp];
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@app/XML/%@.xml",[AppDelegate App].serverAddress ,docXMlName]];
            NSData *data =[NSData dataWithContentsOfURL:url];
            if(data ==nil){
                succed=@"fuck";
                
                if([failDocNames isEqualToString:@""]){
                    failDocNames =[NSString  stringWithFormat:@"%@%@",failDocNames,docXMlName ];
                }else{
                    failDocNames =[NSString  stringWithFormat:@"%@,%@",failDocNames,docXMlName ];
                }
            }
            NSString * s2=[[NSString alloc] initWithBytes: [data bytes] length:[data length] encoding:NSUTF8StringEncoding];
            [s2 writeToFile:destPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"%@",docXMlName);
        }
        NSString *message=@"";
        if([succed isEqualToString: @"ok"]){
            message=@"更新完成！";
        }
        else{
            message=@"更新失败，请检查网络连接";
        }
        UIAlertView *alert=[ [ UIAlertView alloc] initWithTitle:@"消息" message:message delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"isDebugingDocFormat"] &&![failDocNames isEqualToString:@""]){
            [OMGToast showWithText:[NSString stringWithFormat:@"%@文书更新失败",failDocNames] bottomOffset:100 duration:2];
        }
    }else{
        [OMGToast showWithText:@"无法连接服务器，请检查网络连接。" bottomOffset:100 duration:2];
    }  
}

- (IBAction)Changeorganization:(id)sender {
//    NSString *currentUserName=[[UserInfo userInfoForUserID:currentUserID] valueForKey:@"username"];
//    if (currentUserName!=nil) {
//        currentUserName = @"";
//    }
    [self.view endEditing:YES];
    NSString *inspectionID=[[NSUserDefaults standardUserDefaults] valueForKey:INSPECTIONKEY];
    if (![inspectionID isEmpty] && inspectionID!=nil) {
        void(^ShowAlert)(void)=^(void){
            UIAlertView *canalert=[[UIAlertView alloc] initWithTitle:@"错误" message:@"当前还有未完成的巡查，请先交班再清除业务数据。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [canalert show];
        };
        MAINDISPATCH(ShowAlert);
        return;
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"数据一经删除，不可恢复，确定删除数据" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 666;
    [alert show];
}
- (void)ChangeorganizationStart{
//    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
//    NSString *currentUserName=[[UserInfo userInfoForUserID:currentUserID] valueForKey:@"username"];
//    if (currentUserID != nil || ![currentUserID isEmpty]) {
//        currentUserID = nil;
//        currentUserName = @"重新选择";
//    }
    //   切换机构或者第一次进入   删除用户使其下次进入重新选择
//    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:USERKEY];
    //    删除写入沙盒数据
    [self deleteAllDatafornsarray];
    
//    OrgSyncViewController * osVC = [self.storyboard instantiateViewControllerWithIdentifier:@"OrgSyncVC"];
//    osVC.modalPresentationStyle = UIModalPresentationFormSheet;
//    osVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    osVC.delegate=self;
//    [self presentModalViewController:osVC animated:YES];
   
}
- (void)deleteRecordAllDocuments:(NSString *)name{
    //删除所有写入数据
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:name inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:nil];
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    for (id obj in fetchResult) {
        [context deleteObject:obj];
    }
    [context save:nil];
}
//删除所有写入沙盒数据
- (void)deleteAllDatafornsarray{
    NSArray  * dataNameArray   = @[@"Project",@"Task",@"AtonementNotice",@"CaseDeformation",@"CaseInfo",@"CaseInquire",@"CaseProveInfo",@"CaseServiceFiles",@"CaseServiceReceipt",@"Citizen",@"RoadWayClosed",@"Inspection",@"InspectionCheck",@"InspectionOutCheck",@"InspectionPath",@"InspectionRecord",@"ParkingNode",@"CaseMap",@"ConstructionChangeBack",@"TrafficRecord",@"InspectionConstruction",@"CasePhoto",@"MaintainPlanCheck",@"RectificationNotice",@"StopNotice",@"RoadWayClosed",@"CaseLawInfo",@"ServiceManage",@"ServiceManageDetail",@"HelpWork",@"CarCheckRecords",@"CheckInstitutions",@"RoadAsset_Check_Main",@"RoadAsset_Check_detail",@"BridgeSpaceCheckSpecialB",@"BridgeSpaceCheckSpecial"];
    for (int i = 0; i < [dataNameArray count]; i++) {
        [self deleteRecordAllDocuments:dataNameArray[i]];
    }
}
- (void)deleteAllData{
    //删除案件数据
    [self deleteRecordAllDocuments:@"CaseInfo"];
    //删除构造物数据
    [self deleteRecordAllDocuments:@"InspectionConstruction"];
    //删除路政巡查数据
    [self deleteRecordAllDocuments:@"InspectionRecord"];
    [self deleteRecordAllDocuments:@"Inspection"];
    //删除施工数据
    [self deleteRecordAllDocuments:@"MaintainPlanCheck"];
    //删除交通事故登记数据
    [self deleteRecordAllDocuments:@"TrafficRecord"];
    //删除服务区检查数据
    [self deleteRecordAllDocuments:@"ServiceManage"];
    [self deleteRecordAllDocuments:@"ServiceManageDetail"];
    //删除应急保障事件
    [self deleteRecordAllDocuments:@"RoadWayClosed"];
    //删除桥梁数据
    [self deleteRecordAllDocuments:@"Table101"];
    //删除照片数据
    [self deleteRecordAllDocuments:@"CasePhoto"];
    //删除所有数据。 所有case数据   案件数据包含表
    [self deleteRecordAllDocuments:@"CaseProveInfo"];
    [self deleteRecordAllDocuments:@"Citizen"];
    [self deleteRecordAllDocuments:@"CaseDeformation"];
    [self deleteRecordAllDocuments:@"CaseInquire"];
    [self deleteRecordAllDocuments:@"ParkingNode"];
    [self deleteRecordAllDocuments:@"CaseDocuments"];
    
    [self deleteRecordAllDocuments:@"BridgeSpaceCheckSpecialB"];
    [self deleteRecordAllDocuments:@"BridgeSpaceCheckSpecial"];
}

- (void)downLoadFinished{
    self.dataDownLoader = nil;
}

- (void)upLoadFinished{
    self.dataUploader = nil;
}

- (IBAction)btnUser:(id)sender {
    
    //初始化使用机内文书格式设置
    /*
    NSArray *paths             = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *plistFileName    = @"Settings.plist";
    NSString *plistPath        = [libraryDirectory stringByAppendingPathComponent:plistFileName];
    NSPropertyListFormat format;
    NSString *errorDesc;
    NSData *plistXML       = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *settings = (NSDictionary *)[NSPropertyListSerialization
                                              propertyListFromData:plistXML
                                              mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                              format:&format
                                              errorDescription:&errorDesc];
    NSDictionary *tables = [settings objectForKey:@"FileToTableMapping"];
    NSArray *fileArray   = [tables allValues];
    for (NSString * docXMLSettingFileName in fileArray) {
        NSArray *paths                   = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory       = [paths objectAtIndex:0];
        NSString *docXMLSettingFilesPath = [[NSBundle mainBundle] pathForResource:docXMLSettingFileName ofType:@"xml"];
        NSString *temp=[docXMLSettingFileName stringByAppendingString:@".xml"];
        NSString *destPath=[libraryDirectory stringByAppendingPathComponent:temp];
        NSError *error;
        if([[NSFileManager defaultManager] fileExistsAtPath:destPath]){
            [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
        }
        
        if([[NSFileManager defaultManager] fileExistsAtPath:docXMLSettingFilesPath]){
            [[NSFileManager defaultManager] copyItemAtPath:docXMLSettingFilesPath toPath:destPath error:&error];
        }
    }
    [[ [UIAlertView alloc]initWithTitle:@"提示" message:@"完成！" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil] show];
    */
    [[[InitBasicData alloc]init] startUpload];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 666) {
        if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"确定"] && buttonIndex == 1 ){
            [self ChangeorganizationStart];
            return;
        }
    }
    NSString *filePath=@"http://124.172.189.177:81/xbyh/app/update.json";
    NSURL *fileUrl=[NSURL URLWithString:filePath];
    id Update=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileUrl] options:NSJSONReadingMutableLeaves error:nil];
    if(buttonIndex==0){
        if([Update[@"isMustUpdate"] boolValue]){
            NSString *url = @"https://teank.github.io/apprelease/xbyh/downloadapp.html";//把http://带上
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            assert(0);
        }
        else
            return;
    }else if(buttonIndex==1){
        
        //abort(0);
        //exit(1);
        NSString *url = @"https://teank.github.io/apprelease/xbyh/downloadapp.html";//把http://带上
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        assert(0);
        UIWindow *window = [AppDelegate App].window;
        
        [UIView animateWithDuration:1.0f animations:^{
            window.alpha = 0;
            window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
        } completion:^(BOOL finished) {
            exit(0);
        }];
    }
}
- (IBAction)UpdateVersion:(UIButton *)sender {
     if ([WebServiceHandler isServerReachable]){
         [self hasUpdateVersion];
     }
}
//如果有最新版本上传到蒲公英，提示更新
- (void)hasUpdateVersion{
    //    kWeakSelf(self);
    __weak typeof(self)weakself = self;
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentBulidVersion = infoDic[@"CFBundleVersion"];
    
    //蒲公英的apikey，appkey
    NSDictionary *paramDic = @{@"_api_key":@"d98734ffcbcb99a86ff217e63c46ecfe",@"appKey":@"b155636e60b9d2d85e1e507070fa7633"};
    [self loadUpdateWithDic:paramDic success:^(id response) {
        NSLog(@"更新信息");
        if ([currentBulidVersion integerValue] < [response[@"data"][@"buildVersionNo"]integerValue]) {
            //如果当前手机安装app的版本号不是蒲公英上最新打包的版本号，则提示更新
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"版本更新" message:@"检测到新版本,是否更新?"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:cancelAction];
            UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //                NSURL *url = [NSURL URLWithString:response[@"data"][@"buildShortcutUrl"]];
                //                [[UIApplication sharedApplication] openURL:url];
                //                data =     {
                //                    buildBuildVersion = 2;
                //                    buildHaveNewVersion = 1;
                //                    buildShortcutUrl = "https://www.pgyer.com/HbOA";
                //                    buildUpdateDescription = "\U6700\U65b0\U7248\U672c\U6d4b\U8bd5";
                //                    buildVersion = 2018092901;
                //                    buildVersionNo = 2018092901;
                //                    downloadURL = "itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/e649cd191f07632c94c628774b91f0d5/update/s.plist";
                //                };
                NSURL *url = [NSURL URLWithString:response[@"data"][@"downloadURL"]];
                [[UIApplication sharedApplication] openURL:url];
            }];
            [ac addAction:doneAction];
            [weakself.navigationController presentViewController:ac animated:YES completion:nil];
        }
        else if ([currentBulidVersion integerValue] >=[response[@"data"][@"buildVersionNo"]integerValue]){
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"版本更新" message:@"检测到已是最新版本"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [ac addAction:cancelAction];
            [weakself.navigationController presentViewController:ac animated:YES completion:nil];
        }
    }];
}
- (void)loadUpdateWithDic:(NSDictionary *)dic success:(void(^)(id response))success {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // - (NSURLSessionDataTask *)POST:(NSString *)URLString
    //parameters:(id)parameters
    //success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
    //failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
    //    {
    //        return [self POST:URLString parameters:parameters progress:nil success:success failure:failure];
    //    }
    [manager POST:@"https://www.pgyer.com/apiv2/app/check" parameters:dic progress:nil success:^(NSURLSessionDataTask *task,id responseObject) {
        NSLog(@"版本更新%@",responseObject);
        success(responseObject);
    } failure:^(NSURLSessionDataTask *task,NSError *error){
        NSLog(@"搜版本更新请求失败");
    }];
}
    
//    if ([WebServiceHandler isServerReachable]){
//        NSString *filePath=@"http://124.172.189.177:81/xbyh/app/update.json";
//        NSURL *fileUrl=[NSURL URLWithString:filePath];
//        //id Update=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileUrl] options:NSJSONReadingMutableLeaves error:nil];
//        NSData *data=[NSData dataWithContentsOfURL:fileUrl];
//        NSError *err;
//        id Update=@{};//[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileUrl] options:NSJSONReadingMutableLeaves error:&err];
//        if(data){
//            Update=[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:fileUrl] options:NSJSONReadingMutableLeaves error:&err];
//        }else{
//            Update = nil;
//        }
//
//        if(data && [Update[@"versionNum"] intValue]> [VERSION_NUMBER intValue]){
//            if([Update[@"isMustUpdate"] boolValue]){
//                [[[UIAlertView alloc]initWithTitle:@"版本更新提示" message:Update[@"log"] delegate:self cancelButtonTitle:@"去更新" otherButtonTitles:nil, nil] show];
//            }else{
//                [[[UIAlertView alloc]initWithTitle:@"版本更新提示" message:Update[@"log"] delegate:self cancelButtonTitle:@"不了" otherButtonTitles:@"去更新", nil] show];
//            }
//        }else{
//            [OMGToast showWithText:@"您安装的已经是最新版!" duration:1];
//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        }
//
//    }else{
//        [OMGToast showWithText:@"无法连接服务器，请检查网络连接。" bottomOffset:100 duration:2];
//
//    }
//}
@end
