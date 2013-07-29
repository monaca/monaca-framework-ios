//
//  MonacaTabBarController.h
//  MonacaFramework
//
//  Created by Hiroki Nakagawa on 11/11/10.
//  Copyright (c) 2011 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFDelegate.h"
#import "NativeComponents.h"
#import "MFDevice.h"

@class PhoneGapViewController;
@class NCContainer;
@class NCManager;

@interface MFTabBarController : UITabBarController <UITabBarControllerDelegate,UITabBarDelegate,UIStyleProtocol> {
 @private
    NCManager *_ncManager;
    NCStyle *_ncStyle;
    id<UIStyleProtocol> _navigationBar;
    NCContainer *_backButton;
    NSDictionary *_uidict;
    BOOL _isload;
}

@property(nonatomic, retain) NCManager *ncManager;
@property(nonatomic, retain) NSDictionary *uidict;
@property (nonatomic, retain) NCContainer *backButton;

@end
