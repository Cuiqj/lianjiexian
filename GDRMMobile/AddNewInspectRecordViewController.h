//
//  AddNewInspectRecordViewController.h
//  GuiZhouRMMobile
//
//  Created by yu hongwu on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InspectionCheckPickerViewController.h"
#import "DateSelectController.h"
#import "InspectionRecord.h"
#import "InspectionHandler.h"
#import "RoadSegmentPickerViewController.h"
#import "BridgePickerViewController.h"
#import "RoadInspectViewController.h"
#import "ListSelectViewController.h"
#import "CaseDescListViewController.h"

typedef enum {
    kAddNewRecord = 0,
    kNormalDesc,
	kUnderBridgeCheck,
    kYiZhuanDuoNeng,
}DescState;

//@interface AddNewInspectRecordViewController : UIViewController<InspectionPickerDelegate,DatetimePickerHandler,UITextFieldDelegate,RoadSegmentPickerDelegate,BridgePickerDelegate >
@interface AddNewInspectRecordViewController : UIInputViewController<InspectionPickerDelegate,DatetimePickerHandler,UITextFieldDelegate,RoadSegmentPickerDelegate,BridgePickerDelegate,ListSelectPopoverDelegate ,CaseIDHandler>
@property (strong, nonatomic) IBOutlet UIScrollView *contentView;
@property (nonatomic,copy) NSString *inspectionID;
//@property (retain,retain) NSString *inspectRecordID;
@property (nonatomic,assign) RoadSegmentPickerState roadSegmentPickerState;
@property (nonatomic,assign) BridgePickerState bridgePickerState;
@property (nonatomic,assign) InspectionCheckState pickerState;
@property (nonatomic,retain) UIPopoverController *pickerPopover;
@property (nonatomic,retain) NSString *checkTypeID;
@property (weak, nonatomic) IBOutlet UITextField *textCheckType;
@property (weak, nonatomic) IBOutlet UITextField *textCheckReason;
@property (weak, nonatomic) IBOutlet UITextField *textCheckHandle;
@property (weak, nonatomic) IBOutlet UITextField *textCheckStatus;
@property (weak, nonatomic) IBOutlet UITextField *textSide;
@property (weak, nonatomic) IBOutlet UIButton *uibuttonSwitch;
@property (weak, nonatomic) IBOutlet UIButton *uibuttonToUnderBridgeCheck;

@property (weak, nonatomic) IBOutlet UITextField *textDate;
@property (weak, nonatomic) IBOutlet UITextField *textSegement;

@property (weak, nonatomic) IBOutlet UITextField *textPlace;
@property (weak, nonatomic) IBOutlet UITextField *textStationStartKM;
@property (weak, nonatomic) IBOutlet UITextField *textStationStartM;
@property (weak, nonatomic) IBOutlet UITextField *textStationEndKM;
@property (weak, nonatomic) IBOutlet UITextField *textStationEndM;

@property (weak, nonatomic) IBOutlet UIView *viewNormalDesc;
@property (weak, nonatomic) IBOutlet UIView * viewUnderBridgeCheck;
@property (weak, nonatomic) IBOutlet UIScrollView *ZLYHView;
 
@property (weak, nonatomic) IBOutlet UIScrollView *YZDNView;
@property (weak, nonatomic) IBOutlet UITextView *yzdnBeiZhu;
@property (weak, nonatomic) IBOutlet UITextField *yzdnCanYuRenYuan;
@property (weak, nonatomic) IBOutlet UITextView *yzdnGongZuoNeiRong;
@property (weak, nonatomic) IBOutlet UITextField *yzdnGangWei;
@property (weak, nonatomic) IBOutlet UITextField *yzdnShiJian;
@property (weak, nonatomic) IBOutlet UIButton *yzdnBtn;


@property (weak, nonatomic) IBOutlet UITextField *textTimeStart;
//@property (weak, nonatomic) IBOutlet UITextField *textTimeEnd;
@property (weak, nonatomic) IBOutlet UITextField *textRoad;
@property (weak, nonatomic) IBOutlet UITextField *textPlaceNormal;
@property (weak, nonatomic) IBOutlet UITextField *textDescNormal;
@property (weak, nonatomic) IBOutlet UITextView *textViewNormalDesc;


@property (weak, nonatomic) IBOutlet UITextField *textBridgeStartTime;
@property (weak, nonatomic) IBOutlet UITextField *textBridgeEndTime;
//桥梁名称
@property (weak, nonatomic) IBOutlet UITextField *textBridgeName;
@property (weak, nonatomic) IBOutlet UITextField *textBridgeDesc;
@property (weak, nonatomic) IBOutlet UITextView *textBridgeInspectDesc;
- (IBAction)btnToZlyh:(UIButton *)sender;

- (IBAction)btnFormNormalDesc:(id)sender;
- (IBAction)viewNormalTextTouch:(UITextField *)sender;
- (IBAction)viewNormalRoadTouch:(id)sender;
- (IBAction)pickerNormalDesc:(id)sender;
- (IBAction)addCounstructionChangeBack:(id)sender;
- (IBAction)addTrafficRecord:(id)sender;

//构造物检查
- (IBAction)btnConstructionInspection:(id)sender;

- (IBAction)btnGenerateBridgeInspectDesc:(id)sender;
- (IBAction)btnFuwuquJiancha:(UIButton *)sender;

@property (weak, nonatomic) id<InspectionHandler> delegate;
@property (assign, nonatomic) DescState descState;
- (IBAction)btnSwitch:(UIButton *)sender;

- (IBAction)btnDismiss:(id)sender;
- (IBAction)btnSave:(id)sender;
//点击文本框，弹出选择窗口
- (IBAction)textTouch:(UITextField *)sender;
//桥梁名称显示
- (IBAction)BridgeTouch:(UITextField *)sender;
- (IBAction)btnToShiGongCheck:(UIButton *)sender;
- (IBAction)toCaseView:(id)sender;
//桥下检查 按钮事件
- (IBAction)btntoUnderBridgeCheck:(UIButton *)sender;
- (IBAction)toAdminidtrativeCaseView:(id)sender;
- (IBAction)toUnderBridgeCheck:(id)sender;
- (IBAction)toAttachmentView:(id)sender ;
- (IBAction)selectGangwei:(UITextField *)sender;
- (IBAction)selectMutiPeople:(UITextField *)sender;

@end

/*
#import <UIKit/UIKit.h>
#import "InspectionCheckPickerViewController.h"
#import "DateSelectController.h"
#import "InspectionRecord.h"
#import "InspectionHandler.h"
#import "RoadSegmentPickerViewController.h"

@interface AddNewInspectRecordViewController : UIViewController<InspectionPickerDelegate,DatetimePickerHandler,UITextFieldDelegate,RoadSegmentPickerDelegate>
@property (nonatomic,copy) NSString *inspectionID;
@property (nonatomic,assign) RoadSegmentPickerState roadSegmentPickerState;
@property (nonatomic,assign) InspectionCheckState pickerState;
@property (nonatomic,retain) UIPopoverController *pickerPopover;
@property (nonatomic,retain) NSString *checkTypeID;
@property (weak, nonatomic) IBOutlet UITextField *textCheckType;
@property (weak, nonatomic) IBOutlet UITextField *textCheckReason;
@property (weak, nonatomic) IBOutlet UITextField *textCheckHandle;
@property (weak, nonatomic) IBOutlet UITextField *textCheckStatus;
@property (weak, nonatomic) IBOutlet UITextField *textWeather;
@property (weak, nonatomic) IBOutlet UITextField *textDate;
@property (weak, nonatomic) IBOutlet UITextField *textSegement;
@property (weak, nonatomic) IBOutlet UITextField *textSide;
@property (weak, nonatomic) IBOutlet UITextField *textPlace;
@property (weak, nonatomic) IBOutlet UITextField *textStationStartKM;
@property (weak, nonatomic) IBOutlet UITextField *textStationStartM;
@property (weak, nonatomic) IBOutlet UITextField *textStationEndKM;
@property (weak, nonatomic) IBOutlet UITextField *textStationEndM;

@property (weak, nonatomic) id<InspectionHandler> delegate;

- (IBAction)btnDismiss:(id)sender;
- (IBAction)btnSave:(id)sender;
//点击文本框，弹出选择窗口
- (IBAction)textTouch:(UITextField *)sender;


@end
*/
