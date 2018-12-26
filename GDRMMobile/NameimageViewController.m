//
//  NameimageViewController.m
//  YUNWUMobile
//
//  Created by admin on 2018/8/28.
//

#import "NameimageViewController.h"
#import "CasePhoto.h"

@interface NameimageViewController ()

@property (nonatomic,retain) CasePhoto *photo;

@end

@implementation NameimageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.signatureView = [[signatureView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height/2)];
    self.signatureView.backgroundColor = [UIColor whiteColor];
    self.signatureView.delegate =self;
    self.signatureView.showMessage =@"完成";
    [self.view addSubview:self.signatureView];
    
    self.signatureView.layer.borderWidth = 1;
    self.signatureView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"重签"forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor colorWithHue:72 saturation:106 brightness:123 alpha:0.7] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(self.view.frame.size.width/10*7,self.view.frame.size.height/2*1.35,130, 40)];
    button.layer.cornerRadius =5.0;
    button.clipsToBounds =YES;
    button.layer.borderWidth =1.0;
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.layer.borderColor = [[UIColor blackColor]CGColor];
    [button addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setTitle:@"确认"forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont systemFontOfSize:17];
//    button2.backgroundColor = [UIColor blueColor];
    [button2 setFrame:CGRectMake(self.view.frame.size.width/10*7,self.view.frame.size.height/2*1.15,130, 40)];
    button2.layer.cornerRadius =5.0;
    button2.clipsToBounds =YES;
    button2.layer.borderWidth =1.0;
    button2.layer.borderColor = [[UIColor blackColor]CGColor];
    [button2 addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button3 setTitle:@"保存"forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button3.titleLabel.font = [UIFont systemFontOfSize:17];
//    button3.backgroundColor = [UIColor blueColor];
    [button3 setFrame:CGRectMake(self.view.frame.size.width/10*7,self.view.frame.size.height/2*1.55,130, 40)];
    button3.layer.cornerRadius =5.0;
    button3.clipsToBounds =YES;
    button3.layer.borderWidth =1.0;
    button3.layer.borderColor = [[UIColor blackColor]CGColor];
    [button3 addTarget:self action:@selector(btnSave:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    saveView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2,600, 300)];
    saveView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:saveView];
    saveView.layer.borderWidth = 1;
    saveView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(saveView.frame.size.width/2-55, saveView.frame.size.height/2-25, 110, 50)];
    label.text = @"显示图片";
    label.textColor  = [UIColor colorWithRed:108/255 green:108/255 blue:108/255 alpha:0.3];
    [label setFont:[UIFont systemFontOfSize:25]];
    [saveView addSubview:label];
    
}
- (void)btnSave:(UIButton *)button{
    UIImageView * imagesave = [saveView viewWithTag:666];
    if (imagesave) {
//        imagesave.image;
        self.photo = [CasePhoto casePhotoById:self.imageID];
        if (!self.photo) {
            self.photo = [CasePhoto newDataObjectWithEntityName:@"CasePhoto"];
        }
        self.photo.myid = [NSString stringWithFormat:@"%@",self.imageID];
        self.photo.proveinfo_id = self.imageID;
        self.photo.project_id = @"11";
        self.photo.photo_name = @"ServiceManage.jpg";
        [self saveimage:imagesave];
        [[AppDelegate App] saveContext];
    }
}
- (void)add:(UIButton *)sender{
    @try {
        [self.signatureView sure];
        //执行的代码，如果异常,就会抛出，程序不继续执行啦
    } @catch (NSException *exception) {
        //                                捕获异常
        NSLog(@"error");
    } @finally {
        //这里一定执行，无论你异常与否
    }
}
- (void)clear:(UIButton *)sender{
    NSLog(@"重签");
    [self.signatureView clear];
    for(UIView *view in saveView.subviews){
        [view removeFromSuperview];
    }
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(saveView.frame.size.width/2-55, saveView.frame.size.height/2-25, 110, 50)];
    label.text = @"显示图片";
    label.textColor  = [UIColor colorWithRed:108/255 green:108/255 blue:108/255 alpha:0.3];
    [label setFont:[UIFont systemFontOfSize:25]];
    [saveView addSubview:label];
}
-(void)getSignatureImg:(UIImage*)image{
    for(UIView *view in saveView.subviews){
        [view removeFromSuperview];
    }
    if(image){
        NSLog(@"haveImage");
        UIImageView *image1 = [[UIImageView alloc] initWithImage:image];
        image1.frame =CGRectMake(saveView.frame.size.width/2 -image.size.width/2,saveView.frame.size.height/2 -image.size.height/2 ,image.size.width,image.size.height) ;
        //        [self.view addSubview:image1];
        [saveView addSubview:image1];
        image1.tag = 666;
        saveImage = image;
//        [self saveImage:saveImage];
        //        [self makeUpLoad];
        //        UIImageView *image2 = [[UIImageView alloc] initWithImage:image];
        //        image2.frame =CGRectMake(600,200,600,300);
        //        [self.view addSubview:image2];
    }
    else{
        NSLog(@"NoImage");
    }
}
- (void)saveimage:(UIImageView *)imageview{
    UIGraphicsBeginImageContext(imageview.frame.size);
    CGRect contextRect = imageview.frame;
    [imageview.image drawInRect:contextRect];
    [imageview.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * Image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImageJPEGRepresentation(Image,1);
    NSArray *pathArray=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath=[pathArray objectAtIndex:0];
    NSString *Path=[NSString stringWithFormat:@"CasePhoto/%@",self.imageID];
    Path=[documentPath stringByAppendingPathComponent:Path];
    if (![[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:Path withIntermediateDirectories:YES attributes:nil error:nil];
    }
//    NSString *Name = @"ServiceManage.jpg";
//    NSString *filePath=[Path stringByAppendingPathComponent:Name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        [[NSFileManager defaultManager] removeItemAtPath:Path error:nil];
    }
    self.photo.photopath = Path;
    [data writeToFile:Path atomically:YES];
}




//图片保存到本地
//- (void)saveImage:(UIImage *)image{
//    //设置图片名
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMdd"];
//    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
//    NSString *dateStr = [NSString stringWithFormat:@"%@.png",currentDateStr];
//    NSString *path = [NSTemporaryDirectory()stringByAppendingFormat:@"%@",dateStr];
//    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil];
//    if ( existed  ){
//        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
//    }
//    NSData *imgData = UIImageJPEGRepresentation(image, 1);
//    [imgData writeToFile:path atomically:YES];
//}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
