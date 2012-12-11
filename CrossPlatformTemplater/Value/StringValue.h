//
//  StringValue.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Value.h"


/*
 * The StringValue class represents a string value in the template engine.
 */
@interface StringValue : NSObject {
 @private
    NSString *str_;
}

// Returns an autoreleased instance of StringValue.
+ (StringValue *)valueWithString:(NSString *)str;

// Designated initializer.
- (id)initWithString:(NSString *)str;

@property(copy) NSString *str;

@end