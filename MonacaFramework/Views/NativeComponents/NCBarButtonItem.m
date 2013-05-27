//
//  NCBarButtonItem.m
//  MonacaFramework
//
//  Created by Shikata on 4/25/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "NCBarButtonItem.h"

@implementation NCBarButtonItem

@synthesize hidden = _hidden;

-(id)initWithCustomView:(UIView *)customView{
    
    self.customView = customView;
    _hidden = false;
    
    return self;
}

@end

