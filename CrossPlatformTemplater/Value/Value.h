//
//  Value.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/27.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Value

// Checks equality.
- (BOOL)isEqual:(id<Value>)value;

@end

#import "DictValue.h"
#import "SymbolValue.h"
#import "StringValue.h"
#import "TrueValue.h"
#import "FalseValue.h"