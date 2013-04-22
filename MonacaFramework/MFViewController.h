//
//  MFViewController.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVViewController.h"
#import "NCManager.h"

@interface MFViewController : CDVViewController <UIScrollViewDelegate, UIWebViewDelegate>
{
@private
    NSString *previousPath_;
    UIView *centerView_;
    BOOL existTop_;
    NCManager *ncManager_;
    NSDictionary *uiDict_;
}
- (void)applyUserInterface:(NSDictionary *)uidict;
- (id)initWithFileName:(NSString *)fileName;
- (void)destroy;

@property (nonatomic, copy) NSString *previousPath;
@property (nonatomic) BOOL existTop;
@property (nonatomic) NCManager *ncManager;
@property (nonatomic, retain) NSDictionary *uiDict;

@end
