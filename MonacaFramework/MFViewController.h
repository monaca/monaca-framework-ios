//
//  MFViewController.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVViewController.h"
#import "NCManager.h"
#import "NCContainer.h"

@interface MFViewController : CDVViewController <UIScrollViewDelegate, UIWebViewDelegate>
{
@private
    NSString *_previousPath;
    NCManager *_ncManager_;
    NSDictionary *_uiDict;
    NCContainer *_backButton;
}
- (void)applyUserInterface:(NSDictionary *)uidict;
- (id)initWithFileName:(NSString *)fileName;
- (void)destroy;
- (void)showSplash:(BOOL)show;

@property (nonatomic, copy) NSString *previousPath;
@property (nonatomic, retain) NCManager *ncManager;
@property (nonatomic, retain) NSDictionary *uiDict;
@property (nonatomic, retain) NSDictionary *monacaPluginOptions;
@property (nonatomic, retain) NCContainer *backButton;


@end
