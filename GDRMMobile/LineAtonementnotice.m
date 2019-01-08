//
//  LineAtonementnotice.m
//  LianJieXianMobile
//
//  Created by admin on 2018/10/18.
//

#import "LineAtonementnotice.h"

@implementation LineAtonementnotice

@dynamic myid;
@dynamic lineparty;
@dynamic lineadress;
@dynamic lineorganization_info_part1;
@dynamic lineorganization_info_part2;
@dynamic linecase_desc;
//@dynamic linecase_desc_part2;
@dynamic line_pay_reason;
//@dynamic line_pay_reason_part2;
//@dynamic line_pay_reason_part3;


+ (LineAtonementnotice *)AtonementNoticesForCase:(NSString *)caseID{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"LineAtonementnotice" inManagedObjectContext:context];
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
+ (NSString *)NsstringofLengthforNsstring:(NSString *)str{
    NSString * result = @"";;
    NSArray * num = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"[",@"]",@"+",@"《",@"》"];
    NSArray * letter = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
    for (int i = 0,j = 0; i<str.length; i++) {
        NSString * temp = [str substringWithRange:NSMakeRange(i, 1)];
        if ([num containsObject:temp] || [letter containsObject:temp]) {
            j += 1;
            if(j%2==0){
                result = [result stringByAppendingString:@"—"];
            }
        }else{
            result = [result stringByAppendingString:@"—"];
        }
    }
    return result;
}


@end
