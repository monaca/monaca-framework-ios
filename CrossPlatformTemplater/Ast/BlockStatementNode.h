//
//  BlockStatementNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"


@interface BlockStatementNode : NSObject <Node> {
 @private
	Token *identifier_;
	StatementsNode *statements_;
}

// Designated initializer.
- (id)initWithToken:(Token *)identifier node:(StatementsNode *)statements;

- (NSString *)getBlockName;

@property(retain) Token *identifier;
@property(retain) StatementsNode *statements;
@end