//
//  NCButton.m
//  8Card
//
//  Created by KUBOTA Mitsunori on 12/05/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NCButton.h"

@implementation NCButton 

@synthesize imageButtonView;
@synthesize position = _position;

- (id)init {
    self = [super init];
    
    if (self) {
        self.imageButtonView = [[UIButton alloc] init];
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action postion:(NSString *)aPosition {
    self = [super initWithTitle:title style:style target:target action:action];
    if(self){
        _position = aPosition;
    }
    return self;
}

@end
