//
//  RunLoopSource.h
//  RunLoopTest
//
//  Created by wtwo on 16/7/28.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunLoopSource : NSObject {
    CFRunLoopSourceRef _runLoopSource;
    NSMutableArray *_commands;
    NSMutableDictionary *_commandsData;
}

- (instancetype)init;
- (void)addToCurrentRunLoop;
- (void)invalidate;

//Handler method
- (void)sourceFired;

//Client interface for registering commands to process
- (void)addCommand:(NSInteger)command withData:(id)data;
- (void)fireAllCommandsOnRunLoop:(CFRunLoopRef)runLoop;

@end

//These are CFRunLoopRef callback functions

void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine(void *info);
void RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);

//RunLoopContext is a container used during registering of a input source
@interface RunLoopContext : NSObject {
    CFRunLoopRef _runLoop;
    RunLoopSource *_source;
}

@property (readonly) CFRunLoopRef runLoop;
@property (readonly) RunLoopSource *source;

- (instancetype)initWithSource:(RunLoopSource *)source andLoop:(CFRunLoopRef)runLoop;

@end