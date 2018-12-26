//
//  signatureView.h
//  test
//
//  Created by admin on 2018/8/27.
//  Copyright © 2018年 com.cqj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GetSignatureImageDele <NSObject>

-(void)getSignatureImg:(UIImage*)image;

@end

@interface signatureView : UIView
{
    
    CGFloat min;
    
    CGFloat max;
    
    CGRect origRect;
    
    CGFloat origionX;
    
    CGFloat totalWidth;
    
    BOOL  isSure;
    
}

//签名完成后的水印文字

@property (strong,nonatomic) NSString *showMessage;

@property(nonatomic,assign)id<GetSignatureImageDele> delegate;

- (void)clear;

- (void)sure;
@end
