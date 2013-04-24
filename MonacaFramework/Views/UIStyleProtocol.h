//
//  UIStyleProtocol.h
//  MonacaFramework
//
//  Created by yasuhiro on 13/04/22.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIStyleProtocol <NSObject>
- (void)updateUIStyle:(id)value forKey:(NSString *)key;
- (id)retrieveUIStyle:(NSString *)key;

@end
