//
//  RunLoopCustomInputSourceThread.m
//  RunLoopTest
//
//  Created by wtwo on 16/7/28.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import "RunLoopCustomInputSourceThread.h"
#import "RunLoopSource.h"

@interface RunLoopCustomInputSourceThread ()

@property (nonatomic, strong) RunLoopSource *customSource;

@end

@implementation RunLoopCustomInputSourceThread

- (void)main {
    NSLog(@"RunLoopCustomInputSourceThread Enter");
    self.customSource = [RunLoopSource new];
    [self.customSource addToCurrentRunLoop];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    while (!self.cancelled) {
        NSLog(@"Enter RunLoop");
        
        [self fooBar];
        
        [runLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
        
        NSLog(@"Exit RunLoop");
    }
    
    NSLog(@"RunLoopCustomInputSourceThread Exit");
}

- (void)fooBar {
    NSLog(@"🌹🌹🌹🌹🌹🌹🌹🌹🌹🌹🌹🌹");
    NSLog(@"🍊🍊🍊🍊🍊🍊🍊🍊🍊🍊🍊🍊");
}

@end
