//
//  NCSearchBoxBuilder.m
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/15.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import "NCSearchBoxBuilder.h"
#import "NCSearchBar.h"
#import "MFPGNativeComponent.h"

@implementation NCSearchBoxBuilder

static inline void
removeBackgroundView(UISearchBar *searchBox) {
    for (UIView *view in searchBox.subviews) {
        if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [view removeFromSuperview];
            break;
        }
    }
}

static UISearchBar *
updateSearchBox(UISearchBar *searchBox, NSDictionary *style) {
    BOOL invisible = isFalse([style objectForKey:kNCStyleVisibility]);
    [searchBox setHidden:invisible];
    
    // TODO(nhiroki): Opacity does not work. INFO(yoshiki): bgColor unconsidered.
    NSString *opacity = [style objectForKey:kNCStyleOpacity];
    if (opacity) {
        float alpha = [opacity floatValue];
        if (alpha < 1.0f) {
            [searchBox setTranslucent:YES];
        }
    }

    // TODO(nhiroki): Ignore background color.
    removeBackgroundView(searchBox);
    
    NSString *placeholder = [style objectForKey:kNCStylePlaceholder];
    if (placeholder) {
        [searchBox setPlaceholder:placeholder];
    }

    NSString *value = [style objectForKey:kNCStyleValue];
    if (value) {
        [searchBox setText:value];
    }
    
    NSString *focus = [style objectForKey:kNCStyleFocus];
    if (isFalse(focus)) {
        [searchBox resignFirstResponder];
    }

    NSString *bgColor = [style objectForKey:kNCStyleBackgroundColor];
    if (bgColor) {
        [searchBox setBackgroundColor:hexToUIColor(removeSharpPrefix(bgColor), 1)];
     }
    // TODO(nhiroki): Ignore text color.
    
    return searchBox;
}

+ (UISearchBar *)searchBox:(NSDictionary *)style {
    UISearchBar *searchBox = [[NCSearchBar alloc] init];
    
    return updateSearchBox(searchBox, style);
}

+ (void)makeWide:(UISearchBar*)searchBar {
    NCSearchBar* bar = (NCSearchBar*)searchBar;
    [bar setNCSearchBarType:kNCSearchBarTypeCenter];
}

+ (UIBarButtonItem *)update:(UIBarButtonItem *)searchBox with:(NSDictionary *)style {
    searchBox.customView = updateSearchBox((UISearchBar *)searchBox.customView, style);
    return searchBox;
}

+ (NSMutableDictionary *)retrieve:(UIBarButtonItem *)searchBox {
    UISearchBar *view = (UISearchBar *)searchBox.customView;
    NSMutableDictionary *style = [NSMutableDictionary dictionary];

    if (view.placeholder) {
        [style setObject:view.placeholder forKey:kNCStylePlaceholder];
    }

    if (view.text) {
        [style setObject:view.text forKey:kNCStyleValue];
    }

    UITextField *searchField;
    NSUInteger numViews = [view.subviews count];
    for(int i = 0; i < numViews; i++) {
        if([[view.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            searchField = [view.subviews objectAtIndex:i];
        }
    }

    if(searchField) {
        [style setObject:UIColorToHex(searchField.textColor) forKey:kNCStyleTextColor];
    }

    if (view.backgroundColor) {
        [style setObject:UIColorToHex(view.backgroundColor) forKey:kNCStyleBackgroundColor];
    }

    if (view.userInteractionEnabled) {
        [style setObject:kNCFalse forKey:kNCStyleDisable];
    } else {
        [style setObject:kNCTrue forKey:kNCStyleDisable];
    }

    if (view.hidden) {
        [style setObject:kNCFalse forKey:kNCStyleVisibility];
    } else {
        [style setObject:kNCTrue forKey:kNCStyleVisibility];
    }

    if (view.selectedScopeButtonIndex){
        [view resignFirstResponder];
    }

    if (view.isFirstResponder) {
        [style setObject:kNCTrue forKey:kNCStyleFocus];
    } else {
        [style setObject:kNCFalse forKey:kNCStyleFocus];
    }

    return style;
}

@end
