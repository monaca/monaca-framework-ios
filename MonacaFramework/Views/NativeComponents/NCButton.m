//
//  NCButton.m
//  8Card
//
//  Created by KUBOTA Mitsunori on 12/05/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NCButton.h"
#import "NativeComponentsInternal.h"

@implementation NCButton 

@synthesize imageButtonView;
@synthesize position = _position;

- (id)init {
    self = [super init];
    
    if (self) {
        self.imageButtonView = [[UIButton alloc] init];
        ncStyle = [[NSMutableDictionary alloc] init];
        [ncStyle setValue:@"true" forKey:kNCStyleVisibility];
        [ncStyle setValue:@"false" forKey:kNCStyleDisable];
        [ncStyle setValue:@"#000000" forKey:kNCStyleBackgroundColor];
        [ncStyle setValue:@"#FFFFFF" forKey:kNCStyleTextColor];
        [ncStyle setValue:@"" forKey:kNCStyleImage];
        [ncStyle setValue:@"" forKey:kNCStyleInnerImage];
        [ncStyle setValue:@"" forKey:kNCStyleText];
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

#pragma mark - UIStyleProtocol

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([ncStyle objectForKey:key] == nil) {
        // 例外処理
        return;
    }

    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        [self setTintColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleText]) {
        [self setTitle:value];
    }

    [ncStyle setValue:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    if ([ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }

    return [ncStyle objectForKey:key];
}

@end
