//
//  MyWorkClass.m
//  RunLoopTest
//
//  Created by wtwo on 16/7/29.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import "MyWorkClass.h"

@interface MyWorkClass ()<NSPortDelegate>

@property (nonatomic, strong) NSPort *remotePort;
@property (nonatomic, assign) BOOL shouldExit;

@end

@implementation MyWorkClass

+ (void)LaunchThreadWithPort:(id)inData {
#if kUseNSMachPort
    NSPort *distantPort = (NSMachPort *)inData;
#else
    NSPort *distantPort = [NSMessagePortNameServer.sharedInstance portForName:kMainThreadMessagePortName];
#endif
    
    MyWorkClass *workObj = [MyWorkClass new];
    [workObj sendCheckInMessage:distantPort];
    
    do {
        //run runLoop,等待port-based source的到来
        [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:NSDate.distantFuture];
    }while(![workObj shouldExit]);
    
}

- (instancetype)init {
    self = [super init];
    if (!self) return self;
    _shouldExit = NO;
    return self;
}

- (void)sendCheckInMessage:(NSPort *)outPort {
    
    [NSThread.currentThread setName:@"Work Thread"];
    
#if kUseNSMachPort
    [self setRemotePort:outPort];
    NSPort *myPort = [NSMachPort port];
#else
    NSPort *myPort = [NSMessagePort new];
    [NSMessagePortNameServer.sharedInstance registerPort:myPort name:kWorkThreadMessagePortName];
#endif
    [myPort setDelegate:self];
    //将port加入runloop，监听发送到这个port的消息
    [NSRunLoop.currentRunLoop addPort:myPort forMode:NSDefaultRunLoopMode];
    
    //构造消息
    NSString *msg = [NSString stringWithFormat:@"from %@: %s", [NSThread currentThread] , __func__];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    NSPortMessage *messageObj = [[NSPortMessage alloc] initWithSendPort:outPort
                                                            receivePort:myPort components:@[data]];
    
    if (messageObj) {
        [messageObj setMsgid:kCheckinMessage];
        [messageObj sendBeforeDate:NSDate.date];
    }
}

#pragma mark - NSPortMessageDelegate
//处理从Main thread发送来的port消息
- (void)handlePortMessage:(NSPortMessage *)message {
    NSUInteger msgId = [message msgid];
    
    if (msgId == kCheckinMessage) {
        NSData *data = [message components][0];
        NSString *msg = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"\n%@ received: %@", [NSThread currentThread] ,msg);
        _shouldExit = YES;
    }
}


@end
