//
//  NCSearchBox.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "NCSearchBox.h"
#import "NativeComponentsInternal.h"

@implementation NCSearchBox

@synthesize deleagte = _delegate;

- (id)init {
    self = [super init];

    if (self) {
        _searchBar = [[UISearchBar alloc] init];
        _type = kNCComponentSearchBox;
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        [searchField  setEnablesReturnKeyAutomatically:NO];

        // ignore background to adapt container Color
        UIView * backgroundView = [_searchBar valueForKey:@"_background"];
        [backgroundView removeFromSuperview];
        [_searchBar setFrame:CGRectMake(0, 0, 110, 44) ];
        self.customView = _searchBar;
        _searchBar.delegate = self;
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCComponentSearchBox];
    }

    return self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_delegate searchBarSearchButtonClicked:searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_ncStyle updateStyle:searchText forKey:kNCStyleValue];
}

#pragma mark - UIStyleProtocol

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (![_ncStyle checkStyle:value forKey:key]) {
        return;
    }
    
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    if ([NSStringFromClass([[_ncStyle.styles valueForKey:key] class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
    }
    

    if ([key isEqualToString:kNCStyleVisibility]) {
        _hidden = isFalse(value);
        [_toolbar applyVisibility];
    }
    if ([key isEqualToString:kNCStyleDisable]) {
        if (isFalse(value)) {
            [_searchBar setUserInteractionEnabled:YES];
        } else {
            [_searchBar setUserInteractionEnabled:NO];
        }
    }

    if ([key isEqualToString:kNCStyleOpacity]) {
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        [searchField setAlpha:[value floatValue]];
    }
    if ([key isEqualToString:kNCStyleTextColor]) {
        UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
        [searchField setTextColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStylePlaceholder]) {
        value = [NSString stringWithFormat:@"%@", value];
        [_searchBar setPlaceholder:value];
    }
    if ([key isEqualToString:kNCStyleFocus]) {
        if (isFalse(value)) {
            [_searchBar resignFirstResponder];
        } else {
            [_searchBar becomeFirstResponder];
        }
    }
    if ([key isEqualToString:kNCStyleValue]) {
        [_searchBar setText:value];
    }

    [_ncStyle updateStyle:value forKey:key];
}

@end
