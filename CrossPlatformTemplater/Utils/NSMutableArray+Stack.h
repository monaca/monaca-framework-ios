//
//  NSMutableArray+Stack.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/03/30.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (Stack)
- (id)pop;
- (void)push:(id)obj;
- (id)peek;
@end