//
//  CDVCookieMaster.m
//
//
//  Created by Kristian Hristov on 12/16/14.
//
//

#import "CDVCookieMaster.h"


@implementation CDVCookieMaster

 - (void)getCookieValue:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* urlString = [command.arguments objectAtIndex:0];
    __block NSString* cookieName = [command.arguments objectAtIndex:1];

    if (urlString != nil) {
        NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:urlString]];

        __block NSString *cookieValue;

        [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSHTTPCookie *cookie = obj;
            if([cookie.name isEqualToString:cookieName])
            {
                cookieValue = cookie.value;
                *stop = YES;
            }
        }];
        if (cookieValue != nil) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"cookieValue":cookieValue}];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No cookie found"];
        }

    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"URL was null"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

 - (void)setCookieValue:(CDVInvokedUrlCommand*)command
{
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    CDVPluginResult* pluginResult = nil;
    NSString* urlString = [command.arguments objectAtIndex:0];
    NSString* cookieName = [command.arguments objectAtIndex:1];
    NSString* cookieValue = [command.arguments objectAtIndex:2];
    NSMutableDictionary* cookieOptions = [command.arguments objectAtIndex:3];

    id pathOption    = [cookieOptions objectForKey:@"path"];
    id domainOption  = [cookieOptions objectForKey:@"domain"];
    id secureOption  = [cookieOptions objectForKey:@"secure"];
    id expiresOption = [cookieOptions objectForKey:@"expires"];

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:cookieName forKey:NSHTTPCookieName];
    [cookieProperties setObject:cookieValue forKey:NSHTTPCookieValue];
    [cookieProperties setObject:urlString forKey:NSHTTPCookieOriginURL];

    if ([pathOption isKindOfClass:[NSString class]]) {
      [cookieProperties setObject:pathOption forKey:NSHTTPCookiePath];
    } else {
      [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    }

    if ([domainOption isKindOfClass:[NSString class]]) {
      [cookieProperties setObject:domainOption forKey:NSHTTPCookieDomain];
    }

    if ([secureOption isKindOfClass:[NSString class]]) {
      if ([secureOption isEqualToString:@"true"]) {
        [cookieProperties setObject:@"true" forKey:NSHTTPCookieSecure];
      }
    } else if ([secureOption boolValue]) {
      [cookieProperties setObject:@"true" forKey:NSHTTPCookieSecure];
    }

    if ([expiresOption isKindOfClass:[NSString class]]) {
      [cookieProperties setObject:expiresOption forKey:NSHTTPCookieExpires];
    }

    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];

    NSArray* cookies = [NSArray arrayWithObjects:cookie, nil];

    NSURL *url = [[NSURL alloc] initWithString:urlString];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:cookieProperties];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
