//
//  NCSearchBar.h
//  8Card
//
//  Created by KUBOTA Mitsunori on 12/05/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum _NCSearchBarType {
    kNCSearchBarTypeDefault,
    kNCSearchBarTypeCenter
};

typedef enum _NCSearchBarType NCSearchBarType;

@interface NCSearchBar : UISearchBar {
    NCSearchBarType _type;
}

- (void)didRotate:(NSNotification *)notification;
- (void)setNCSearchBarType:(NCSearchBarType)type;
- (void)updateFrameForOrieantionAndType;

@end
