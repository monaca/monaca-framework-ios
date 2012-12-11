//
//  TrueValue.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/27.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Value.h"


@interface TrueValue : NSObject<Value>

+ (TrueValue *)getInstance;

@end
