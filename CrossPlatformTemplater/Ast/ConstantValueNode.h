//
//  ConstantValueNode.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/02.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"


@interface ConstantValueNode : NSObject<Node> {
 @private
    Token *id_;
    NSMutableArray *names_;
    ConstantValueNode *left_;
    NSString *name_;
}

+ (ConstantValueNode *)nodeWithToken:(Token *)token;
+ (ConstantValueNode *)nodeWithToken:(Token *)token left:(ConstantValueNode *)left;
- (id)initWithToken:(Token *)id;
- (id)initWithToken:(Token *)id left:(ConstantValueNode *)left;

@property(retain) Token *id;
@property(retain) NSMutableArray *names;
@property(retain) ConstantValueNode *left;
@property(retain) NSString *name;
@end
