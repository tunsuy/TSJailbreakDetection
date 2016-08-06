//
//  JailBreakHelper.m
//  TSJailbreakDetection
//
//  Created by tunsuy on 29/6/16.
//  Copyright © 2016年 tunsuy. All rights reserved.
//

#import "JailBreakHelper.h"
#import "AppDelegate.h"
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

#define CydiaPath @"/Applications/Cydia.app"
#define CydiaUrlScheme @"cydia://package/com.example.package"
#define AppPath @"/User/Applications/"

#define CydiaPathCStr "/Applications/Cydia.app"

#define StatDlibName @"/usr/lib/system/libsystem_kernel.dylib"
#define JailBreakDylib @"Library/MobileSubstrate/MobileSubstrate.dylib"

#define appEnv "DYLD_INSERT_LIBRARIES"

#pragma mark - C Method
bool has_cydia(void)
{
    struct stat stat_info;
    if (0 == (stat(CydiaPathCStr, &stat_info))) {
        return YES;
    }
    return NO;
}

/** 动态链接库stat的名字 */
const char * dylib_stat_info(void)
{
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        return dylib_info.dli_fname;
    }
    return NULL;
}

/** 列出所有已链接的动态库 */
CFArrayRef dylib_list(void)
{
    NSMutableArray *dylibList = [NSMutableArray array];
    uint32_t count = _dyld_image_count();
    for (uint32_t i=0; i<count; i++) {
        NSString *dylibName = [NSString stringWithUTF8String:_dyld_get_image_name(i)];
        [dylibList addObject:dylibName];
    }
    return CFBridgingRetain(dylibList);
}

/** 当前程序运行的环境变量 */
char * appRunEnv(void)
{
    char *env = getenv(appEnv);
    return env;
}

@implementation JailBreakHelper

+ (BOOL)isJailBroken {
    if ([[NSFileManager defaultManager] fileExistsAtPath:CydiaPath]) {
        return YES;
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:CydiaUrlScheme]]) {
        return YES;
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:AppPath]) {
        NSArray *appList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:AppPath error:nil];
        NSLog(@"appList = %@", appList);
        return YES;
    }
    
    if (has_cydia()) {
        return YES;
    }
    
    const char * stat_dlib_name = dylib_stat_info();
    if (![[NSString stringWithUTF8String:stat_dlib_name] isEqualToString:StatDlibName]) {
        return YES;
    }
    
    CFArrayRef dlibListArrayRef = dylib_list();
    NSArray *dlibListArray = CFBridgingRelease(dlibListArrayRef);
    if ([dlibListArray containsObject:JailBreakDylib]) {
        return YES;
    }
    
    if (NULL != appRunEnv()) {
        return YES;
    }
    
    return NO;
}



@end
