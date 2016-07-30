//
//  RunLoopSource.m
//  RunLoopTest
//
//  Created by wtwo on 16/7/28.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import "RunLoopSource.h"
#import "AppDelegate.h"



void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode) {
    RunLoopSource *obj = (__bridge RunLoopSource *)info;
    AppDelegate *del = [UIApplication.sharedApplication delegate];;
    RunLoopContext *theContext = [RunLoopContext.alloc initWithSource:obj andLoop:rl];
    [del performSelectorOnMainThread:@selector(registerSource:) withObject:theContext waitUntilDone:NO];
}

void RunLoopSourcePerformRoutine(void *info) {
    RunLoopSource *obj = (__bridge RunLoopSource *)info;
    [obj sourceFired];
}

void RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode) {
    RunLoopSource *obj = (__bridge RunLoopSource *)info;
    AppDelegate *del = [UIApplication.sharedApplication delegate];;
    RunLoopContext *theContext = [RunLoopContext.alloc initWithSource:obj andLoop:rl];
    [del performSelectorOnMainThread:@selector(removeSource:) withObject:theContext waitUntilDone:NO];
}


@implementation RunLoopSource

- (instancetype)init {
    self = [super init];
    if (!self) return self;
    CFRunLoopSourceContext context = {0, (__bridge void *)(self), NULL, NULL, NULL, NULL, NULL,
    &RunLoopSourceScheduleRoutine, &RunLoopSourceCancelRoutine, &RunLoopSourcePerformRoutine};
    
    _runLoopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    _commands = [NSMutableArray.alloc init];
    _commandsData = [NSMutableDictionary dictionaryWithCapacity:10];
    return self;
}

- (void)addToCurrentRunLoop {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

- (void)fireAllCommandsOnRunLoop:(CFRunLoopRef)runLoop {
    CFRunLoopSourceSignal(_runLoopSource);
    CFRunLoopWakeUp(runLoop);
}

- (void)invalidate {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(runLoop, _runLoopSource, kCFRunLoopDefaultMode);
}

- (void)addCommand:(NSInteger)command withData:(id)data {
    [_commands addObject:@(command)];
    [_commandsData setObject:data forKey:@(command)];
}

- (void)sourceFired {
    NSInteger cnt = _commands.count;
    for (NSInteger index = 0; index < cnt; ++index) {
        NSLog(@"command: %ld - commandData: %@", (long)[_commands[index] integerValue], _commandsData[_commands[index]]);
    }
}

@end

@implementation RunLoopContext

- (instancetype)initWithSource:(RunLoopSource *)source andLoop:(CFRunLoopRef)runLoop {
    self = [super init];
    if (!self) return self;
    _source = source;
    _runLoop = runLoop;
    return self;
}

@end
