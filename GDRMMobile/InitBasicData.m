//
//  InitBasicData.m
//  YUNWUMobile
//
//  Created by admin on 2018/1/15.
//
//

#import "InitBasicData.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "UserInfo.h"
#import "AlertViewWithProgressbar.h"
#import "MBProgressHUD.h"
#import "CasePhoto.h"
#import "UploadRecord.h"
#import "NSString+Base64.h"


static int total                          = 7;
static NSString  *tables[7] ={@"UserInfo",@"OrgInfo",@"InquireAnswerSentence",@"Provinces",@"CityCode",@"RoadSegment",@"RoadAssetPrice"};
static NSString  *updatetables[2] ={@"CaseInfo",@"CasePhoto" };
static int totalTablesForUpload           = 2;
#define WAITFORPARSER   self.stillParsing = 2;\
while (self.stillParsing == 2) {\
[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];\
}\
if(self.stillParsing == 0){\
return;\
}\

NSString*urlString=@"http://192.168.0.207/xbyh/Framework/DataBase.ashx";
@interface InitBasicData()
@property (nonatomic,retain) AlertViewWithProgressbar *progressView;
@property (nonatomic,assign) NSInteger                parserCount;
@property (nonatomic,assign) NSInteger                currentParserCount;
@property (nonatomic,strong) AFHTTPSessionManager     *manager;
@property (nonatomic,strong) NSMutableDictionary      *param;
@property (nonatomic,strong) NSString                 *urlString;
@property (nonatomic,retain) UploadRecord             * uploadedRecord;
@property (nonatomic,retain) NSMutableArray           *uploadedFailRecord;
@property (nonatomic,assign) int                      currentUploadIndex;
@property (nonatomic,assign) int                      currentDownloadIndex;
/**
 *1下载成功
 *0下载失败
 *2正在等待前一个下载结束
 */
@property (nonatomic,assign) NSInteger stillParsing;
@end
@implementation InitBasicData
-(AFHTTPSessionManager*)manager{
    if(_manager==nil){
        return [AFHTTPSessionManager manager];
    }
    else{
        return _manager;
    }
}
-(NSString*)urlString{
    if(_urlString==nil){
        //return [urlString pathWithComponents:@"Framework/DataBase.ashx"];
        return @"http://192.168.0.207/xbyh/Framework/DataBase.ashx";
    }else{
        return _urlString;
    }
}
-(void)startDownload{
    _currentDownloadIndex = 0;
    self.progressView=[[AlertViewWithProgressbar alloc] initWithTitle:@"同步基础数据" message:@"正在下载，请稍候……" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    MAINDISPATCH(^(void){
        [self.progressView show];
    });
    for (int i = 0;i<total;i++ ) {
        [ self GetItemsWithSql:[NSString stringWithFormat:@"select * from %@",tables[i]]];
        WAITFORPARSER
    }
    
}
-(void)startUpload{
    _uploadedFailRecord=[[NSMutableArray alloc]initWithObjects: nil];
    _currentUploadIndex = 0;
    self.progressView=[[AlertViewWithProgressbar alloc] initWithTitle:@"上传业务数据" message:@"正在上传，请稍候……" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    MAINDISPATCH(^(void){
        [self.progressView show];
    });
    //    for (int i = 0;i<totalTablesForUpload;i++ ) {
    //        [ self uploadDataAtIndex:i];
    //        WAITFORPARSER
    //    }
    [self uploadDataAtIndex:_currentUploadIndex];
}

- (void)uploadDataAtIndex:(NSInteger)index{
    if(_currentUploadIndex>=totalTablesForUpload){
        [self.progressView dismissWithClickedButtonIndex:-1 animated:YES];
        [[ [UIAlertView alloc]initWithTitle:nil message:@"上传完成" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil]  show ];
        return;
    }
    NSString *currentDataName = updatetables[index];
    NSArray *dataArray        = [NSClassFromString(currentDataName) uploadArrayOfObject];
    if(dataArray.count>0){
        
        if([currentDataName isEqualToString:@"CasePhoto"]){//图片上传
            for (NSInteger i = 0;i < dataArray.count;i++) {
                id obj = [dataArray objectAtIndex:i];
                CasePhoto *photo = (CasePhoto *)obj;
                NSString* imagePath=photo.photopath;
                NSString* imageName=photo.photo_name;
                NSString *photostr=[obj dataXMLStringForCasePhoto];
                //@"/Users/admin/Desktop/WX20180117-092011@2x.png"
                NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentPath=[pathArray objectAtIndex:0];
                NSString *photoPath=[NSString stringWithFormat:@"%@/CasePhoto/%@/%@",documentPath,photo.project_id,photo.photo_name];
                UIImage *image=[UIImage imageWithContentsOfFile:photoPath];
                NSData*imageData=UIImageJPEGRepresentation(image, 0.5);
                NSString*imageString=[NSString base64forData:imageData];
                self.param                                        = [@{ @"File": imageString}  mutableCopy];
                NSString *url=[NSString stringWithFormat:@"%@?Ran = 8990&Command=UploadFile&path=%@&filename=%@",self.urlString,photo.photo_name,photo.photo_name] ;
                [self.manager POST: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:self.param  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [self.progressView setProgress:(int)(((float)(self.currentUploadIndex+1)/(float)totalTablesForUpload)*100.0)];
                    _currentUploadIndex += 1;
                    self.stillParsing   = 1;
                    if([responseObject[@"status"] isEqualToString:@"success"]){
                        NSLog([NSString stringWithFormat:@"%@表上传成功",currentDataName]);
                        [self uploadDataAtIndex:_currentUploadIndex];
                    }else{
                        NSLog([NSString stringWithFormat:@"%@表上传失败  原因：%@",currentDataName,responseObject[@"error"]]);
                        [self uploadDataAtIndex:_currentUploadIndex];
                        
                    }
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    NSLog([NSString stringWithFormat:@"%@表上传失败失败",currentDataName]);
                    [self.progressView setProgress:(int)(((float)(self.currentUploadIndex+1)/(float)totalTablesForUpload)*100.0)];
                    _currentUploadIndex += 1;
                    self.stillParsing   = 0;
                    [self uploadDataAtIndex:_currentUploadIndex];
                }];
            }
            
        }else{                                             //非图片数据上传
            NSString *objArrayString=[NSClassFromString(currentDataName) needUploadDataArray2JSONArrayString];
            self.param                                        = [@{ @"Value": objArrayString}  mutableCopy];
            NSString *url=[NSString stringWithFormat:@"%@?Ran = 8990&Command=InsertList&TableName=%@",self.urlString,currentDataName] ;
            [self.manager POST: [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:self.param  progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self.progressView setProgress:(int)(((float)(self.currentUploadIndex+1)/(float)totalTablesForUpload)*100.0)];
                _currentUploadIndex += 1;
                self.stillParsing   = 1;
                if([responseObject[@"status"] isEqualToString:@"success"]){
                    NSLog([NSString stringWithFormat:@"%@表上传成功",currentDataName]);
                    [self uploadDataAtIndex:_currentUploadIndex];
                }else{
                    NSLog([NSString stringWithFormat:@"%@表上传失败  原因：%@",currentDataName,responseObject[@"error"]]);
                    [self uploadDataAtIndex:_currentUploadIndex];
                    
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog([NSString stringWithFormat:@"%@表上传失败失败",currentDataName]);
                [self.progressView setProgress:(int)(((float)(self.currentUploadIndex+1)/(float)totalTablesForUpload)*100.0)];
                _currentUploadIndex += 1;
                self.stillParsing   = 0;
                [self uploadDataAtIndex:_currentUploadIndex];
            }];
        }
    }else{//表数据为空
        [self.progressView setProgress:(int)(((float)(self.currentUploadIndex+1)/(float)totalTablesForUpload)*100.0)];
        _currentUploadIndex += 1;
        self.stillParsing   = 1;
        NSLog([NSString stringWithFormat:@"%@表无数据需要上传",currentDataName]);
        [self uploadDataAtIndex:_currentUploadIndex];
    }
    
}

-(void)GetItemsWithSql:(NSString*)sqlString{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        self.param = @{@"Command":@"GetItems", @"sql":sqlString };
        [self.manager GET:self.urlString parameters:self.param progress:^(NSProgress * _Nonnull downloadProgress) {
            //
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"成功");
            self.currentParserCount += 1;
            NSString *table         = tables[self.currentParserCount-1];
            id datas                = responseObject;
            if(responseObject){
                [[AppDelegate App] clearEntityForName:table];
                NSLog([NSString stringWithFormat:@"开始解析%@表",table]);
                NSMutableArray * users=[ NSClassFromString(table) mj_objectArrayWithKeyValuesArray:datas context:[AppDelegate App].managedObjectContext];
                [[AppDelegate App] saveContext];
            }
            self.progressView.progress = self.currentParserCount*100/total;
            if(self.currentParserCount==total){
                [self.progressView dismissWithClickedButtonIndex:-1 animated:YES];
                self.currentParserCount = 0;
                [ [[UIAlertView alloc]initWithTitle:@"提示" message:@"下载完成" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil   , nil] show ];
            }
            self.stillParsing = 1;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"失败");
            self.stillParsing = 0;
        }];
    });
}

@end

