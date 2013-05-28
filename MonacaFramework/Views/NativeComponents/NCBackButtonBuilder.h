//
//  NCBackButtonBuilder.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/01/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeComponentsInternal.h"
#import "NCButton.h"

@interface NCBackButtonBuilder : NSObject

+ (UIButton *)backButton:(NSDictionary *)style;
+ (NCButton *)update:(NCButton *)button with:(NSDictionary *)style;

@end
