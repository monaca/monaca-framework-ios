//
//  NCButtonBuilder.h
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/10.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NCContainer.h"
#import "NativeComponentsInternal.h"


@interface NCButtonBuilder : NSObject

+ (void)setUpdatedTag:(UIView *)view;
+ (UIBarButtonItem *)button:(NSDictionary *)dict position:(NSString *)aPosition;
+ (UIBarButtonItem *)update:(UIBarButtonItem *)button with:(NSDictionary *)style;

@end
