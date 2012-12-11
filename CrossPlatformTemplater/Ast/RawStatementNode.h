//
//  RawStatementNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@class Token;


@interface RawStatementNode : NSObject <Node> {
 @private
	Token *raw_;
}

+ (RawStatementNode *)nodeWithToken:(Token *)token;
- (id)initWithToken:(Token *)token;
- (NSString *)getRawString;

@end