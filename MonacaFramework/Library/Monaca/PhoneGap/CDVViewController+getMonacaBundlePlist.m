//
//  CDVViewController+getBundlePlist.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 12/09/30.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "CDVViewController+getMonacaBundlePlist.h"

@implementation CDVViewController (getMonacaBundlePlist)

+ (NSDictionary*) getMonacaBundlePlist:(NSString*)plistName
{
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format errorDescription:&errorDesc];
    
    if ([plistName isEqualToString:@"Cordova"]) {
        NSDictionary *cordovaDictInInfo = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Cordova"];
        NSMutableDictionary *copyDict = [[NSMutableDictionary alloc] initWithDictionary:temp];
        if (cordovaDictInInfo == nil){
            return copyDict;
        }
        for (NSString *key in temp) {
            id value = [cordovaDictInInfo valueForKey:key];
            if (value != nil) {
                [copyDict setValue:value forKey:key];
            }
        }
        return copyDict;
    } else {
        return temp;
    }
}

@end
