//
//  NCButton.m
//  8Card
//
//  Created by KUBOTA Mitsunori on 12/05/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NCButton.h"
#import "NativeComponentsInternal.h"
#import "MFUtility.h"

@implementation NCButton 

- (id)init {
    self = [super init];
    
    if (self) {
        [self setTitle:@""];
        _ncStyle = [[NSMutableDictionary alloc] init];
        [_ncStyle setValue:@"true" forKey:kNCStyleVisibility];
        [_ncStyle setValue:@"false" forKey:kNCStyleDisable];
        [_ncStyle setValue:@"#000000" forKey:kNCStyleBackgroundColor];
        [_ncStyle setValue:@"#FFFFFF" forKey:kNCStyleTextColor];
        [_ncStyle setValue:@"" forKey:kNCStyleImage];
        [_ncStyle setValue:@"" forKey:kNCStyleInnerImage];
        [_ncStyle setValue:@"" forKey:kNCStyleText];
    }
    
    return self;
}

- (void)applyUserInterface:(NSDictionary *)uidict
{
    for (id key in uidict) {
        [self updateUIStyle:[uidict objectForKey:key] forKey:key];
    }
}

#pragma mark - UIStyleProtocol


- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return;
    }

    if ([key isEqualToString:kNCStyleVisibility]) {
        // TODO: Implement
    }
    if ([key isEqualToString:kNCStyleDisable]) {
        if (isFalse(value)) {
            [self setEnabled:YES];
        } else {
            [self setEnabled:NO];
        }
    }
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        float alpha = [[self retrieveUIStyle:kNCStyleOpacity] floatValue];
        [self setTintColor:hexToUIColor(removeSharpPrefix(value), alpha)];
    }
    if ([key isEqualToString:kNCStyleActiveTextColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [self setTitleTextAttributes:attributes forState:UIControlStateSelected];
    }
    if ([key isEqualToString:kNCStyleTextColor]) {
        UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    if ([key isEqualToString:kNCStyleImage]) {
        // TODO: check
    }
    if ([key isEqualToString:kNCStyleInnerImage]) {
        NSString *imagePath = [[MFUtility currentViewController].wwwFolderName stringByAppendingPathComponent:value];
        UIImage *image = [UIImage imageNamed:imagePath];
        [self setImage:image];
    }
    if ([key isEqualToString:kNCStyleText]) {
        [self setTitle:value];
    }

    [_ncStyle setValue:value forKey:key];
}


- (id)retrieveUIStyle:(NSString *)key
{
    if ([_ncStyle objectForKey:key] == nil) {
        // 例外処理
        return nil;
    }

    return [_ncStyle objectForKey:key];
}

@end
