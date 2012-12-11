//
//  TemplateResourceDictionary.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/04/01.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TemplateResourceDictionary : NSObject {
 @private
	NSMutableDictionary *dictionary_;
}

- (void)set:(NSString *)text forKey:(NSString *)path;
- (void)setWithContentsOfFile:(NSString *)filename forKey:(NSString *)key;
- (BOOL)exists:(NSString *)path;
- (NSString *)get:(NSString *)path;

@end
