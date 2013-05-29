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
    NSDictionary *_defaultStyle;
    NSMutableDictionary *_style;
    NSString *_component;
}

- (id)initWithComponent:(NSString *)component;
- (void)setStyles:(NSDictionary *)styles;
- (NSDictionary *)getStyles;
- (void)updateStyle:(id)value forKey:(NSString *)key;
- (id)retrieveStyle:(NSString *)key;
- (BOOL)checkStyle:(id)value forKey:(id)key;

@end
