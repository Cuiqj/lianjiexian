//
//  LineAtonementnotice.h
//  LianJieXianMobile
//
//  Created by admin on 2018/10/18.
//

#import "BaseManageObject.h"

@interface LineAtonementnotice : BaseManageObject

@property (nonatomic, retain) NSString * myid;
@property (nonatomic, retain) NSString * lineparty;
@property (nonatomic, retain) NSString * lineadress;
@property (nonatomic, retain) NSString * lineorganization_info_part1;
@property (nonatomic, retain) NSString * lineorganization_info_part2;
@property (nonatomic, retain) NSString * linecase_desc;
//@property (nonatomic, retain) NSString * linecase_desc_part2;
@property (nonatomic, retain) NSString * line_pay_reason;
//@property (nonatomic, retain) NSString * line_pay_reason_part2;
//@property (nonatomic, retain) NSString * line_pay_reason_part3;


+ (LineAtonementnotice *)AtonementNoticesForCase:(NSString *)caseID;
+ (NSString *)NsstringofLengthforNsstring:(NSString *)str;

@end
