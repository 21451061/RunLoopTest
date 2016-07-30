//
//  AppDelegate.m
//  RunLoopTest
//
//  Created by wtwo on 16/7/27.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import "AppDelegate.h"
#import "RunLoopSource.h"
#import "RunLoopCustomInputSourceThread.h"

#define kTestCustomInputSource 0

@interface AppDelegate ()

@end

@implementation AppDelegate {
    NSMutableArray *_sourcesToPing;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if (kTestCustomInputSource) {
        [self startCustomInputSourceThread];
    }
    
    return YES;
}

- (void)registerSource:(RunLoopContext *)contextInfo {
    if (!_sourcesToPing) {
        _sourcesToPing = [NSMutableArray new];
    }
    [_sourcesToPing addObject:contextInfo];
}

- (void)removeSource:(RunLoopContext *)contextInfo {
    id sourceToRemove  = nil;
    for (RunLoopContext *context in _sourcesToPing) {
        if ([context isEqual:contextInfo]) {
            sourceToRemove = context;
            break;
        }
    }
    if (sourceToRemove) {
        [_sourcesToPing removeObject:sourceToRemove];
    }
}

- (void)startCustomInputSourceThread {
    RunLoopCustomInputSourceThread *thread = [RunLoopCustomInputSourceThread new];
    [thread start];
}

- (void)testCustomInputSourceCommand {
    RunLoopContext *theContext = [_sourcesToPing objectAtIndex:0];
    RunLoopSource *customSource = theContext.source;
    [customSource addCommand:0 withData:[NSString stringWithFormat:@"hello %s", __func__]];
    [customSource fireAllCommandsOnRunLoop:theContext.runLoop];
}

@end
