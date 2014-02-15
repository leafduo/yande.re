//
//  SDImageCache+DeadLock.m
//  yande.re
//
//  Created by Zuyang Kou on 2/16/14.
//  Copyright (c) 2014 leafduo.com. All rights reserved.
//

#import "SDImageCache+DeadLock.h"
#import <objc/runtime.h>

// Patch SDWebImage to fix a bug, see
// https://github.com/rs/SDWebImage/issues/625

@implementation SDImageCache (DeadLock)

+ (void)load {
    method_exchangeImplementations(
        class_getInstanceMethod(self, @selector(diskImageExistsWithKey:)),
        class_getInstanceMethod(self, @selector(YANDiskImageExistsWithKey:)));
}

- (BOOL)YANDiskImageExistsWithKey:(NSString *)key {
    BOOL exists = NO;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    exists = [[NSFileManager defaultManager]
        fileExistsAtPath:[self
                             performSelector:@selector(defaultCachePathForKey:)
                                  withObject:key]];
#pragma clang diagnostic pop

    return exists;
}

@end
