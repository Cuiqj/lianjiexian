//
//  NameimageViewController.h
//  YUNWUMobile
//
//  Created by admin on 2018/8/28.
//

#import <UIKit/UIKit.h>
#import "signatureView.h"

@interface NameimageViewController : UIViewController <GetSignatureImageDele>
{
    UIImage *saveImage;
    UIView *saveView;
}
@property (nonatomic,retain) NSString * imageID;

@property (strong,nonatomic) signatureView * signatureView;




@end
