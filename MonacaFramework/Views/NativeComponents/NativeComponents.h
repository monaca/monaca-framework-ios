//
//  NativeComponents.h
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/10.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MFTabBarController.h"

#import "NCButtonBuilder.h"
#import "NCLabelBuilder.h"
#import "NCSearchBoxBuilder.h"
#import "NCSegmentBuilder.h"
#import "NCContainer.h"
#import "NCTitleView.h"
#import "NCTabbarItemBuilder.h"
#import "NCBackButtonBuilder.h"
#import "NCButton.h"

#import "NCToolbar.h"
#import "NCManager.h"

// WebView status tags.
static const NSUInteger kWebViewNormal = 0;
static const NSUInteger kWebViewIgnoreStyle = 10;  // Ignore native component style.
static const NSUInteger kWebViewBackground = 20;
