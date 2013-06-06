//
//  MFVIewBackground.m
//  MonacaDebugger
//
//  Created by Shikata on 5/23/13.
//  Copyright (c) 2013 ASIAL CORPORATION. All rights reserved.
//

#import "MFVIewBackground.h"
#import "NativeComponentsInternal.h"
#import "MFUtility.h"
#import "MFViewManager.h"
#import "MFUIChecker.h"

#define kWebViewBackground  @"bg"

@implementation MFViewBackground

- (id)initWithViewController:(MFViewController *)viewController
{
    self = [super init];
    
    if (self) {
        _viewController = viewController;
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCContainerPage];
        CGRect frame = CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height);
        self.frame = frame;
    }
    
    return self;
}

#pragma mark - Other methods

- (void)setBackgroundColor:(UIColor *)color
{
    _viewController.webView.backgroundColor = [UIColor clearColor];
    _viewController.webView.opaque = NO;
    
    UIScrollView *scrollView = (UIScrollView *)[_viewController.webView scrollView];
    
    if (scrollView) {
        scrollView.opaque = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        // Remove shadow
        for (UIView *subview in [scrollView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]){
                subview.hidden = YES;
            }
        }
    }
    
    _viewController.view.opaque = YES;
    _viewController.view.backgroundColor = color;
}

-(NSNumber*)castBackgroundSizeValue:(NSString*)stringParameterValue
{
    // 引数は"○○%"で渡されてくるので"%"を除去
    NSRegularExpression* matchResult = [NSRegularExpression regularExpressionWithPattern:@"(%)" options:0 error:nil];
    NSString* castStringParameterValue = [matchResult stringByReplacingMatchesInString:stringParameterValue
                                                                               options:NSMatchingReportProgress
                                                                                 range:NSMakeRange(0, stringParameterValue.length)
                                                                          withTemplate:@""];
    
    float castParameter = 100;
    
    // 不正な値の場合は100（デフォルト値）のままで返す
    if ([castStringParameterValue floatValue] && [castStringParameterValue floatValue] < castParameter && [castStringParameterValue floatValue] >= 0 ) {
        castParameter = [castStringParameterValue floatValue];
    }
    
    return [NSNumber numberWithFloat:castParameter];
}

- (void)setBackgroundImageSize:(id)value
{
    if ([[MFUIChecker valueType:value] isEqualToString:@"Array"]) {
        NSArray *size = (NSArray *)value;
        float width = [[self castBackgroundSizeValue:[size objectAtIndex:0]] floatValue];
        float height = [[self castBackgroundSizeValue:[size objectAtIndex:1]] floatValue];
        CGSize newSize = CGSizeMake(self.frame.size.width * 0.01 * width,
                               self.frame.size.height * 0.01 * height);

        UIGraphicsBeginImageContext(newSize);
        [_originalImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        _resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        _resizedImage = _originalImage;
        if ([value isEqualToString:kNCTypeAuto]) {
            [self setPosition:[self retrieveUIStyle:kNCStyleBackgroundPosition]];
        }
        else if ([value isEqualToString:kNCTypeCover]) {
            self.contentMode = UIViewContentModeScaleToFill;
        }
        else if ([value isEqualToString:kNCTypeContain]) {
            self.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

- (void)setPosition:(NSArray *)style
{
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionCenter] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionCenter]) {
        self.contentMode = UIViewContentModeCenter;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionCenter] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionTop]) {
        self.contentMode = UIViewContentModeTop;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionCenter] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionBottom]) {
        self.contentMode = UIViewContentModeBottom;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionRight] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionCenter]) {
        self.contentMode = UIViewContentModeRight;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionRight] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionTop]) {
        self.contentMode = UIViewContentModeTopRight;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionRight] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionBottom]) {
        self.contentMode = UIViewContentModeBottomRight;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionLeft] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionCenter]) {
        self.contentMode = UIViewContentModeLeft;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionLeft] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionTop]) {
        self.contentMode = UIViewContentModeTopLeft;
    }
    if ([[style objectAtIndex:0] isEqual:kNCBackgroundImagePositionLeft] &&
        [[style objectAtIndex:1] isEqual:kNCBackgroundImagePositionBottom]) {
        self.contentMode = UIViewContentModeBottomLeft;
    }
}

- (void)updateFrame
{
    if (!CGRectEqualToRect(self.frame, _viewController.view.frame)) {
        self.frame = _viewController.view.frame;
        if ([[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeNoRepeat]) {
            [self setBackgroundImageSize:[_ncStyle retrieveStyle:kNCStyleBackgroundSize]];
        }
    }
}

- (void)createBackgroundView:(NSDictionary *)uidict
{
    [self setUserInterface:uidict];
    [self applyUserInterface];
    [_viewController.view insertSubview:self atIndex:0];
}

#pragma mark - UIStyleProtocol

- (void)setUserInterface:(NSDictionary *)uidict
{
    [_ncStyle setStyles:uidict];
}

- (void)applyUserInterface
{
    [self updateUIStyle:[[_ncStyle styles] objectForKey:kNCStyleBackgroundImage] forKey:kNCStyleBackgroundImage];
    for (id key in [_ncStyle styles]) {
        [self updateUIStyle:[[_ncStyle styles] objectForKey:key] forKey:key];
    }
}

- (void)removeUserInterface
{
    self.backgroundColor = UIColor.whiteColor;
    self.image = nil;
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
//    if (![_ncStyle checkStyle:value forKey:key]) {
//        return;
//    }
    
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        if (![[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeRepeat]) {
            [self setBackgroundColor:hexToUIColor(removeSharpPrefix(value), 1)];
        }
    }
    if ([key isEqualToString:kNCStyleBackgroundImage]) {
        NSString *imagePath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:value];
        _originalImage = [UIImage imageWithContentsOfFile:imagePath];
        if (![[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeRepeat]) {
            [self setBackgroundImageSize:[_ncStyle retrieveStyle:kNCStyleBackgroundSize]];
            self.image = _resizedImage;
        }
    }
    if ([key isEqualToString:kNCStyleBackgroundSize]) {
        if (![[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeRepeat]) {
            [self setBackgroundImageSize:value];
            self.image = _resizedImage;
        }
    }
    if ([key isEqualToString:kNCStyleBackgroundRepeat]) {
        if ([value isEqualToString:kNCTypeRepeat]) {
            self.image = nil;
            self.backgroundColor = [UIColor colorWithPatternImage:_originalImage];
        } else {
            [self setBackgroundImageSize:[_ncStyle retrieveStyle:kNCStyleBackgroundSize]];
            self.image = _resizedImage;
            NSString *colorString = [self retrieveUIStyle:kNCStyleBackgroundColor];
            [self setBackgroundColor:hexToUIColor(removeSharpPrefix(colorString), 1)];
        }
    }

    if ([key isEqualToString:kNCStyleBackgroundPosition]) {
        if ([[self retrieveUIStyle:kNCStyleBackgroundSize] isKindOfClass:NSString.class] &&
            [[self retrieveUIStyle:kNCStyleBackgroundSize] isEqualToString:kNCTypeAuto]) {
            [self setPosition:value];
        }
    }
    [_ncStyle updateStyle:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    return [_ncStyle retrieveStyle:key];
}

@end
