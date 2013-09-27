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

@synthesize type = _type;

- (id)initWithViewController:(MFViewController *)viewController
{
    self = [super init];
    
    if (self) {
        _viewController = viewController;
        _type = kNCContainerPage;
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

-(float)castBackgroundSizeValue:(NSString*)stringParameterValue
{
    // 引数は"○○%"で渡されてくるので"%"を除去
    NSRegularExpression* matchResult = [NSRegularExpression regularExpressionWithPattern:@"[^0-9]" options:0 error:nil];
    NSString* castStringParameterValue = [matchResult stringByReplacingMatchesInString:stringParameterValue
                                                                               options:NSMatchingReportProgress
                                                                                 range:NSMakeRange(0, stringParameterValue.length)
                                                                          withTemplate:@""];
    
    float castParameter = 100;
    
    // 不正な値の場合は100（デフォルト値）のままで返す
    if ([castStringParameterValue floatValue] && [castStringParameterValue floatValue] >= 0 ) {
        castParameter = [castStringParameterValue floatValue];
    }

    return castParameter;
}

-(CGSize)getBackgroundSize:(NSArray *)value
{
    float width, height;
    if ([[value objectAtIndex:0] rangeOfString:@"%"].location != NSNotFound) {
        width = self.frame.size.width * 0.01 * [self castBackgroundSizeValue:[value objectAtIndex:0]];
    } else {
        width = [self castBackgroundSizeValue:[value objectAtIndex:0]];
    }
    
    if ([[value objectAtIndex:1] rangeOfString:@"%"].location != NSNotFound) {
        height = self.frame.size.height * 0.01 * [self castBackgroundSizeValue:[value objectAtIndex:1]];
    } else {
        height = [self castBackgroundSizeValue:[value objectAtIndex:1]];
    }

    return CGSizeMake(roundf(width),roundf(height));
}

- (void)setBackgroundImageSize:(id)value
{
    if ([[MFUIChecker valueType:value] isEqualToString:@"Array"]) {
        NSArray *array = (NSArray *)value;
        CGSize size = [self getBackgroundSize:array];
        UIGraphicsBeginImageContext(size);
        [_originalImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        _resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self setPosition:[self retrieveUIStyle:kNCStyleBackgroundPosition]];
    } else {

        if ([value isEqualToString:kNCTypeAuto]) {
            [self setPosition:[self retrieveUIStyle:kNCStyleBackgroundPosition]];
            _resizedImage = _originalImage;
        }
        else if ([value isEqualToString:kNCTypeCover]) {
            if ([[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeNoRepeat]) {
                _resizedImage = _originalImage;
            }
            self.contentMode = UIViewContentModeScaleToFill;
        }
        else if ([value isEqualToString:kNCTypeContain]) {
            if ([[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeNoRepeat]) {
                _resizedImage = _originalImage;
            }
            self.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

- (void)setPosition:(NSArray *)style
{
    if (![[MFUIChecker valueType:style] isEqualToString:@"Array"]) return;
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
        [self setBackgroundImageSize:[_ncStyle retrieveStyle:kNCStyleBackgroundSize]];
        if (_originalImage != nil) {
            if ([[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeNoRepeat]) {
                self.image = _resizedImage;
            } else {
                self.backgroundColor = [UIColor colorWithPatternImage:_resizedImage];
            }
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
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }
    
    if ([NSStringFromClass([[_ncStyle.styles valueForKey:key] class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
    }
    
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        if (![[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeRepeat] || _originalImage == nil) {
            [self setBackgroundColor:hexToUIColor(removeSharpPrefix(value), 1)];
        }
    } else  if ([key isEqualToString:kNCStyleBackgroundImage]) {
        NSString *imagePath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:value];
        _originalImage = [UIImage imageWithContentsOfFile:imagePath];
        [self setBackgroundImageSize:[_ncStyle retrieveStyle:kNCStyleBackgroundSize]];
        if (_originalImage != nil) {
            if (![[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeRepeat]) {
                self.image = _resizedImage;
            } else {
                self.backgroundColor = [UIColor colorWithPatternImage:_resizedImage];
            }
        }
    } else if ([key isEqualToString:kNCStyleBackgroundSize]) {
        [self setBackgroundImageSize:value];
        if (_originalImage != nil) {
            if ([[self retrieveUIStyle:kNCStyleBackgroundRepeat] isEqualToString:kNCTypeRepeat]) {
                self.backgroundColor = [UIColor colorWithPatternImage:_resizedImage];
            } else {
                self.image = _resizedImage;
            }
        }
    } else if ([key isEqualToString:kNCStyleBackgroundRepeat]) {
        if (_originalImage != nil) {
            [self setBackgroundImageSize:[_ncStyle retrieveStyle:kNCStyleBackgroundSize]];
            if ([value isEqualToString:kNCTypeRepeat]) {
                self.image = nil;
                self.backgroundColor = [UIColor colorWithPatternImage:_resizedImage];
            } else {
                self.image = _resizedImage;
                NSString *colorString = [self retrieveUIStyle:kNCStyleBackgroundColor];
                [self setBackgroundColor:hexToUIColor(removeSharpPrefix(colorString), 1)];
            }
        }
    } else if ([key isEqualToString:kNCStyleBackgroundPosition]) {
        if ([[self retrieveUIStyle:kNCStyleBackgroundSize] isKindOfClass:NSArray.class] ||
            ([[self retrieveUIStyle:kNCStyleBackgroundSize] isKindOfClass:NSString.class] &&
            [[self retrieveUIStyle:kNCStyleBackgroundSize] isEqualToString:kNCTypeAuto])) {
            [self setPosition:value];
        }
    }
    
    if ([key isEqualToString:kNCStyleScreenOrientation]) {
        _viewController.screenOrientations = parseScreenOrientationsMask(value);
    }

    [_ncStyle updateStyle:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    return [_ncStyle retrieveStyle:key];
}

@end
