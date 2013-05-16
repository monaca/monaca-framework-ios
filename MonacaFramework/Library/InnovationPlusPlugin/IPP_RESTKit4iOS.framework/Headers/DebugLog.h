//
//  @File       DebugLogMacro.h
//  @Project    IPPDemoApp
//  @brief      Debug Macro
//  @version    1.0.0
//
//  Created by Ken Miyachi on 12/09/18.
//  Copyright (c) 2012 Ken Miyachi. All rights reserved.
//


#ifndef IPPDemoApp_DebugLog_h
#define IPPDemoApp_DebugLog_h

#pragma mark -
#pragma mark DEBUG_MACRO

#ifdef DEBUG
    #define DLOG(...) NSLog((@"%s %d : %@"), __PRETTY_FUNCTION__, __LINE__,__VA_ARGS__);
    #define LOG(...) NSLog(__VA_ARGS__)
    #define LOG_METHOD NSLog(@"%s", __PRETTY_FUNCTION__)
    #define LOG_POINT(p) NSLog(@"%f, %f", p.x, p.y)
    #define LOG_SIZE(p) NSLog(@"%f, %f", p.width, p.height)
    #define LOG_RECT(p) NSLog(@"%f, %f - %f, %f", p.origin.x, p.origin.y, p.size.width, p.size.height)
#else
    #define DLOG(...)
    #define LOG(...)
    #define LOG_METHOD
    #define LOG_POINT(p)
    #define LOG_SIZE(p)
    #define LOG_RECT(p)
#endif

#pragma mark -
#pragma mark VERIFICATION SCREEN SIZE & DEVICE

#define IS_4INCH (([UIScreen mainScreen].scale == 2.0f && [UIScreen mainScreen].bounds.size.height == 568.0f) ? YES : NO)
#define IS_PAD ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? YES : NO)
#define IS_PHONE ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? YES : NO)
#define IS_RETINA (([UIScreen mainScreen].scale == 2.0f) ? YES : NO)
#define SCREEN_SIZE_STR (NSStringFromCGRect([UIScreen mainScreen].bounds))

#pragma mark -
#pragma mark COORDINATE DATA STRING

#define SIZE_STR(p) [NSString stringWithFormat:@"%f , %f", p.width, p.height]
#define POINT_STR(p) [NSString stringWithFormat:@"%f, %f", p.x, p.y]
#define RECT_STR(p) [NSString stringWithFormat:@"%f, %f - %f, %f", p.origin.x, p.origin.y, p.size.width, p.size.height]

#endif
