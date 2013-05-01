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
    NSString *_previousPath;
    NCManager *_ncManager_;
    NSDictionary *_uiDict;
    BOOL _deallocFlag;
}
- (void)applyUserInterface:(NSDictionary *)uidict;
- (id)initWithFileName:(NSString *)fileName;
- (void)destroy;

@property (nonatomic, copy) NSString *previousPath;
@property (nonatomic) NCManager *ncManager;
@property (nonatomic, retain) NSDictionary *uiDict;

@end
