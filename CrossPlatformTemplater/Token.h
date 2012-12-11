//
//  Token.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/24.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//
    
#import <Foundation/Foundation.h>

@interface Token : NSObject {
 @private
	int symbol_;
    int line_;
	id value_;
}

+ (id)tokenWithSymbol:(int)symbol lineNumber:(int)line value:(id)value;
- (id)initWithSymbol:(int)symbol lineNumber:(int)line value:(id)value;

@property int symbol;
@property int line;
@property(retain) id value;

@end
