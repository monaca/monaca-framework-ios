//
//  MonacaTemplateEngine.m
//  ForteTemplateEngine
//
//  Created by Hiroki Nakagawa on 11/08/16.
//  Copyright 2011 ASIAL CORPORATION. All rights reserved.
//

#import "MonacaTemplateEngine.h"

#import "TemplateCompiler.h"
#import "TemplateExecuter.h"
#import "TemplateResourceDictionary.h"

@implementation MonacaTemplateEngine

static NSString *applicationRoot = @"";

+ (NSString *)compileFromString:(NSString *)text path:(NSString *)path {
    NSString *html = nil;
    
    @try {
        TemplateResourceDictionary *dict = [[TemplateResourceDictionary alloc] init];
        [dict set:text forKey:path];

        // Compile template text to the Template class.
        TemplateCompiler *driver = [[TemplateCompiler alloc] init:dict];
        Template *template = [driver compileFrom:path];

        // Execute template objects.
        html = [[[TemplateExecuter alloc] init] execute:template];
    }
    @catch (NSException *exception) {
        html = [exception description];
    }
    
    return html;
}

+ (NSString *)compileFromFile:(NSString *)path {
    NSString *html = nil;
    
    @try {
        TemplateResourceDictionary *dict = [[TemplateResourceDictionary alloc] init];
        [dict setWithContentsOfFile:path forKey:path];
        
        // Compile template file to the Template class.
        TemplateCompiler *driver = [[TemplateCompiler alloc] init:dict];
        Template *template = [driver compileFrom:path];

        // Execute template object.
        html = [[[TemplateExecuter alloc] init] execute:template];
    }
    @catch (NSException *exception) {
        html = [exception description];
    }

    return html;
}

+ (void)setApplicationRootPath:(NSString *)path {
    applicationRoot = [path retain];
}

+ (NSString *)getApplicationRootPath {
    if ([applicationRoot isEqualToString:@""]){
        return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"www"];
    }else {
        return applicationRoot;
    }
}

@end
