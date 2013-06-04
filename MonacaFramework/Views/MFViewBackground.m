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

#define kWebViewBackground  @"bg"

@implementation MFViewBackground

- (id)initWithViewController:(MFViewController *)viewController
{
    self = [super init];
    
    if (self) {
        _viewController = viewController;
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCContainerPage];
        self.frame = viewController.view.frame;
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

#pragma mark - UIStyleProtocol

- (void)createBackgroundView:(NSDictionary *)uidict
{
    [_viewController.view insertSubview:self atIndex:0];
    [self setUserInterface:uidict];
    [self applyUserInterface];
}

- (void)setUserInterface:(NSDictionary *)uidict
{
    [_ncStyle setStyles:uidict];
}

- (void)applyUserInterface
{
    for (id key in [_ncStyle styles]) {
        [self updateUIStyle:[[_ncStyle styles] objectForKey:key] forKey:key];
    }
}

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }
    
    if ([key isEqualToString:kNCStyleBackgroundColor]) {
        if (value != nil) {
            UIColor *color = hexToUIColor(removeSharpPrefix(value), 1);
            [self setBackgroundColor:color];
        } else {
            [self setBackgroundColor:UIColor.whiteColor];
        }
    }
    if ([key isEqualToString:kNCStyleBackgroundImage]) {
        NSString *imagePath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:value];
        self.image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if ([key isEqualToString:kNCStyleBackgroundSize]) {
        
    }
    if ([key isEqualToString:kNCStyleBackgroundRepeat]) {
        
    }
    if ([key isEqualToString:kNCStyleBackgroundPosition]) {
        
    }
    
    [_ncStyle updateStyle:value forKey:key];
}

- (id)retrieveUIStyle:(NSString *)key
{
    return [_ncStyle retrieveStyle:key];
}
/*
- (void)detectPosition:(NSArray *)style
{
    if ([[style objectAtIndex:0] isEqual:kNCTypeCenter] && [[style objectAtIndex:0] isEqual:kNCTypeCenter]) {
        self.contentMode = UIViewContentModeCenter;
    }
    else if ([[style objectAtIndex:0] isEqual:kNCTypeCenter] && [[style objectAtIndex:0] isEqual:kNCPositionTop]) {
            self.contentMode = UIViewContentModeTop;
    else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeCenter] &&
                [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionBottom])
        {
            self.contentMode = UIViewContentModeBottom;
        }
        else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeRight] &&
                [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCTypeCenter])
        {
            self.contentMode = UIViewContentModeRight;
        }
        else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeRight] &&
                [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionTop])
        {
            self.contentMode = UIViewContentModeTopRight;
        }
        else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeRight ] &&
                [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionBottom])
        {
            self.contentMode = UIViewContentModeBottomRight;
        }
        else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeLeft ] &&
                [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCTypeCenter])
        {
            self.contentMode = UIViewContentModeLeft;
        }
        else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeLeft ] &&
                [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionTop])
        {
            self.contentMode = UIViewContentModeTopLeft;
        }
        else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeLeft ] &&
                [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionBottom])
        {
            self.contentMode = UIViewContentModeBottomLeft;
        }
    }
}
*/

-(void)setBackgroundStyle:(NSMutableDictionary*)style
{
    
    NSMutableDictionary* backgroundStyle = [self setBackgroundParameter:style];
    
    // set background color
    if( !(backgroundStyle) || [[backgroundStyle objectForKey:kNCStyleBackgroundColor] isEqual:[NSNull null]])
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.backgroundColor = [backgroundStyle objectForKey:kNCStyleBackgroundColor];
        
    }
    
    // set background image
    if (![[backgroundStyle objectForKey:kNCStyleBackgroundImageFilePath]isEqual:[NSNull null]])
    {
        UIImage* backgroundImage = [UIImage imageWithContentsOfFile:[backgroundStyle objectForKey:kNCStyleBackgroundImageFilePath]];
        UIImage* setImage = backgroundImage;
        
        // Image size set
        id sizeString = [backgroundStyle objectForKey:kNCStyleBackgroundSize];
        
        if ([sizeString isKindOfClass:NSArray.class])
        {
            CGSize sz = CGSizeMake( backgroundImage.size.width * 0.01 * [[backgroundStyle objectForKey:kNCStyleBackgroundSizeWidth] floatValue],
                                   backgroundImage.size.height * 0.01 * [[backgroundStyle objectForKey:kNCStyleBackgroundSizeHeight] floatValue] );
            
            UIGraphicsBeginImageContext(sz);
            [backgroundImage drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
            setImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        // set image repeat
        if ([[backgroundStyle objectForKey:kNCStyleBackgroundRepeat] isEqual:kNCTypeRepeat] )
        {
            self.backgroundColor = [UIColor colorWithPatternImage:setImage];
        }
        else
        {
            if ([sizeString isKindOfClass:NSArray.class] || ([sizeString isKindOfClass:NSString.class] && [sizeString isEqual:kNCTypeAuto])) {
                
                if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeCenter] &&
                   [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCTypeCenter])
                {
                    self.contentMode = UIViewContentModeCenter;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeCenter] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionTop])
                {
                    self.contentMode = UIViewContentModeTop;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeCenter] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionBottom])
                {
                    self.contentMode = UIViewContentModeBottom;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeRight] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCTypeCenter])
                {
                    self.contentMode = UIViewContentModeRight;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeRight] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionTop])
                {
                    self.contentMode = UIViewContentModeTopRight;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeRight ] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionBottom])
                {
                    self.contentMode = UIViewContentModeBottomRight;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeLeft ] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCTypeCenter])
                {
                    self.contentMode = UIViewContentModeLeft;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeLeft ] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionTop])
                {
                    self.contentMode = UIViewContentModeTopLeft;
                }
                else if([[backgroundStyle objectForKey:kNCStyleBackgroundPositionHorizontal] isEqual:kNCTypeLeft ] &&
                        [[backgroundStyle objectForKey:kNCStyleBackgroundPositionVertical] isEqual:kNCPositionBottom])
                {
                    self.contentMode = UIViewContentModeBottomLeft;
                }
            }
            else if([sizeString isKindOfClass:NSString.class] && [sizeString isEqual:kNCTypeCover])
            {
                self.contentMode = UIViewContentModeScaleToFill;
            }
            else if([sizeString isKindOfClass:NSString.class] && [sizeString isEqual:kNCTypeContain])
            {
                self.contentMode = UIViewContentModeScaleAspectFit;
            }
            
            self.image = setImage;
        }
    }
    

}

-(NSMutableDictionary*)setBackgroundParameter:(NSMutableDictionary*)style
{
    // set background color
    id colorString = [style objectForKey:kNCStyleBackgroundColor];
    if ([colorString isKindOfClass:NSString.class])
    {
        // 変な文字列が入ってた場合の対策
        @try {
            [style setObject:hexToUIColor(removeSharpPrefix(colorString), 1) forKey:kNCStyleBackgroundColor];
        }
        @catch (NSException *exception) {
            [style setObject:[NSNull null] forKey:kNCStyleBackgroundColor];
        }
    }
    else if (!([colorString isKindOfClass:UIColor.class]))
    {
        [style setObject:[NSNull null] forKey:kNCStyleBackgroundColor];
    }
    
    // set background image(file path)
    id imageString = [style objectForKey:kNCStyleBackgroundImage];
    NSString *imagePath;
    if ([imageString isKindOfClass:NSString.class])
    {
        NSString *imageFilePath = imageString;
        NSString *currentDirectory = [[MFViewManager currentViewController].previousPath stringByDeletingLastPathComponent];
        imagePath = [currentDirectory stringByAppendingPathComponent:imageFilePath];
        
        // get ImageFilePath for Retina Display
        if([UIScreen mainScreen].scale > 1.0)
        {
            NSRegularExpression* matchResult = [NSRegularExpression regularExpressionWithPattern:@"(\\.)" options:0 error:nil];
            NSString* retinaImageFileName = [matchResult
                                             stringByReplacingMatchesInString:imageFilePath options:NSMatchingReportProgress range:NSMakeRange(0, imageFilePath.length) withTemplate:@"@2x."];
            
            NSString *retinaImageFilePath = [currentDirectory stringByAppendingPathComponent:retinaImageFileName];
            
            // file exist check for Retina
            if([[NSFileManager defaultManager] fileExistsAtPath:retinaImageFilePath])
            {
                imagePath = retinaImageFilePath;
            }
        }
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        [style setObject:imagePath forKey:kNCStyleBackgroundImageFilePath];
    }
    else
    {
        [style setObject:[NSNull null] forKey:kNCStyleBackgroundImageFilePath];
    }
    
    // set background size
    
    [style setObject:[NSNumber numberWithFloat:100] forKey:kNCStyleBackgroundSizeWidth];
    [style setObject:[NSNumber numberWithFloat:100] forKey:kNCStyleBackgroundSizeHeight];
    
    id sizeString = [style objectForKey:kNCStyleBackgroundSize];
    
    if([sizeString isKindOfClass:NSString.class])
    {
        if (!( [sizeString isEqual:kNCTypeAuto]) && !( [sizeString isEqual:kNCTypeCover]) && !( [sizeString isEqual:kNCTypeContain]))
        {
            [style setObject:kNCTypeAuto forKey:kNCStyleBackgroundSize];
        }
    }
    else if ([sizeString isKindOfClass:NSArray.class])
    {
        //[style setObject:nil forKey:kNCStyleBackgroundSize];
        
        NSArray* backgroundSize = sizeString;
        if([backgroundSize count] == 2 && [backgroundSize objectAtIndex:0] && [backgroundSize objectAtIndex:1] )
        {
            [style setObject:[self castBackgroundSizeValue:[backgroundSize objectAtIndex:0]] forKey:kNCStyleBackgroundSizeWidth];
            [style setObject:[self castBackgroundSizeValue:[backgroundSize objectAtIndex:1]] forKey:kNCStyleBackgroundSizeHeight];
        }
    }
    
    // set background repeat
    id repeatString = [style objectForKey:kNCStyleBackgroundRepeat];
    if([repeatString isKindOfClass:NSString.class] && [repeatString isEqual:kNCTypeRepeat])
    {
        [style setObject:kNCTypeRepeat forKey:kNCStyleBackgroundRepeat];
    }
    else
    {
        [style setObject:kNCTypeNoRepeat forKey:kNCStyleBackgroundRepeat];
    }
    
    // set background position
    [style setObject:kNCTypeCenter forKey:kNCStyleBackgroundPositionHorizontal];
    [style setObject:kNCTypeCenter forKey:kNCStyleBackgroundPositionVertical];
    id positionString = [style objectForKey:kNCStyleBackgroundPosition];
    if ([positionString isKindOfClass:NSArray.class])
    {
        NSArray* backgroundPosition = positionString;
        if([backgroundPosition count] == 2 && [backgroundPosition objectAtIndex:0] && [backgroundPosition objectAtIndex:1] )
        {
            // 水平方向のalign
            if ([[backgroundPosition objectAtIndex:0] isEqual:kNCTypeLeft ]
                || [[backgroundPosition objectAtIndex:0] isEqual:kNCTypeRight] )
            {
                [style setObject:[backgroundPosition objectAtIndex:0] forKey:kNCStyleBackgroundPositionHorizontal];
            }
            
            // 垂直方向のalign
            if ([[backgroundPosition objectAtIndex:1] isEqual:kNCPositionTop]
                || [[backgroundPosition objectAtIndex:1] isEqual:kNCPositionBottom] )
            {
                [style setObject:[backgroundPosition objectAtIndex:1] forKey:kNCStyleBackgroundPositionVertical];
            }
        }
        
    }
    return  style;
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


@end
