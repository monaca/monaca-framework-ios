//
//  EchoStatementNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/02.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"


@interface EchoStatementNode : NSObject<Node> {
 @private
    id<Node> expression_;
    Token *apply_;
}

// Designated initializer.
- (id)initWithNode:(id<Node>)expression apply:(Token *)apply;

@property(retain) id<Node> expression;
@property(retain) Token *apply;
@end
