//
//  NCButton.h
//  8Card
//
//  Created by KUBOTA Mitsunori on 12/05/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

@interface NCButton : UIBarButtonItem <UIStyleProtocol> {
    UIView* _imageButtonView;
    NSString* _position;
    NSMutableDictionary *ncStyle;
}

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action postion:(NSString *)aPosition;

@property (retain) UIView* imageButtonView;
@property (retain, readonly) NSString* position;

@end
