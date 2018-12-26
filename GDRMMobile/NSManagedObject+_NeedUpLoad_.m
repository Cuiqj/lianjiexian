//
//  NSManagedObject+_NeedUpLoad_.m
//  GuiZhouRMMobile
//
//  Created by Sniper One on 12-10-29.
//
//

#import "NSManagedObject+_NeedUpLoad_.h"
#import "NSString+Base64.h"
#import "Project.h"
#import "Task.h"
#import "CaseInfo.h"
#import "UserInfo.h"
#import "CasePhoto.h"

#define NodeNameDefault @"现场勘验"
#define NodeIDDefault   @"1"

@implementation NSManagedObject (_NeedUpLoad_)

+ (NSArray *)uploadArrayOfObject{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    if ([NSStringFromClass([self class]) isEqualToString:@"CasePhoto"]) {
        [fetchRequest setPredicate:[NSPredicate  predicateWithFormat:@"isuploaded.boolValue == NO && (proveinfo_id != nil||project_id!=nil)"]];
        //[fetchRequest setPredicate:[NSPredicate  predicateWithFormat:@"isuploaded.boolValue == NO"  ]];
    }else if ([NSStringFromClass([self class]) isEqualToString:@"CarCheckRecords"]) {
        [fetchRequest setPredicate:[NSPredicate  predicateWithFormat:@"isuploaded.boolValue == NO &&  parent_id != nil "]];
        //[fetchRequest setPredicate:[NSPredicate  predicateWithFormat:@"isuploaded.boolValue == NO"  ]];
    }else if ([NSStringFromClass([self class]) isEqualToString:@"RoadAsset_Check_detail"]) {
        [fetchRequest setPredicate:[NSPredicate  predicateWithFormat:@"isuploaded.boolValue == NO &&  status ==1 "]];
        //[fetchRequest setPredicate:[NSPredicate  predicateWithFormat:@"isuploaded.boolValue == NO"  ]];
    }else{
        [fetchRequest setPredicate:[NSPredicate  predicateWithFormat:@"isuploaded.boolValue == NO"]];
    }
    
    return [context executeFetchRequest:fetchRequest error:nil];
}

+ (id)newDataObjectWithEntityName:(NSString *)entityName{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    id obj = [[NSClassFromString(entityName) alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    if ([obj respondsToSelector:@selector(setMyid:)]) {
        [obj setValue:[NSString randomID] forKey:@"myid"];
    }
    if ([obj respondsToSelector:@selector(isuploaded)]) {
        [obj setValue:@(NO) forKey:@"isuploaded"];
    }
    if ([obj respondsToSelector:@selector(organization_id)]) {
        NSString *currentUserID=[[NSUserDefaults standardUserDefaults] stringForKey:USERKEY];
        NSString *orgID = [UserInfo userInfoForUserID:currentUserID].organization_id;
        [obj setValue:orgID forKey:@"organization_id"];
    }
    if ([entityName isEqualToString:@"CaseInfo"]) {
        CaseInfo *caseInfo    = (CaseInfo *)obj;
        Project *project      = (Project *)[NSManagedObject newDataObjectWithEntityName:@"Project"];
        project.process_id    = ProcessIDDefault;
        project.process_name  = ProcessNameDefault;
        project.start_time    = [NSDate date];
        project.inite_node_id = caseInfo.myid;
        Task *task            = (Task *)[NSManagedObject newDataObjectWithEntityName:@"Task"];
        caseInfo.case_type_id = CaseTypeIDDefault;
        caseInfo.project_id   = project.myid;
        task.myid             = caseInfo.myid;
        task.node_name        = NodeNameDefault;
        task.node_id          = NodeIDDefault;
        task.project_id       = project.myid;
        task.start_time       = [NSDate date];
        [[AppDelegate App] saveContext];
    }
    return obj;
}

+ (NSString *)complexTypeString{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    NSDictionary *attributes = [entity attributesByName];
    NSString *typeString     = @"";
    
    for (NSString *attriName in [attributes allKeys]) {
        if (![attriName isEqualToString:@"isuploaded"]) {
            NSAttributeDescription *attriDesc = [attributes objectForKey:attriName];
            NSString *elementString;
            switch (attriDesc.attributeType) {
                case NSDateAttributeType:
                    elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"%@\" type=\"xs:dateTime\" minOccurs=\"0\" />\r",attriName];
                    break;
                default:{
                    if ([attriName isEqualToString:@"myid"]) {
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"id\" type=\"xs:string\" minOccurs=\"0\" />\r"];
                    } else if ([attriName isEqualToString:@"inspection_description"]){
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"description\" type=\"xs:string\" minOccurs=\"0\" />\r"];
                    } else if ([attriName isEqualToString:@"map_item"]) {
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"%@\" type=\"xs:string\" minOccurs=\"0\" />\r",attriName];
                        for (int i    = 1; i <= 9; i++) {
                            elementString = [elementString stringByAppendingFormat:@"<xs:element name=\"%@%d\" type=\"xs:string\" minOccurs=\"0\" />\r",attriName,i];
                        }
                    } else {
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"%@\" type=\"xs:string\" minOccurs=\"0\" />\r",attriName];
                    }
                }
                    break;
            }
            typeString = [typeString stringByAppendingString:elementString];
        }
    }
    
    typeString = [[NSString alloc] initWithFormat:@"<xs:schema id=\"NewDataSet\" xmlns=\"\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:msdata=\"urn:schemas-microsoft-com:xml-msdata\">\r"
                  "   <xs:element name=\"NewDataSet\" msdata:IsDataSet=\"true\" msdata:Locale=\"zh-CN\">\r"
                  "       <xs:complexType>\r"
                  "           <xs:choice maxOccurs=\"unbounded\">\r"
                  "               <xs:element name=\"%@\">\r"
                  "                   <xs:complexType>\r"
                  "                       <xs:sequence>\r"
                  "                           %@\r"
                  "                       </xs:sequence>\r"
                  "                   </xs:complexType>\r"
                  "               </xs:element>\r"
                  "           </xs:choice>\r"
                  "       </xs:complexType>\r"
                  "   </xs:element>\r"
                  "</xs:schema>\r",NSStringFromClass([self class]),typeString];
    return typeString;
}
- (NSString *)dataJSONString{
    NSString *dataJSONString = @"";
    NSEntityDescription *entity=[self entity];
    NSDictionary *attributes = [entity attributesByName];
    for (NSString *attriName in [attributes allKeys]) {
        if (![attriName isEqualToString:@"isuploaded"]) {
            NSAttributeDescription *attriDesc = [attributes objectForKey:attriName];
            NSString *elementString           = @"";
            id obj                            = [self valueForKey:attriName];
            switch (attriDesc.attributeType) {
                case NSStringAttributeType:{
                    if (obj == nil) {
                        obj = @"";
                    }
                    if (![attriName isEqualToString:@"maintainplan_id"]) {
                        if ([attriName isEqualToString:@"myid"]) {
                            elementString = [[NSString alloc] initWithFormat:@"\"id\":\"%@\",",obj];
                        } else if ([attriName isEqualToString:@"inspection_description"]) {
                            elementString = [[NSString alloc] initWithFormat:@"\"description\":\"%@\",",obj];
                        } else if ([attriName isEqualToString:@"map_item"]) {
                            elementString = [[NSString alloc] initWithFormat:@"<%@><![CDATA[%@]]></%@><map_item1></map_item1><map_item2></map_item2><map_item3></map_item3><map_item4></map_item4><map_item5></map_item5><map_item6></map_item6><map_item7></map_item7><map_item8></map_item8><map_item9></map_item9>",attriName,obj,attriName];
                        } else {
                            obj           = [obj stringByReplacingOccurrencesOfString:@"\n" withString:@"\r\n"];
                            obj           = [obj stringByReplacingOccurrencesOfString:@"\r" withString:@"\r\n"];
                            elementString = [[NSString alloc] initWithFormat:@"\"%@\":\"%@\",",attriName,obj];
                        }
                    }
                }
                    break;
                case NSBooleanAttributeType:
                case NSFloatAttributeType:
                case NSDoubleAttributeType:
                case NSInteger16AttributeType:
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:{
                    if (obj) {
                        elementString = [[NSString alloc] initWithFormat:@"\"%@\":\"%@\",",attriName,[obj stringValue] ];
                    } else {
                        elementString = [[NSString alloc] initWithFormat:@"\"%@\":\"%@\",",attriName,attriName];
                    }
                }
                    break;
                case NSDateAttributeType:{
                    if (obj) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                        [dateFormatter setLocale:[NSLocale currentLocale]];
                        NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
                        [dateFormatter setTimeZone:timeZone];
                        elementString = [[NSString alloc] initWithFormat:@"\"%@\":\"%@\",",attriName,[dateFormatter stringFromDate:obj]];
                    }
                }
                    break;
                default:
                    break;
            }
            if (![elementString isEmpty]) {
                dataJSONString = [dataJSONString stringByAppendingString:elementString];
            }
        }
    }
    if (![dataJSONString isEmpty]) {
        dataJSONString = [[NSString alloc] initWithFormat:@"{%@}", dataJSONString ];
        dataJSONString=[dataJSONString stringByReplacingOccurrencesOfString:@",}" withString:@"}"];
    }
    return dataJSONString;
}
+ (NSString *)needUploadDataArray2JSONArrayString{
    NSArray *dataArray=[self uploadArrayOfObject];
    NSString *objArrayString=@"[";
    if(dataArray.count>0){
        NSString *objStr = @"";
        for (id obj in dataArray) {
            objStr = [obj dataJSONString];
            objArrayString=[NSString stringWithFormat:@"%@,%@",objArrayString,objStr];
            //[_uploadedRecord addUploadedRecord:currentDataName WitdData:obj];
        }
        objArrayString=[NSString stringWithFormat:@"%@]",objArrayString];
        objArrayString=[objArrayString stringByReplacingOccurrencesOfString:@"[," withString:@"["];
    }else{
        objArrayString=@"[]";
    }
    return objArrayString;
}
- (NSString *)dataXMLString{
    NSString *dataXMLString  = @"";
    NSEntityDescription *entity=[self entity];
    NSDictionary *attributes = [entity attributesByName];
    for (NSString *attriName in [attributes allKeys]) {
        if (![attriName isEqualToString:@"isuploaded"]) {
            NSAttributeDescription *attriDesc = [attributes objectForKey:attriName];
            NSString *elementString           = @"";
            id obj                            = [self valueForKey:attriName];
            switch (attriDesc.attributeType) {
                case NSStringAttributeType:{
                    if (obj == nil) {
                        obj = @"";
                    }
                    if (![attriName isEqualToString:@"maintainplan_id"]) {
                        if ([attriName isEqualToString:@"myid"]) {
                            elementString = [[NSString alloc] initWithFormat:@"<id>%@</id>\n",obj];
                        } else if ([attriName isEqualToString:@"inspection_description"]) {
                            elementString = [[NSString alloc] initWithFormat:@"<description>%@</description>\n",obj];
                        } else if ([attriName isEqualToString:@"map_item"]) {
                            elementString = [[NSString alloc] initWithFormat:@"<%@><![CDATA[%@]]></%@><map_item1></map_item1><map_item2></map_item2><map_item3></map_item3><map_item4></map_item4><map_item5></map_item5><map_item6></map_item6><map_item7></map_item7><map_item8></map_item8><map_item9></map_item9>",attriName,obj,attriName];
                        } else {
                            obj           = [obj stringByReplacingOccurrencesOfString:@"\n" withString:@"\r\n"];
                            obj           = [obj stringByReplacingOccurrencesOfString:@"\r" withString:@"\r\n"];
                            elementString = [[NSString alloc] initWithFormat:@"<%@>%@</%@>\n",attriName,obj,attriName];
                        }
                    }
                }
                    break;
                case NSBooleanAttributeType:
                case NSFloatAttributeType:
                case NSDoubleAttributeType:
                case NSInteger16AttributeType:
                case NSInteger32AttributeType:
                case NSInteger64AttributeType:{
                    if (obj) {
                        elementString = [[NSString alloc] initWithFormat:@"<%@>%@</%@>\n",attriName,[obj stringValue],attriName];
                    } else {
                        elementString = [[NSString alloc] initWithFormat:@"<%@>0</%@>\n",attriName,attriName];
                    }
                }
                    break;
                case NSDateAttributeType:{
                    if (obj) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                        [dateFormatter setLocale:[NSLocale currentLocale]];
                        NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
                        [dateFormatter setTimeZone:timeZone];
                        elementString = [[NSString alloc] initWithFormat:@"<%@>%@</%@>\n",attriName,[dateFormatter stringFromDate:obj],attriName];
                    }
                }
                    break;
                default:
                    break;
            }
            if (![elementString isEmpty]) {
                dataXMLString = [dataXMLString stringByAppendingString:elementString];
            }
        }
    }
    if (![dataXMLString isEmpty]) {
        dataXMLString = [[NSString alloc] initWithFormat:@"<%@>%@</%@>",entity.name,dataXMLString,entity.name];
    }
    return dataXMLString;
}

//对接
+ (NSString *)complexTypeString:(NSString *)dataXMLString{
    NSManagedObjectContext *context=[[AppDelegate App] managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    NSDictionary *attributes = [entity attributesByName];
    NSString *typeString     = @"";
    
    for (NSString *attriName in [attributes allKeys]) {
        if (![attriName isEqualToString:@"isuploaded"] && ![attriName isEqualToString:@"officeAddress"]) {
            NSAttributeDescription *attriDesc = [attributes objectForKey:attriName];
            NSString *elementString;
            switch (attriDesc.attributeType) {
                case NSDateAttributeType:
                    elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"%@\" type=\"xs:dateTime\" minOccurs=\"0\" />\r",attriName];
                    break;
                default:{
                    if ([attriName isEqualToString:@"myid"]) {
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"id\" type=\"xs:string\" minOccurs=\"0\" />\r"];
                    } else if ([attriName isEqualToString:@"inspection_description"]){
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"description\" type=\"xs:string\" minOccurs=\"0\" />\r"];
                    } else if ([attriName isEqualToString:@"map_item"]) {
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"%@\" type=\"xs:string\" minOccurs=\"0\" />\r",attriName];
                        for (int i    = 1; i <= 9; i++) {
                            elementString = [elementString stringByAppendingFormat:@"<xs:element name=\"%@%d\" type=\"xs:string\" minOccurs=\"0\" />\r",attriName,i];
                        }
                    } else {
                        elementString = [[NSString alloc] initWithFormat:@"<xs:element name=\"%@\" type=\"xs:string\" minOccurs=\"0\" />\r",attriName];
                    }
                }
                    break;
            }
            typeString = [typeString stringByAppendingString:elementString];
        }
    }
    
    typeString = [[NSString alloc] initWithFormat:@"<xs:schema id=\"NewDataSet\" xmlns=\"\" xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" xmlns:msdata=\"urn:schemas-microsoft-com:xml-msdata\">\r"
                  "   <xs:element name=\"NewDataSet\" msdata:IsDataSet=\"true\" msdata:Locale=\"zh-CN\">\r"
                  "       <xs:complexType>\r"
                  "           <xs:choice maxOccurs=\"unbounded\">\r"
                  "               <xs:element name=\"%@\">\r"
                  "                   <xs:complexType>\r"
                  "                       <xs:sequence>\r"
                  "                           %@\r"
                  "                       </xs:sequence>\r"
                  "                   </xs:complexType>\r"
                  "               </xs:element>\r"
                  "           </xs:choice>\r"
                  "       </xs:complexType>\r"
                  "%@\r"
                  "   </xs:element>\r"
                  "</xs:schema>\r",NSStringFromClass([self class]),typeString,dataXMLString];
    return typeString;
}

-(NSString *)dataXMLStringForCasePhoto{
    NSString *casePhotoStr = @"<id>%@</id>"
    "<parent_id>%@</parent_id>"
    "<photo_name>%@</photo_name>"
    "<imagetype>JPG</imagetype>"
    "<data>%@</data>"
    "<remark>%@</remark>";
    CasePhoto *photo = (CasePhoto*)self;
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[pathArray objectAtIndex:0];
    NSString *photoPath=[NSString stringWithFormat:@"CasePhoto/%@",photo.proveinfo_id];
    photoPath=[documentPath stringByAppendingPathComponent:photoPath];
    
    UIImage *image        = [UIImage imageWithContentsOfFile:[photoPath stringByAppendingPathComponent:photo.photo_name]];
    image=[UIImage imageWithContentsOfFile:photo.photopath];
    NSData *data          = UIImageJPEGRepresentation(image, 0.5);// UIImageJPGRepresentation(image);
    NSString *stringImage = [NSString base64forData:data];
    casePhotoStr          = [NSString stringWithFormat:casePhotoStr,photo.myid?photo.myid:@"",photo.proveinfo_id?photo.proveinfo_id:photo.project_id,photo.photo_name?photo.photo_name:@"",stringImage?stringImage:@"",photo.remark?photo.remark:@""];
    return casePhotoStr;
}

-(NSString *)dataXMLStringForCasePhotoServiceManage_jpg{
    NSString *casePhotoStr = @"<id>%@</id>"
    "<parent_id>%@</parent_id>"
    "<photo_name>%@</photo_name>"
    "<imagetype>JPG</imagetype>"
    "<data>%@</data>"
    "<remark>%@</remark>";
    CasePhoto *photo = (CasePhoto*)self;

    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[pathArray objectAtIndex:0];
    NSString *photoPath=[NSString stringWithFormat:@"CasePhoto/%@",photo.proveinfo_id];
    photoPath=[documentPath stringByAppendingPathComponent:photoPath];

//    UIImage *image        = [UIImage imageWithContentsOfFile:[photoPath stringByAppendingPathComponent:photo.photo_name]];
//    image=[UIImage imageWithContentsOfFile:photo.photopath];
    UIImage * image = [[UIImage alloc] initWithContentsOfFile:photoPath];
    NSData *data          = UIImageJPEGRepresentation(image, 1);// UIImageJPGRepresentation(image);
    NSString *stringImage = [NSString base64forData:data];
    casePhotoStr          = [NSString stringWithFormat:casePhotoStr,photo.myid?photo.myid:@"",photo.proveinfo_id?photo.proveinfo_id:photo.project_id,photo.photo_name?photo.photo_name:@"",stringImage?stringImage:@"",photo.remark?photo.remark:@""];
    return casePhotoStr;
}

-(NSString*)base64StringForCasePhoto{
    CasePhoto *photo      = (CasePhoto*)self;
    UIImage *image        = [UIImage imageWithContentsOfFile:photo.photopath];
    NSData *data          = UIImageJPEGRepresentation(image, 0.5);// UIImageJPGRepresentation(image);
    NSString *stringImage = [NSString base64forData:data];
    return stringImage;
}
-(NSString*)JSONStringForCasePhoto{
    CasePhoto *photo  = (CasePhoto*)self;
    UIImage *image=[UIImage imageWithContentsOfFile:photo.photopath];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSString*imageString=[NSString base64forData:imageData];
    
}
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"myid" : @"id",
             @"account" : @"code",
             @"username" : @"name",
             @"organization_id" : @"org_id"
             };
}




@end
