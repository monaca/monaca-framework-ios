//
//  MFTransitPlugin.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/03/31.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVPlugin.h"

@interface MFTransitPlugin : CDVPlugin

- (void)push:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)pop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)modal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;

@end
