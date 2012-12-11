//
//  IfStatementNode.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/02.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "IfStatementNode.h"
#import "NodeVisitor.h"


@implementation IfStatementNode
@synthesize expression = expression_, elseStatement = elseStatement_, statements = statements_;

+ (IfStatementNode *)nodeWithNodes:(id<Node>)expression statements:(StatementsNode *)statements elseStatement:(id<Node>)elseStatement {
    return [[[IfStatementNode alloc] initWithNodes:expression statements:statements elseStatement:elseStatement] autorelease];
}

- (id)initWithNodes:(id<Node>)expression statements:(StatementsNode *)statements elseStatement:(id<Node>)elseStatement; {
    self = [super init];
    if (self != nil) {
        expression_ = [(id)expression retain];
        statements_ = [statements retain];
        elseStatement_ = [(id)elseStatement retain];
    }
    return self;
}

- (void)dealloc {
    [(id)expression_ release];
    [statements_ release];
    [(id)elseStatement_ release];
    [super dealloc];
}

// Override.
- (void)accept:(id<NodeVisitor>)visitor value:(id)val {
    [visitor visitIfStatementNode:self value:val];
}

@end
