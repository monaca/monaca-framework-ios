//
//  StringValueNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"
#import "Value.h"


//
// StringValueNode class.
//
@interface StringValueNode : NSObject<Node> {
 @private
    Token *token_;
    id<Value> value_;
}

// Returns an autoreleased instance of StringValueNode.
+ (StringValueNode *)nodeWithToken:(Token *)token;

// Designated initializer.
- (id)initWithToken:(Token *)token;

@property(retain) Token *token;
@property(retain) id<Value> value;

@end
