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
    NSMutableDictionary *_ncStyle;
}

@property(nonatomic, retain) NCManager *ncManager;

@end
