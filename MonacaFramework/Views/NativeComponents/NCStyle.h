//
//  NCStyle.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/05/30.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCStyle : NSObject
{
    NSDictionary *_defaultStyles;
    NSMutableDictionary *_styles;
    NSString *_component;
}

- (id)initWithComponent:(NSString *)component;
- (id)getDefaultStyle:(NSString *)key;
- (void)resetStyles;
- (void)setStyles:(NSDictionary *)styles;
- (NSDictionary *)styles;
- (void)updateStyle:(id)value forKey:(NSString *)key;
- (id)retrieveStyle:(NSString *)key;
- (BOOL)checkStyle:(id)value forKey:(id)key;

@end
