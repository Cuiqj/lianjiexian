//
//  CaseViewController.h
//  GDRMMobile
//
//  Created by yu hongwu on 12-2-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataModelsHeader.h"
#import "AccInfoBriefViewController.h"
#import "CitizenInfoBriefViewController.h"
#import "DeformInfoBriefViewController.h"
#import "DeformationInfoViewController.h"
#import "InquireInfoViewController.h"
#import "InquireInfoBriefViewController.h"
#import "PaintBriefViewController.h"
#import "CasePaintViewController.h"
#import "CasePaintViewController.h"
#import "CaseDocumentsViewController.h"
#import "CaseListViewController.h"
#import "CaseIDHandler.h"
#import "CasePhoto.h"
#import "UserInfo.h"
#import "CaseInfoPickerViewController.h"

#import "CitizenListViewController.h"
#import "CaseDescListViewController.h"
#import "DateSelectController.h"

#import "CaseDocuments.h"
#import "RoadSegmentPickerViewController.h"
#import "RoadInspectViewController.h"
#import <AipOcrSdk/AipOcrSdk.h>

@interface CaseViewController : UIViewController<UITextFieldDelegate,CaseIDHandler,DatetimePickerHandler,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,RoadSegmentPickerDelegate,ReloadPaintDelegate,AipOcrDelegate,UIPopoverPresentationControllerDelegate,UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel            *payLabel;
@property (weak, nonatomic) IBOutlet UITextField        *textCasemark2;
@property (weak, nonatomic) IBOutlet UITextField        *textCasemark3;
@property (weak, nonatomic) IBOutlet UITextField        *textWeatheer;
@property (weak, nonatomic) IBOutlet UITextField        *textSide;
@property (weak, nonatomic) IBOutlet UITextField        *textPlace;
@property (weak, nonatomic) IBOutlet UITextField        *textRoadSegment;
@property (weak, nonatomic) IBOutlet UITextField        *textStationStartKM;
@property (weak, nonatomic) IBOutlet UITextField        *textStationStartM;
@property (weak, nonatomic) IBOutlet UITextField        *textStationEndKM;
@property (weak, nonatomic) IBOutlet UITextField        *textStationEndM;
@property (weak, nonatomic) IBOutlet UITextField        *textHappenDate;
@property (weak, nonatomic) IBOutlet UITextField        *textAutoPattern;    //所选车型
@property (weak, nonatomic) IBOutlet UITextField        *textBadDesc;        //所选损坏程度
@property (weak, nonatomic) IBOutlet UITextField        *textAutoNumber;     //所选车号
@property (weak, nonatomic) IBOutlet UILabel            *labelPhotoIndex;
@property (weak, nonatomic) IBOutlet UITextField        *textCaseDesc;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segInfoPage;
@property (weak, nonatomic) IBOutlet UIScrollView       *infoView;
@property (weak, nonatomic) IBOutlet UIButton           *uiButtonEdit;            //编辑
@property (weak, nonatomic) IBOutlet UIButton           *uiButtonNewCase;         //新增
@property (weak, nonatomic) IBOutlet UIButton           *uiButtonSave;            //保存
@property (weak, nonatomic) IBOutlet UIButton *  uiButtonSavebaoxian;   //保险案件


@property (weak, nonatomic) IBOutlet UIButton           *uiButtonCamera;          //拍照
@property (weak, nonatomic) IBOutlet UIButton           *uiButtonPickFromLibrary; //相册
@property (weak, nonatomic) IBOutlet UITableView        *docListView;
@property (weak, nonatomic) IBOutlet UITableView        *docTemplatesView;

//@property (weak,nonatomic) IBOutlet UITableView *testList;

@property (nonatomic,retain) NSString *caseID;
@property (nonatomic,retain) CaseInfo *caseInfo;
@property (nonatomic,retain) Citizen  *citizenInfo;

//@property (nonatomic,retain) id infoPageVC;
@property (nonatomic,retain) AccInfoBriefViewController     *accInfoBriefVC;
@property (nonatomic,retain) CitizenInfoBriefViewController *citizenInfoBriefVC;
@property (nonatomic,retain) DeformInfoBriefViewController  *deformInfoVC;
@property (nonatomic,retain) InquireInfoBriefViewController *inquireInfoBriefVC;
@property (nonatomic,retain) PaintBriefViewController       *paintBriefVC;

@property (nonatomic,assign) BOOL needsMove;

@property (nonatomic, retain) NSString                  *inspectionID;
@property (nonatomic, retain) NSString                  *sfzID;
@property (nonatomic, assign) RoadInspectViewController *roadInspectVC;

- (IBAction)btnImageFromCamera:(id)sender;
- (IBAction)btnImageFromLibrary:(id)sender;
- (IBAction)btnClickToEditor:(id)sender;
- (IBAction)btnNewCase:(id)sender;
- (IBAction)selectWeather:(id)sender;
- (IBAction)selectRoadSegmet:(UITextField *)sender;
- (IBAction)selectRoadSide:(UITextField *)sender;
- (IBAction)selectRoadPlace:(UITextField *)sender;
- (IBAction)selectAutoMobilePattern:(id)sender;
- (IBAction)selectBadDesc:(id)sender;
- (IBAction)selectCitizen:(id)sender;
- (IBAction)selectCaseDesc:(id)sender;
- (IBAction)selectDateAndTime:(id)sender;
- (IBAction)btnSaveCaseInfo:(id)sender;
- (IBAction)btnSavebaoxianCaseInfo:(id)sender;   //保存到保险案件并跳转

- (IBAction)btnPreviousCase:(id)sender;

- (IBAction)SwitchOnOrOff:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchNumber;

- (IBAction)changeInfoPage:(UISegmentedControl *)sender;

-(void)saveCaseInfoForCase:(NSString *)caseID;
-(void)loadCaseInfoForCase:(NSString *)caseID;

-(void)saveCitizenInfoForCase:(NSString *)caseID andAutoNumber:(NSString *)aAutoNumber;
-(void)loadCitizenInfoForCase:(NSString *)caseID andAutoNumber:(NSString *)aAutoNumber;

-(void)saveCaseProveInfoForCase:(NSString *)caseID;
-(void)loadCaseProveInfoForCase:(NSString *)caseID;
-(BOOL)checkCaseBaseInfo;
@end
