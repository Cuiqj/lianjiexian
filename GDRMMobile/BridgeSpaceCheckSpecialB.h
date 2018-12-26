//
//  BridgeSpaceCheckSpecialB.h
//  YUNWUMobile
//
//  Created by admin on 2018/8/20.
//

#import <CoreData/CoreData.h>

@interface BridgeSpaceCheckSpecialB : NSManagedObject

@property(nonatomic,retain) NSString * road_name;          //路段名称
@property(nonatomic,retain) NSString * org_id;          //管理单位id
@property(nonatomic,retain) NSString * check_user;      //检查人员
@property(nonatomic,retain) NSDate   * check_date;        //检查日期
@property(nonatomic,retain) NSDate   * finish_date;     //完成整改日期
@property(nonatomic,retain) NSString * myid;        //      自己标识
@property(nonatomic,retain) NSString * bsd_id;     //     关联另一个表
//@property(nonatomic,retain) NSString * check_mana;          //检查负责人
//@property(nonatomic,retain) NSString * check_org_id;        //受检单位
@property (nonatomic, retain) NSNumber * isuploaded;

+(BridgeSpaceCheckSpecialB *)BridgeSpaceCheckSpecialBforcaseID:(NSString *)caseID;
+(NSArray *)BridgeSpaceCheckSpecialBforArray;
+ (BridgeSpaceCheckSpecialB *)newDataObjectWithEntityName;
@end
