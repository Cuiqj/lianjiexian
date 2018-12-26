//
//  CaseInfo.m
//  GDRMMobile
//
//  Created by yu hongwu on 12-11-14.
//
//

#import "CaseInfo.h"
#import "FileCode.h"
#import "RoadSegment.h"

NSString * const CaseTypeIDPei = @"11";
NSString * const CaseTypeIDFa = @"12";
NSString * const CaseTypeIDDefault = @"11";
NSString * const CaseTypeIDBaoxian = @"20";

static NSString *lochus_code = @"";


@implementation CaseInfo

@dynamic badcar_sum;
@dynamic badwound_sum;
@dynamic case_mark2;
@dynamic case_mark3;
@dynamic case_reason;
@dynamic case_style;
@dynamic case_type;
@dynamic case_type_id;
@dynamic death_sum;
@dynamic fleshwound_sum;
@dynamic happen_date;
@dynamic myid;
@dynamic organization_id;
@dynamic place;
@dynamic roadsegment_id;
@dynamic side;
@dynamic station_end;
@dynamic station_start;
@dynamic weater;
@dynamic isuploaded;
@dynamic project_id;
@dynamic peccancy_type;
@dynamic case_character;
@dynamic case_disposal;




@dynamic car_bump_part;
@dynamic bump_object;
@dynamic car_stop_status;
@dynamic car_stop_side;
@dynamic head_side;
@dynamic body_side;
@dynamic tail_side;
@dynamic car_looks;


@dynamic insurance_company;
@dynamic insurance_no;

@dynamic sfz_id;

- (NSString *) signStr{
    if (![self.myid isEmpty]) {
        return [NSString stringWithFormat:@"myid == %@", self.myid];
    }else{
        return @"";
    }
}

//读取案号对应的案件信息记录
+(CaseInfo *)caseInfoForID:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInfo" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"myid == %@",caseID];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    if (fetchResult.count>0) {
        return [fetchResult objectAtIndex:0];
    } else {
        return nil;
    }
}

//删除对应案号的信息记录
+ (void)deleteCaseInfoForID:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInfo" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"myid == %@",caseID];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    if (fetchResult.count>0) {
        NSString *project_id = [[fetchResult objectAtIndex:0] valueForKey:@"project_id"];
        [context deleteObject:[fetchResult objectAtIndex:0]];
        entity = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:context];
        if ([context countForFetchRequest:fetchRequest error:nil]>0) {
            [context deleteObject:[[context executeFetchRequest:fetchRequest error:nil] objectAtIndex:0]];
        }
        entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:context];
        predicate = [NSPredicate predicateWithFormat:@"myid == %@",project_id];
        [fetchRequest setPredicate:predicate];
        if ([context countForFetchRequest:fetchRequest error:nil]>0) {
            [context deleteObject:[[context executeFetchRequest:fetchRequest error:nil] objectAtIndex:0]];
        }
    }
    [context save:nil];
    //根据案号删除对应文件夹
    NSFileManager *manager=[NSFileManager defaultManager];
    NSArray *pathArray=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[pathArray objectAtIndex:0];
    NSString *photoPath=[NSString stringWithFormat:@"CasePhoto/%@",caseID];
    photoPath=[documentPath stringByAppendingPathComponent:photoPath];
    if ([manager fileExistsAtPath:photoPath]) {
        [manager removeItemAtPath:photoPath error:nil];
    }
    NSString *docPath=[NSString stringWithFormat:@"CaseDoc/%@",caseID];
    docPath=[documentPath stringByAppendingPathComponent:docPath];
    if ([manager fileExistsAtPath:docPath]) {
        [manager removeItemAtPath:docPath error:nil];
    }
    NSString *mapPath=[NSString stringWithFormat:@"CaseMap/%@",caseID];
    mapPath=[documentPath stringByAppendingPathComponent:mapPath];
    if ([manager fileExistsAtPath:mapPath]) {
        [manager removeItemAtPath:mapPath error:nil];
    }
}

//删除无用的空记录
+ (void)deleteEmptyCaseInfo{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInfo" inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"case_mark2 == nil || case_mark3 == nil"];
    fetchRequest.predicate=predicate;
    fetchRequest.entity=entity;
    NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
    for (id obj in fetchResult) {
        [context deleteObject:obj];
    }
    [context save:nil];
}

+ (NSInteger)maxCaseMark3{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInfo" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"case_type_id == 11"];
    request.predicate=predicate;
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"case_mark3"];
    NSExpression *maxCaseMark3Expression = [NSExpression expressionForFunction:@"max:"
                                                                     arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxCase_mark3"];
    [expressionDescription setExpression:maxCaseMark3Expression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    [request setPropertiesToFetch:@[expressionDescription]];
    [request setResultType:NSDictionaryResultType];
    NSArray *objects = [context executeFetchRequest:request error:nil];
    if (objects.count > 0) {
        return [[[objects objectAtIndex:0] valueForKey:@"maxCase_mark3"] integerValue];
    } else {
        return 0;
    }
}
+ (NSInteger)maxCaseMark3ForAdministrativePenalty{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"CaseInfo" inManagedObjectContext:context];
    NSFetchRequest *request=[[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"case_type_id == 12"];
    request.predicate=predicate;
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"case_mark3"];
    NSExpression *maxCaseMark3Expression = [NSExpression expressionForFunction:@"max:"
                                                                     arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxCase_mark3"];
    [expressionDescription setExpression:maxCaseMark3Expression];
    [expressionDescription setExpressionResultType:NSInteger32AttributeType];
    [request setPropertiesToFetch:@[expressionDescription]];
    [request setResultType:NSDictionaryResultType];
    NSArray *objects = [context executeFetchRequest:request error:nil];
    if (objects.count > 0) {
        return [[[objects objectAtIndex:0] valueForKey:@"maxCase_mark3"] integerValue];
    } else {
        return 0;
    }
}
- (NSString *)station_start_km{
    return [[NSString alloc] initWithFormat:@"%02d",self.station_start.integerValue/1000];
}
- (NSString *)station_start_m{
    return [[NSString alloc] initWithFormat:@"%03d",self.station_start.integerValue%1000];
}

- (NSString *)side_short{
    NSRange found = [self.side rangeOfString:@"方向"];
    if (found.location == NSNotFound) {
        return self.side;
    }else{
        return [self.side substringToIndex:found.location];
    }
}
- (NSString *)full_case_mark3{
    if ([lochus_code isEmpty]) {
        NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
        NSEntityDescription *entity=[NSEntityDescription entityForName:@"FileCode" inManagedObjectContext:context];
        NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
        fetchRequest.entity=entity;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file_name == %@", @"赔补偿案件编号"];
        fetchRequest.predicate = predicate;
        NSArray *fetchResult=[context executeFetchRequest:fetchRequest error:nil];
        
        if (fetchResult && [fetchResult count]>0) {
            FileCode *fileCode = [fetchResult objectAtIndex:0];
            lochus_code = [NSString stringWithString:fileCode.lochus_code];
        }
    }
    return [NSString stringWithFormat:@"%@%@", lochus_code, self.case_mark3];
}

- (NSString *)full_happen_place{
    NSString *roadName = [RoadSegment roadNameFromSegment:self.roadsegment_id];
    if(self.sfz_id.integerValue>0)
        return [NSString stringWithFormat:@"%@%@%@", roadName, self.side, self.place];
    else
        return [NSString stringWithFormat:@"%@%@K%@+%@M%@", roadName, self.side, [self station_start_km], [self station_start_m], self.place];
}
- (NSString *)roadnameAndPlace{
    NSString *roadName = [RoadSegment roadNameFromSegment:self.roadsegment_id];
    if(self.sfz_id.integerValue>0)
        return [NSString stringWithFormat:@"%@%@", roadName, self.side];
    else
        return [NSString stringWithFormat:@"%@%@", roadName, self.side];
}

-(NSString *)roadName{
 NSString *roadName = [RoadSegment roadNameFromSegment:self.roadsegment_id];
    return roadName;

}

-(NSString *)full_roadName{
    NSString *roadName =[RoadSegment roadNameFromSegment:self.roadsegment_id];
    NSString *full_roadName=[NSString stringWithFormat:@"%@%@方向",roadName,[self side_short]];
    return full_roadName;
}

- (NSString *)service_position{
    NSString *roadName = [RoadSegment roadNameFromSegment:self.roadsegment_id];
    if(self.station_end.integerValue ==0 && self.station_start.integerValue == 0){
        return [NSString stringWithFormat:@"%@%@%@", roadName, self.side,[self place]];
    }
    return [NSString stringWithFormat:@"%@%@K%@+%@M%@", roadName, self.side, [self station_start_km], [self station_start_m],[self place]];
}
- (NSString *)organization_label
{
    return [FileCode fileCodeWithPredicateFormat:@"赔补偿案件编号"].organization_code;
}
- (NSString *)count_place{
    return  [self.place stringByReplacingOccurrencesOfString:@"侧" withString:@""];
}


- (NSString *)FullmMrkforcaseinfo{
//    return [NSString stringWithFormat:@"%@%@", lochus_code, self.case_mark3];
    if(self.case_mark2.length >0 && self.full_case_mark3.length>0){
                return [NSString stringWithFormat:@"%@年%@号",self.case_mark2,self.full_case_mark3];
    }
    return nil;
}

@end
