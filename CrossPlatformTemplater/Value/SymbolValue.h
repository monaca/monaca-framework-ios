//
//  SymbolValue.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Value.h"


/*
 * The SymbolValue class represents a symbol value in the template engine.
 */
@interface SymbolValue : NSObject<Value> {
 @private
    NSString *name_;
}

// Returns an autoreleased instance of the SymbolValue.
+ (SymbolValue *)valueWithString:(NSString *)name;

+ (id<Value>)get:(NSString *)key;

// Removes all objects from symbol dictionary |dict_|.
+ (void)clear;

// Designated initializer.
- (id)initWithString:(NSString *)name;

@end
