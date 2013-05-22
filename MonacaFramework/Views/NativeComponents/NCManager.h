//
//  NCManager.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/29.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeComponentsInternal.h"
#import "UIStyleProtocol.h"

@interface NCManager : NSObject {
 @private
    NSMutableDictionary *_components;
    NSMutableArray *_noIDComponents;
}

- (void)setComponent:(id)component forID:(NSString *)cid;
- (id<UIStyleProtocol>)componentForID:(NSString *)cid;

@end
