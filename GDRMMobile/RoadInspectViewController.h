//
//  RoadInspectViewController.h
//  GDRMMobile
//
//  Created by yu hongwu on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InspectionConstruction.h"

#import <UIKit/UIKit.h>
#import "AddNewInspectRecordViewController.h"
#import "InspectionRecordCell.h"
#import "NewInspectionViewController.h"
#import "InspectionOutViewController.h"
#import "InspectionListViewController.h"
#import "InspectionCheckPickerViewController.h"
#import "DateSelectController.h"
#import "TrafficRecord.h"
#import "AttachmentViewController.h"
//#import "DynamicInfoViewController.h"
#import "RoadWayClosed.h"
#import "BaoxianCaseViewController.h"
#import "ServiceManage.h"
//#import "AddNewInspectRecordViewController.h"

typedef enum {
    kRecord = 0,
    kPath
} InpectionState;

@interface RoadInspectViewController : UIViewController<DatetimePickerHandler,InspectionListDelegate,UITableViewDataSource,UITableViewDelegate,InspectionHandler,UITextFieldDelegate,InspectionPickerDelegate, UIAlertViewDelegate>
- (IBAction)btnSaveRemark:(UIButton *)sender;
- (IBAction)btnDeliver:(UIButton *)sender;
- (IBAction)segSwitch:(id)sender;
- (IBAction)selectionStation:(id)sender;
- (IBAction)selectTime:(id)sender;
- (IBAction)selectCheckStatus:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *pathView;
@property (weak, nonatomic) IBOutlet UILabel *labelInspectionInfo;
@property (weak, nonatomic) IBOutlet UITextView *textViewRemark;
@property (weak, nonatomic) IBOutlet UITableView *tableRecordList;
@property (weak, nonatomic) IBOutlet UILabel *labelRemark;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonAddNew;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonFujian;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonSave;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonDeliver;
@property (weak, nonatomic) IBOutlet UISegmentedControl *inspectionSeg;
@property (weak, nonatomic) IBOutlet UITextField *textCheckTime;
@property (weak, nonatomic) IBOutlet UITextField *textStationName;
@property (weak, nonatomic) IBOutlet UITextField *textCheckStatus;

@property (nonatomic,retain) NSString *inspectionID;
//@property (nonatomic,retain) NSString *inspectRecordID;
@property (nonatomic,assign) InpectionState state;


@property (nonatomic,retain) UIStoryboardSegue *mysegue;
- (IBAction)btnInpectionList:(id)sender;
- (IBAction)btnAddNew:(id)sender;
- (IBAction)btnToFujian:(id)sender;

- (void) createRecodeByCaseID:(NSString *)inspectRecordID;
- (void) createRecodeByShiGongCheckID:(NSString *)shiGongCheckID;
- (void) createRecodeByShiGongCheckID:(NSString *)shiGongCheckID;
- (void) createRecodeByShiGongCheck:(NSString *)shiGongCheckID withRemark:(NSString *)Remark;
- (void) setxxx:(NSString *)inspectRecordID;
//交通事故登记描述
- (void) createRecodeByTrafficRecord:(TrafficRecord *)trafficRecord;
- (void) createRecodeByDynamicInfo:(RoadWayClosed *)DynamicInfo;
- (void) createRecodeByBaoxianCase:(NSString  *)baoxianCaseId;
- (void) createRecodeByServicesCheck:(ServiceManage  *)ServicesCheck;

//构造物检查描述
- (void)createRecodeInspectionConstruction:(InspectionConstruction *)inspectionconstruction;

@end
