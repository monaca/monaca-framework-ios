//
//  TopStatementsNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"
#import "StatementsNode.h"


@interface TopStatementsNode : StatementsNode

+ (id)nodeWithNodes:(TopStatementsNode *)left right:(id <Node>)right;
- (id)initWithNodes:(TopStatementsNode *)left right:(id <Node>)right;

@end
