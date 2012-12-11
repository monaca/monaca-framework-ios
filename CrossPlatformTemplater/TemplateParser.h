//
//  TemplateParser.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/01.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TopStatementsNode;
@protocol Node;


/*
 * TemplateParser class.
 */
@interface TemplateParser : NSObject {
 @private
    id<Node> rootNode_;
}

// Parses template text.
- (TopStatementsNode *)parse:(NSString *)path;

@property(retain, nonatomic) id<Node> rootNode;

@end
