//
//  MFJSInterfaceProtocolTest.m
//  MonacaFramework
//
//  Created by Katsuya Saitou on 13/01/21.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFJSInterfaceProtocolTest.h"

@implementation MFJSInterfaceProtocolTest

- (void)testCanInitWithRequest
{
    GHAssertTrue([MFJSInterfaceProtocol canInitWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"monaca://action?type=console.log&message=I'm log"]]], @"monca scheme");
    GHAssertFalse([MFJSInterfaceProtocol canInitWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://monaca.mobi"]]], @"http scheme");
}
@end
