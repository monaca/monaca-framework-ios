//
//  MonacaTransitPlugin.h
//  MonacaFramework
//
//  Created by air on 12/06/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVPlugin.h"

#define kMonacaTransitPluginJsReactivate @"window.onReactivate"
#define kMonacaTransitPluginOptionUrl @"url"
#define kMonacaTransitPluginOptionBg  @"bg"

@interface MFTransitPlugin : CDVPlugin

- (void)push:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)pop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)modal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)dismiss:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)home:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)browse:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)link:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)clearPageStack:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (BOOL)isValidString:(NSString*)urlString;
- (BOOL)isValidOptions:(NSDictionary*)options;
@end
