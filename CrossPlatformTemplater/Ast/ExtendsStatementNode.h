//
//  ExtendsStatementNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"


@interface ExtendsStatementNode : NSObject <Node> {
	Token *path_;
}

- (id)initWithToken:(Token *)path;
- (NSString *)getPath;

@end