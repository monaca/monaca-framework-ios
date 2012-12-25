//
//  NCButtonBuilder.m
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/10.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import "NCButtonBuilder.h"
#import "MFUtility.h"
#import "NCButton.h"

@implementation NCButtonBuilder

static const int kUpdatedTag = 9999;

static UIBarButtonItem *
setTextColor(UIBarButtonItem *button, UIColor *color) {
    if (iOSVersionMajor() >= 5) {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:color, UITextAttributeTextColor, nil];
        [button setTitleTextAttributes:attributes forState:UIControlStateNormal];
    }
    return button;
}

static UIBarButtonItem *
updateVisibility(UIBarButtonItem *button, NSDictionary *style) {
    NSString *cid = [style objectForKey:kNCTypeID];
    UIView *view = [[MFUtility currentTabBarController].viewDict objectForKey:cid];
    [view setHidden:isFalse([style objectForKey:kNCStyleVisibility])];
    return button;
}

#define UIColorFromRGB(rgbValue) [UIColor \
    colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
    green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
    blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

static UIBarButtonItem *
updateButton(UIBarButtonItem *button, NSDictionary *style) {
    NSString *text = [style objectForKey:kNCStyleText];
    NSString *innerImagePath = [style objectForKey:kNCStyleInnerImage];

    if (innerImagePath) {
        NSURL *appWWWURL = [((MFDelegate *)[[UIApplication sharedApplication] delegate]) getBaseURL];
        NSString *imagePath = [[appWWWURL path] stringByAppendingPathComponent:innerImagePath];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            [button setImage:image];
        }
    } else if (text) {
        [button setTitle:text];
    }
    

    BOOL disable = isTrue([style objectForKey:kNCStyleDisable]);
    [button setEnabled:!disable];
    
    // Opacity (not support).

    NSString *bgColor = [style objectForKey:kNCStyleBackgroundColor];
    if (bgColor) {
        if ([button respondsToSelector:@selector(setTintColor:)]) {
            UIColor *color = hexToUIColor(removeSharpPrefix(bgColor), 1);
            [button setTintColor:color];
        }
    }
    
    
    // Active color.
    
    NSString *textColor = [style objectForKey:kNCStyleTextColor];
    if (textColor) {
        setTextColor(button, hexToUIColor(removeSharpPrefix(textColor), 1));
    }
    
    // Shape.
    
    NSString *imageName = [style objectForKey:kNCStyleImage];
    if (imageName) {
        NSURL *appWWWURL = [((MFDelegate *)[[UIApplication sharedApplication] delegate]) getBaseURL];
        NSString *imagePath = [[appWWWURL path] stringByAppendingPathComponent:imageName];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        
        UIButton *imageButtonView = (UIButton*)((NCButton*)button).imageButtonView;
        imageButtonView.frame = CGRectMake(imageButtonView.frame.origin.x, imageButtonView.frame.origin.y, image.size.width, image.size.height);

        imageButtonView.enabled = !disable;
        [imageButtonView setBackgroundImage:image forState:UIControlStateNormal];
        button.customView = imageButtonView;
    }

    // Visibility
    updateVisibility(button, style);

    return button;
}

+ (UIBarButtonItem *)button:(NSDictionary *)dict position:(NSString *)aPosition {
#ifdef MONACA_PRIVATE_API
    NSString *iosStyle = [dict objectForKey:kNCStyleIOSButtonStyle];
    if (iosStyle) {
        UIBarButtonSystemItem item;
        if ([iosStyle isEqualToString:@"UIBarButtonSystemItemDone"]) {
            item = UIBarButtonSystemItemDone;
        } else if ([iosStyle isEqualToString:@"UIBarButtonSystemItemCancel"]) {
            item = UIBarButtonSystemItemCancel;
        } else if ([iosStyle isEqualToString:@"UIBarButtonSystemItemEdit"]) {
            item = UIBarButtonSystemItemEdit;
        } else if ([iosStyle isEqualToString:@"UIBarButtonSystemItemSave"]) {
            item = UIBarButtonSystemItemSave;
        } else if ([iosStyle isEqualToString:@"UIBarButtonSystemItemUndo"]) {
            item = UIBarButtonSystemItemUndo;
        } else if ([iosStyle isEqualToString:@"UIBarButtonSystemItemRedo"]) {
            item = UIBarButtonSystemItemRedo;
        }
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item target:nil action:nil];
    }
#endif // MONACA_PRIVATE_API
    
    NCButton *button = [[NCButton alloc] initWithTitle:nil
                                                  style:UIBarButtonItemStyleBordered
                                                 target:nil
                                                 action:nil
                                                postion:aPosition];
    return updateButton(button, dict);
}

static BOOL
isButtonView(UIView *view) {
    return [[[view class] description] isEqualToString:@"UIToolbarTextButton"];
}

+ (void)setUpdatedTag:(UIView *)view {
    if (isButtonView(view)) {
        view.tag = kUpdatedTag;
    }
}

static void
updateViewDictionary(NSDictionary *style) {
    MFDelegate *delegate = (MFDelegate *)[UIApplication sharedApplication].delegate;
    NSString *cid = [style objectForKey:kNCTypeID];

    // NOTE(nhiroki):　UIToolbar に UIBarButtonItem のオブジェクトを追加すると、実際には
    // UIBarButtonItem が持つ view オブジェクトがツールバーにセットされる。
    // さて UIBarButtonItem のテキストを変更しようとすると、このオブジェクトが
    // 持つ view オブジェクトが別の新しい view オブジェクトに置き変わることでテキストが変更される。
    // これにより、ボタンの色などがデフォルトに戻ってしまっていた。そこで view へ新しく色を設定する。
    // ところで iOS5 では UIBarButtonItem から view オブジェクトの色を操作することができるが、
    // iOS4 では view に対して直接色を設定しなくてはいけない。しかし view は勝手に置き変わってしまうため
    // それへの参照を得るのが難しい。そこで、ツールバー内を探索して置き換わったであろう view を見つけ出し、
    // 色などを設定する。置き換わったかどうかの判定には tag を用いる。ツールバーへの追加時にtag に
    // 値 (kUpdatedTag) をセットしておき、tag にその値がセットされていない view がいたらそれが置き換わった view である。
    if (cid != nil) {
        UINavigationController *navController = delegate.viewController.tabBarController.navigationController;
        for (UIView *toolbar in navController.navigationBar.subviews) {
            for (UIView *view in toolbar.subviews) {
                if (isButtonView(view) && view.tag != kUpdatedTag) {
                    [[MFUtility currentTabBarController].viewDict setObject:view forKey:cid];
                    view.tag = kUpdatedTag;
                }
            }
        }
        for (UIView *toolbar in navController.toolbar.subviews) {
            for (UIView *view in toolbar.subviews) {
                if (isButtonView(view) && view.tag != kUpdatedTag) {
                    [[MFUtility currentTabBarController].viewDict setObject:view forKey:cid];
                    view.tag = kUpdatedTag;
                }
            }
        }
    }
}

static UIBarButtonItem *
updateBackgroundColor(UIBarButtonItem *button, NSDictionary *style) {
    if (iOSVersionMajor() <= 4) {
        NSString *cid = [style objectForKey:kNCTypeID];
        NSString *bgColor = [style objectForKey:kNCStyleBackgroundColor];
        if (bgColor) {
            UIColor *color = hexToUIColor(removeSharpPrefix(bgColor), 1.0f);
            UIView *view = [[MFUtility currentTabBarController].viewDict objectForKey:cid];
            [view performSelector:@selector(setTintColor:) withObject:color];
        }
    }
    return button;
}

+ (UIBarButtonItem *)update:(UIBarButtonItem *)button with:(NSDictionary *)style {
#ifdef MONACA_PRIVATE_API
    NSString *iosStyle = [style objectForKey:kNCStyleIOSBarStyle];
    if (iosStyle) {
        return button;
    }
#endif // MONACA_PRIVATE_API
    
    updateButton(button, style);

    updateViewDictionary(style);
    updateBackgroundColor(button, style);
    return button;
}

@end
