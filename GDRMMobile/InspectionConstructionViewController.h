//
//  InspectionConstructionViewController.h
//  GDRMMobile
//
//  Created by yu hongwu on 14-8-18.
//
//

#import "RoadInspectViewController.h"

#import <UIKit/UIKit.h>
#import "InspectionConstructionViewController.h"
#import "InspectionConstruction.h"
#import "DateSelectController.h"
#import "UserPickerViewController.h"
#import "CaseInfoPickerViewController.h"
#import "CasePrintViewController.h"

@interface InspectionConstructionViewController : CasePrintViewController<UserPickerDelegate,DatetimePickerHandler,UITextFieldDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,CaseIDHandler>
@property (weak, nonatomic) IBOutlet UIButton *uiBtnSave;
@property (weak, nonatomic) IBOutlet UITableView *tableCloseList;    //构造物检查记录
@property (weak, nonatomic) IBOutlet UIScrollView *scrollContent;       //右边是一个scrollview
@property (weak, nonatomic) IBOutlet UITextField *inspectionDate;       //巡查日期
@property (weak, nonatomic) IBOutlet UITextField *timeStart1;           //序号1检查时间
@property (weak, nonatomic) IBOutlet UITextField *timeEnd1;             //序号1检查时间
@property (weak, nonatomic) IBOutlet UITextField *weather1;             //天气
@property (weak, nonatomic) IBOutlet UITextField *textStartKM1;
@property (weak, nonatomic) IBOutlet UITextField *textStartM1;
@property (weak, nonatomic) IBOutlet UITextField *textEndKM1;
@property (weak, nonatomic) IBOutlet UITextField *textEndM1;
@property (weak, nonatomic) IBOutlet UITextField *inspectionor1;        //序号1巡查人员

@property (weak, nonatomic) IBOutlet UITextField *timeStart2;
@property (weak, nonatomic) IBOutlet UITextField *timeEnd2;
@property (weak, nonatomic) IBOutlet UITextField *weather2;
@property (weak, nonatomic) IBOutlet UITextField *textStartKM2;
@property (weak, nonatomic) IBOutlet UITextField *textStartM2;
@property (weak, nonatomic) IBOutlet UITextField *textEndKM2;
@property (weak, nonatomic) IBOutlet UITextField *textEndM2;
@property (weak, nonatomic) IBOutlet UITextField *inspectionor2;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (retain, nonatomic) NSURL *pdfFormatFileURL;
@property (retain, nonatomic) NSURL *pdfFileURL;

@property (nonatomic, strong) RoadInspectViewController * roadVC;

- (IBAction)btnAddNew:(UIButton *)sender;           //新增
- (IBAction)btnSave:(UIButton *)sender;             //保存
- (IBAction)textTouch:(UITextField *)sender;
- (IBAction)userSelect:(UITextField *)sender;       //人员选择
- (IBAction)toAttachmentView:(id)sender;            //附件
- (IBAction)toPrintView:(id)sender;                 //去打印
- (IBAction)btnDeleteDoc:(id)sender;
@end

