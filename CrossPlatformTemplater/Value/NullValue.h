//
//  NullValue.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/05/03.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * The NullValue class.
 */
@interface NullValue : NSObject

// Returns the singleton instance of the NullValue.
+ (NullValue *)getInstance;

@end
