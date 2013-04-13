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

@interface MFTabBarController : UITabBarController <UITabBarControllerDelegate,UITabBarDelegate> {
 @private
    NCContainer *centerContainer_;

    // Top toolbar components.
    NSMutableArray *leftContainers_;
    NSMutableArray *rightContainers_;

    // Bottom toolbar components.
    NSMutableArray *leftBottomToolbarContainers_;
    NSMutableArray *centerBottomToolbarContainers_;
    NSMutableArray *rightBottomToolbarContainers_;

    NSMutableDictionary *viewDict_;

    NCManager *ncManager_;
    NSInteger activeIndex_;
    BOOL isInitialized_;
    BOOL isLocked;
}

+ (void)setIgnoreBottom:(BOOL)ignore;
- (id)initWithWwwDir:(NSString *)wwwDir path:(NSString *)path;
- (void)applyBottomTabbar:(NSDictionary *)uidict WwwDir:(NSString *)wwwDir;

- (NSMutableArray *)createContainers:(NSArray *)components position:(NSString *)aPosition;
- (void)restoreUserInterface;

@property(nonatomic, retain) NCContainer *centerContainer;
@property(nonatomic, retain) NSMutableArray *leftContainers;
@property(nonatomic, retain) NSMutableArray *rightContainers;

@property(nonatomic, retain) NSMutableArray *leftBottomToolbarContainers;
@property(nonatomic, retain) NSMutableArray *centerBottomToolbarContainers;
@property(nonatomic, retain) NSMutableArray *rightBottomToolbarContainers;

@property(nonatomic, retain) NSMutableDictionary *viewDict;

@property(nonatomic, retain) NCManager *ncManager;
@property(nonatomic, assign) NSInteger activeIndex;

// this property should be used only self and category.
@property(nonatomic, readonly) BOOL isInitialized;

@end


#import "MFTabBarController+Top.h"
#import "MFTabBarController+Bottom.h"