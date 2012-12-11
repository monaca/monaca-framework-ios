//
//  NCLabelBuilder.h
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/15.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeComponentsInternal.h"

@interface NCLabelBuilder : NSObject

+ (UILabel *)label:(NSDictionary *)style;
+ (UIBarButtonItem *)update:(UIBarButtonItem *)label with:(NSDictionary *)style;

@end
