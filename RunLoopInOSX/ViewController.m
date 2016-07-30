//
//  ViewController.m
//  RunLoopInOSX
//
//  Created by wtwo on 16/7/29.
//  Copyright © 2016年 wtwo. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    mySpawnThread();
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#define kThreadStackSize (8 * 4096)

OSStatus ServerThreadEntryPoint(void* param);
CFDataRef MainThreadResponseHandler(CFMessagePortRef local,
                                    SInt32 msgid,
                                    CFDataRef data,
                                    void* info);

OSStatus mySpawnThread() {
    CFStringRef myPortName;
    CFMessagePortRef myPort;
    CFRunLoopSourceRef rlSource;
    CFMessagePortContext context = {0, NULL, NULL, NULL, NULL};
    Boolean shouldFreeInfo;
    
    myPortName = CFStringCreateWithFormat(NULL, NULL, CFSTR("com.myapp.MainThread"));
    
    myPort = CFMessagePortCreateLocal(NULL, myPortName, &MainThreadResponseHandler, &context, &shouldFreeInfo);
    if (myPort) {
        rlSource = CFMessagePortCreateRunLoopSource(NULL, myPort, 0);
        if (rlSource) {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), rlSource, kCFRunLoopDefaultMode);
            CFRelease(myPort);
            CFRelease(rlSource);
        }
    }
    
    MPTaskID taskID;
    OSStatus status = MPCreateTask(&ServerThreadEntryPoint, (void*)myPortName, kThreadStackSize, NULL, NULL, NULL, 0, &taskID);
    return status;
}

#define kCheckInMessage 100
CFDataRef MainThreadResponseHandler(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info) {
    if (msgid == kCheckInMessage) {
        CFMessagePortRef messagePort;
        CFStringRef threadPortName;
        CFIndex bufferLength = CFDataGetLength(data);
        UInt8 *buffer = CFAllocatorAllocate(NULL, bufferLength, 0);
        CFDataGetBytes(data, CFRangeMake(0, bufferLength), buffer);
        printf("Received: %s", buffer);
        threadPortName = CFStringCreateWithBytes(NULL, buffer, bufferLength, kCFStringEncodingASCII, FALSE);
        messagePort = CFMessagePortCreateRemote(NULL, (CFStringRef)threadPortName);
        
        if (messagePort) {
//            AddPortToListOfActiveThreads(messagePort);
            CFRelease(messagePort);
        }
        CFRelease(threadPortName);
        CFAllocatorDeallocate(NULL, buffer);
    }
    return NULL;
}

OSStatus ServerThreadEntryPoint(void* param) {
    CFStringRef portName = (CFStringRef)param;
    CFMessagePortRef mainThreadPort = CFMessagePortCreateRemote(NULL, portName);
    CFRelease(portName);
    
    CFStringRef myPortName = CFStringCreateWithFormat(NULL, NULL, CFSTR("com.MyApp.thread - %d"), MPCurrentTaskID());
    
    CFMessagePortContext context = {0, mainThreadPort, NULL, NULL, NULL};
    Boolean shouldFreeInfo;
    CFMessagePortRef myPort = CFMessagePortCreateLocal(NULL, myPortName, NULL, &context, &shouldFreeInfo);
    if (shouldFreeInfo) {
        MPExit(0);
    }
    CFRunLoopSourceRef rlSource = CFMessagePortCreateRunLoopSource(NULL, myPort, 0);
    if (!rlSource) {
        MPExit(0);
    }
    CFRunLoopAddSource(CFRunLoopGetCurrent(), rlSource, kCFRunLoopDefaultMode);
    CFRelease(myPort);
    CFRelease(rlSource);
    
    CFIndex bufferLength = CFStringGetLength(myPortName);
    UInt8 *buffer = CFAllocatorAllocate(NULL, bufferLength, 0);
    CFStringGetBytes(myPortName, CFRangeMake(0, bufferLength), kCFStringEncodingASCII, 0, FALSE, buffer, bufferLength, NULL);
    CFDataRef outData = CFDataCreate(NULL, buffer, bufferLength);
    CFMessagePortSendRequest(mainThreadPort, kCheckInMessage, outData, 0.1, 0.0, NULL, NULL);
    CFRelease(outData);
    CFAllocatorDeallocate(NULL, buffer);
    CFRunLoopRun();
    return NULL;
}

@end
