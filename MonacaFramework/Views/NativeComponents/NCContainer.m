//
//  NCContainer.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/11/21.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import "NCContainer.h"
#import "NCButton.h"
#import "NCBarButtonItem.h"  

@implementation NCContainer

@synthesize cid = cid_;
@synthesize view = view_;
@synthesize component = component_;
@synthesize type = type_;
@synthesize onTapScript = onTapScript_;
@synthesize onChangeScript = onChangeScript_;
@synthesize onSearchScript = onSearchScript_;

- (void)dealloc {
    self.component = nil;
    self.onTapScript = nil;
    self.onChangeScript = nil;
    self.onSearchScript = nil;
    self.view = nil;
    self.component = nil;
    self.type = nil;
}


// =================================================
// Builder method.
// =================================================

// Creates a container, wrapping a component, for the toolbar.
+ (NCContainer *)container:(NSDictionary *)params position:(NSString *)aPosition {
    NSString *type = [params objectForKey:kNCStyleComponent];
    NCContainer *container = [[NCContainer alloc] init];
    
    // Set component ID.
    container.cid = [params objectForKey:kNCTypeID];
    
    NSMutableDictionary *style_def = [NSMutableDictionary dictionary];
    [style_def addEntriesFromDictionary:[params objectForKey:kNCTypeStyle]];
    [style_def addEntriesFromDictionary:[params objectForKey:kNCTypeIOSStyle]];

    if ([type isEqualToString:kNCComponentButton]) {
        container.component = [NCButtonBuilder button:style_def position:aPosition];
        container.onTapScript = [[params objectForKey:kNCTypeEvent] objectForKey:kNCEventTypeTap];
        
        // for image button case
        NCButton* button = (NCButton*)container.component;
        [(UIButton *)button.imageButtonView addTarget:container action:@selector(didTap:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        // for UIBarButtonItem case
        [container.component setAction:@selector(didTap:forEvent:)];
        [container.component setTarget:container];
        
        container.type = kNCComponentButton;
    }
    else if ([type isEqualToString:kNCComponentBackButton]) {
        UIButton *button = [NCBackButtonBuilder backButton:style_def];
        container.view = button;
        NCBarButtonItem* ncBarButtonItem = [[NCBarButtonItem alloc] initWithCustomView:button];
        ncBarButtonItem.hidden =button.hidden;
        container.component = ncBarButtonItem;
        container.onTapScript = [[params objectForKey:kNCTypeEvent] objectForKey:kNCEventTypeTap];
        [button addTarget:container action:@selector(didTap:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        container.type = kNCComponentBackButton;
    }
    else if ([type isEqualToString:kNCComponentLabel]) {
        UILabel *label = [NCLabelBuilder label:style_def];
        container.view = label;
        NCBarButtonItem* ncBarButtonItem = [[NCBarButtonItem alloc] initWithCustomView:label];
        ncBarButtonItem.hidden = label.hidden;
        container.component = ncBarButtonItem; 
        container.type = kNCComponentLabel;
    }
    else if ([type isEqualToString:kNCComponentSearchBox]) {
        UISearchBar *searchBox = [NCSearchBoxBuilder searchBox:style_def];
        container.view = searchBox;
        NCBarButtonItem* ncBarButtonItem = [[NCBarButtonItem alloc] initWithCustomView:searchBox];
        ncBarButtonItem.hidden = searchBox.hidden;
        container.component = ncBarButtonItem;
        container.onSearchScript = [[params objectForKey:kNCTypeEvent] objectForKey:kNCEventTypeSearch];
        searchBox.delegate = container;

        for (UIView *subview in searchBox.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITextField")]) {
                ((UITextField *)subview).enablesReturnKeyAutomatically = NO;
            }
        }
        container.type = kNCComponentSearchBox;
    }
    else if ([type isEqualToString:kNCComponentSegment]) {
        UISegmentedControl *segment = [NCSegmentBuilder segment:style_def];
        container.view = segment;
        NCBarButtonItem* ncBarButtonItem  = [[NCBarButtonItem alloc] initWithCustomView:segment];
        ncBarButtonItem.hidden = segment.hidden; 
        container.component = ncBarButtonItem;
        container.onTapScript = [[params objectForKey:kNCTypeEvent] objectForKey:kNCEventTypeTap];
        container.onChangeScript = [[params objectForKey:kNCTypeEvent] objectForKey:kNCEventTypeChange];
        
        [segment addTarget:container action:@selector(didChange:forEvent:) forControlEvents:UIControlEventValueChanged];
        // TODO(nhiroki): Do not work.
        [segment addTarget:container action:@selector(didTap:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        container.type = kNCComponentSegment;
    }
    
    // set frame
    NSDictionary *iosFrame = [params objectForKey:kNCStyleIOSFrame];
    if (iosFrame) {
        float x = [[iosFrame objectForKey:@"x"] floatValue];
        float y = [[iosFrame objectForKey:@"y"] floatValue];
        float w = [[iosFrame objectForKey:@"w"] floatValue];
        float h = [[iosFrame objectForKey:@"h"] floatValue];
        CGRect rect = CGRectMake(x, y, w, h);
        [container.view setFrame:rect];
    }

    return container;
}


// =================================================
// Event handlers.
// =================================================

// Handle an onSearch event.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    UIWebView *webView = ((MFDelegate *)[UIApplication sharedApplication].delegate).viewController.cdvViewController.webView;
    NSString *js = [NSString stringWithFormat:@"__search_text='%@';%@", searchBar.text, onSearchScript_];
    [webView stringByEvaluatingJavaScriptFromString:js];
    [searchBar resignFirstResponder];
}

// TODO: js variable name "__segment_index"
// Handle an onChange event.
- (void)didChange:(id)sender forEvent:(UIEvent *)event {

    NSString *index = @"";
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segment = sender;
        NSInteger _index = segment.selectedSegmentIndex;
        index = [NSString stringWithFormat:@"var __segment_index = '%d';", _index];
    }

    NSString *js = [NSString stringWithFormat:@"%@%@", index, onChangeScript_];
    UIWebView *webView = ((MFDelegate *)[UIApplication sharedApplication].delegate).viewController.cdvViewController.webView;
    [webView stringByEvaluatingJavaScriptFromString:js];
}

// Handle an onTap event.
- (void)didTap:(id)sender forEvent:(UIEvent *)event {
    UIWebView *webView = ((MFDelegate *)[UIApplication sharedApplication].delegate).viewController.cdvViewController.webView;
    [webView stringByEvaluatingJavaScriptFromString:onTapScript_];
}

@end
