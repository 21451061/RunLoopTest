//
//  MyWorkClass.h
//  RunLoopTest
//
//  Created by wtwo on 16/7/29.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCheckinMessage 100
#define kWorkThreadMessagePortName @"workThreadMessagePortName"
#define kMainThreadMessagePortName @"mainThreadMessagePortName"
#define kUseNSMachPort 1

@interface MyWorkClass : NSPort

+ (void)LaunchThreadWithPort:(nullable id)inData;

@end

@interface NSPortMessage : NSObject

NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithSendPort:(nullable NSPort *)sendPort receivePort:(nullable NSPort *)replyPort components:(nullable NSArray *)components NS_DESIGNATED_INITIALIZER;


@property (nullable, readonly, copy) NSArray *components;
@property (nullable, readonly, retain) NSPort *receivePort;
@property (nullable, readonly, retain) NSPort *sendPort;
- (BOOL)sendBeforeDate:(NSDate *)date;

@property uint32_t msgid;

NS_ASSUME_NONNULL_END

@end

@class NSString, NSPort;

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UNAVAILABLE("Use NSXPCConnection instead")
@interface NSPortNameServer : NSObject

+ (NSPortNameServer *)systemDefaultPortNameServer;

- (nullable NSPort *)portForName:(NSString *)name;
- (nullable NSPort *)portForName:(NSString *)name host:(nullable NSString *)host;

- (BOOL)registerPort:(NSPort *)port name:(NSString *)name;

- (BOOL)removePortForName:(NSString *)name;

@end

NS_SWIFT_UNAVAILABLE("Use NSXPCConnection instead")
@interface NSMessagePortNameServer : NSPortNameServer
// This port name server actually takes and
// returns instances of NSMessagePort

+ (id)sharedInstance;

- (nullable NSPort *)portForName:(NSString *)name;
- (nullable NSPort *)portForName:(NSString *)name host:(nullable NSString *)host;
// this name server is a local-only server;
// host parameter must be emptry string or nil

// removePortForName: functionality is not supported in
// this name server; if you want to cancel a service,
// you have to destroy the port (invalidate the
// NSMessagePort given to registerPort:name:).

NS_ASSUME_NONNULL_END

@end