//
//  ViewController.m
//  RunLoopTest
//
//  Created by wtwo on 16/7/27.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MyWorkClass.h"

//#import <mach/mach_port.h>

@interface ViewController () <NSPortDelegate>

@property (nonatomic, assign) BOOL didRunLoopThreadFinish;
#if kUseNSMachPort
@property (nonatomic, strong) NSPort *distancePort;
@property (nonatomic, strong) NSPort *myPort;
#endif

@end

@implementation ViewController

- (IBAction)handleTestCustomSourceButtonTouchUpInside {
    AppDelegate *del = [UIApplication.sharedApplication delegate];
    [del testCustomInputSourceCommand];
}

- (IBAction)handleTestRunLoopThread {
    NSLog(@"handleTestRunLoopThread Enter");
    
    _didRunLoopThreadFinish = NO;
    
    NSLog(@"Start a new runLoop thread");
    NSThread *thread = [NSThread.alloc initWithTarget:self selector:@selector(runLoopThreadTask) object:nil];
    [thread start];
    
    while (!self.didRunLoopThreadFinish) {
        NSLog(@"Begin Run Loop, Thread: %@", [NSThread currentThread]);
        
        [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
        
        NSLog(@"End Run Loop, Thread: %@", [NSThread currentThread]);
    }
    
    NSLog(@"handleTestRunLoopThread Exit");
}

- (void)runLoopThreadTask {
    for (int i = 0; i < 5; ++i) {
        NSLog(@"Count: %d, Thread: %@", i, [NSThread currentThread]);
        sleep(1);
    }
    
#if 0
    //bad practise
    _didRunLoopThreadFinish = YES;
#else
    [self performSelectorOnMainThread:@selector(updateDidRunLoopThreadFinish) withObject:nil waitUntilDone:NO];
#endif
}

- (void)updateDidRunLoopThreadFinish {
    _didRunLoopThreadFinish = YES;
}

- (IBAction)SendMsgFromWorkThreadToMainThread {
    [self launchThread];
}

- (IBAction)SendMsgFromMainThreadBackToWorkThread {
    
    NSString *msg = [NSString stringWithFormat:@"from %@: %s", [NSThread currentThread] , __func__];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    NSPort *distantPort = nil;
    NSPort *myPort = nil;
#if kUseNSMachPort
    distantPort =self.distancePort;
    myPort = self.myPort;
#else 
    distantPort = [NSMessagePortNameServer.sharedInstance portForName:kWorkThreadMessagePortName];
    myPort = [NSMessagePortNameServer.sharedInstance portForName:kMainThreadMessagePortName];
#endif
    
    NSPortMessage *messageObj = [[NSPortMessage alloc] initWithSendPort:distantPort
                                                            receivePort:myPort components:@[data]];
    if (messageObj) {
        [messageObj setMsgid:kCheckinMessage];
        [messageObj sendBeforeDate:NSDate.date];
    }
}

- (void)launchThread {
#if kUseNSMachPort
    NSPort *myPort = [NSMachPort port];
    [self setMyPort:myPort];
#else
    NSPort *myPort = [NSMessagePort new];
    [NSMessagePortNameServer.sharedInstance registerPort:myPort name:kMainThreadMessagePortName];
#endif
    if (myPort) {
        [myPort setDelegate:self];

        //在main runloop中注册port-based source，监听发送到该port的消息
        [NSRunLoop.currentRunLoop addPort:myPort forMode:NSDefaultRunLoopMode];
        
        [NSThread detachNewThreadSelector:@selector(LaunchThreadWithPort:)
                                 toTarget:[MyWorkClass class]
                               withObject:myPort];
    }
}

#pragma mark - NSPortMessageDelegate 
//处理从Work Thread发送的port消息
- (void)handlePortMessage:(NSPortMessage *)message {
    NSUInteger msgId = [message msgid];
    NSPort *distantPort = nil;
    
    if (msgId == kCheckinMessage) {
        
#if kUseNSMachPort
        distantPort = [message sendPort];
        [self setDistancePort:distantPort];
#else
        distantPort = [NSMessagePortNameServer.sharedInstance portForName:kWorkThreadMessagePortName];
#endif
        
        NSData *data = [message components][0];
        
        NSString *msg = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"\n%@ received: %@", [NSThread currentThread] ,msg);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)TestAddRunLoopObserver {
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, myRunLoopObserverCallBack, &context);
    
    if (observer) {
        CFRunLoopRef cfRunLoop = [runLoop getCFRunLoop];
        CFRunLoopAddObserver(cfRunLoop, observer, kCFRunLoopDefaultMode);
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(doFireTimer:)
                                   userInfo:nil
                                    repeats:YES];
    NSInteger runLoopCount = 10;
    
    do {
        [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        --runLoopCount;
    }while(runLoopCount);
    
}

void myRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    NSLog(@"runLoop Observer callback, %@, %lu, %@", observer, activity, info);
}

- (void)doFireTimer:(NSTimer *)timer {
    NSLog(@"timer fired with %@", timer);
}




@end
