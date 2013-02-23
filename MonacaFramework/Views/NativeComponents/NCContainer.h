//
//  NCContainer.h
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/11/21.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NativeComponents.h"

//
// NCContainer class wraps UIBarButtonItem and has additional information.
//
@interface NCContainer : NSObject <UISearchBarDelegate> {
 @private
    NSString *cid_;               // Component ID.
    
    id view_;                     // Center component on top toolbar.
    UIBarButtonItem *component_;  // Other components.
    NSString *type_;              // Component type (kNCComponentButton, ...).

    NSString *onTapScript_;
    NSString *onChangeScript_;
    NSString *onSearchScript_;
}

+ (NCContainer *)container:(NSDictionary *)params position:(NSString *)aPosition;

@property(nonatomic, copy) NSString *cid;
@property(nonatomic, retain) id view;
@property(nonatomic, retain) UIBarButtonItem *component;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *onTapScript;
@property(nonatomic, copy) NSString *onChangeScript;
@property(nonatomic, copy) NSString *onSearchScript;

@end
