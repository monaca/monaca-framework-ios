//
//  MFViewController.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/02/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVViewController.h"

@interface MFViewController : CDVViewController <UIScrollViewDelegate, UIWebViewDelegate>
{
@private
    NSString *previousPath_;
}
+ (void)setWantsFullScreenLayout:(BOOL)layout;

- (void)applyUserInterface:(NSDictionary *)uidict;
- (id)initWithFileName:(NSString *)fileName;
- (void)destroy;

@property (nonatomic, copy) NSString *previousPath;

@end
