//
//  MonacaTemplateEngine.h
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/08/16.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// MonacaTemplateEngine class.
//
// This is the interface of the Monaca Template Engine.
//
@interface MonacaTemplateEngine : NSObject {
    
}

+ (NSString *)compileFromString:(NSString *)text path:(NSString *)path;
+ (NSString *)compileFromFile:(NSString *)path;

+ (void)setApplicationRootPath:(NSString *)path;
+ (NSString *)getApplicationRootPath;
@end
