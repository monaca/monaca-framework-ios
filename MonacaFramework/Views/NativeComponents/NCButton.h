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
    NSString* _position;
    NSMutableDictionary *_ncStyle;
}

- (void)applyUserInterface:(NSDictionary *)uidict;

@end
