//
//  AtonementNotice.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-15.
//
//

#import "OrgInfo.h"
#import "UserInfo.h"

#import "AtonementNotice.h"
#import "Systype.h"

@implementation AtonementNotice

@dynamic myid;
@dynamic caseinfo_id;
@dynamic citizen_name;
@dynamic code;
@dynamic date_send;
@dynamic check_organization;
@dynamic case_desc;
@dynamic witness;
@dynamic pay_reason;
@dynamic pay_mode;
@dynamic organization_id;
@dynamic remark;
@dynamic isuploaded;

- (NSString *)signStr{
    if (![self.caseinfo_id isEmpty]) {
        return [NSString stringWithFormat:@"caseinfo_id == %@", self.caseinfo_id];
    }else{
        return @"";
    }
}

+ (NSArray *)AtonementNoticesForCase:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"caseinfo_id==%@",caseID];
    fetchRequest.predicate = predicate;
    fetchRequest.entity    = entity;
    return [context executeFetchRequest:fetchRequest error:nil];
}

- (NSString *)organization_info{
//    NSString*s1=[[self.organization_id stringByReplacingOccurrencesOfString:@"一中队" withString:@""] stringByReplacingOccurrencesOfString :@"二中队" withString:@""];
    [AtonementNotice newDataObjectWithEntityName:@""];
//    return  [[s1 stringByReplacingOccurrencesOfString:@"三中队" withString:@""] stringByReplacingOccurrencesOfString :@"四中队" withString:@""];
    NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
    NSString * organization_info = [[OrgInfo orgInfoForOrgID:[UserInfo userInfoForUserID:currentUserID].organization_id] valueForKey:@"orgname"];
    if ([organization_info containsString:@"路政一中队"]) {
        return [organization_info stringByReplacingOccurrencesOfString:@"路政一中队" withString:@"路政大队一中队"];
    }
    return organization_info;
}

- (NSString *)bank_name{
//    return @"中交清运投资发展有限公司";
    return [[Systype typeValueForCodeName:@"交款地点"] objectAtIndex:0];
//    NSString  * all = [[Systype typeValueForCodeName:@"交款地点"] objectAtIndex:0];
//    return
//    [all stringByReplacingOccurrencesOfString: self.bank_namehead withString:@""];
}
- (NSString *)bank_namehead{
    NSString * full = [[Systype typeValueForCodeName:@"交款地点"] objectAtIndex:0];
    return  [full substringToIndex:10];
}
-(NSString *)new_case_desc{
    NSArray *temp=[self.case_desc componentsSeparatedByString:@"日"];
    return [temp objectAtIndex:1];
//    return [NSString stringWithFormat:@"%@%@",self.citizen_name,self.case_desc];
}
-(NSString *)new_pay_reason{
//    return [NSString stringWithFormat:@"损坏路产的事实清楚，应依法承担民事责任，赔偿路产损失。依%@之规定",self.pay_reason];
    return self.pay_reason;
    //    NSArray *temp=[self.pay_reason componentsSeparatedByString:@"根据"];
    //    NSString * ss=[temp objectAtIndex:1];
    //    NSArray *temp2=[ss componentsSeparatedByString:@"的规定"];
    //    return [temp2 objectAtIndex:0];
}
-(NSString*)pay_mode2{
    NSString *s1 = [[self.pay_mode stringByReplacingOccurrencesOfString:@"元" withString:@""]  stringByReplacingOccurrencesOfString:@"元整" withString:@""];
    return [[s1 stringByReplacingOccurrencesOfString:@"整" withString:@""]  stringByReplacingOccurrencesOfString:@"元整" withString:@""];
}
- (NSString *)organization_info_part1{
    return [[self subString2:self.organization_id] objectAtIndex:0];
}
- (NSString *)organization_info_part2{
    return [[self subString2:self.organization_id] objectAtIndex:1];
}
-(NSArray *)subString2:(NSString *)str {
    
    NSMutableArray * array = [[NSMutableArray alloc]init];
    
    if (str != nil){
        
        //从开始截取到指定索引字符   但不包含此字符  。
        NSString * tempStr1 = [str substringToIndex:str.length/2+1];
        
        //从指定字符串截取到末尾
        NSString * tempStr2 = [str substringFromIndex:str.length/2+1];
        
        [array addObject:tempStr1];
        
        [array addObject:tempStr2];
    }
    
    return array;
}
@end
