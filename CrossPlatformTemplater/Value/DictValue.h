//
//  DictValue.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Value.h"


/*
 * The DictValue class represents a symbol table in the template engine.
 */
@interface DictValue : NSObject<Value> {
 @private
    NSMutableDictionary *dict_;
}

+ (DictValue *)value;

- (void)set:(id)value forKey:(NSString *)key;
- (BOOL)exists:(NSString *)key;
- (id)get:(NSString *)key;

@property(nonatomic, retain) NSMutableDictionary *dict;

@end