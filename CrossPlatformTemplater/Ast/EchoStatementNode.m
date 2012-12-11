//
//  EchoStatementNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/02.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "EchoStatementNode.h"
#import "NodeVisitor.h"


@implementation EchoStatementNode
@synthesize expression = expression_;
@synthesize apply = apply_;

- (id)initWithNode:(id<Node>)expression apply:(Token *)apply {
    self = [super init];
    if (self != nil) {
        self.expression = expression;
        self.apply = apply;
    }
    return self;
}

// Override.
- (void)accept:(id<NodeVisitor>)visitor value:(id)val {
    [visitor visitEchoStatementNode:self value:val];
}

-(void)dealloc {
    [(id)expression_ release];
    [apply_ release];
    [super dealloc];
}

@end
