//
//  Server.m
//  MultiMServer
//
//  Created by Shavit Tzuriel on 2/11/19.
//  Copyright © 2019 demo. All rights reserved.
//

#import "Server.h"
#import <CoreFoundation/CFSocket.h>
#import <sys//socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define LISTENQ 1024

@implementation MediaServer

- (instancetype)initOnPort:(int)port serverType:(int)serverType {
    struct sockaddr_in servaddr;
    CFRunLoopSourceRef source;
    
    const CFSocketContext context = {0, NULL, NULL, NULL, NULL};
    self.errorCode = NOERROR;
    
    // 1. Create a socket
    if ((self.listenfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0) {
        self.errorCode = SOCKETERROR;
    } else {
        memset(&servaddr, 0, sizeof(servaddr));
        servaddr.sin_family = AF_INET;
        servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
        servaddr.sin_port = htons(port);
        
        // 2. Bind
        if (bind(self.listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) {
            self.errorCode = BINDERROR;
        } else {
            
            // 3. Listen
            if (listen(self.listenfd, LISTENQ) < 0) {
                self.errorCode = LISTENERROR;
            } else {
                
                // 4. Accept
                if (serverType == SERVERTYPESTRING) {
                    self.sRef = CFSocketCreateWithNative(NULL, self.listenfd, kCFSocketAcceptCallBack, acceptConnectionString, &context);
                } else if (serverType == SERVERTYPEDATA) {
                    self.sRef = CFSocketCreateWithNative(NULL, self.listenfd, kCFSocketAcceptCallBack, acceptConnectionData, &context);
                } else {
                    self.sRef = NULL;
                }
                
                if (self.sRef == NULL) {
                    self.errorCode = SOCKETCREATERROR;
                } else {
                    NSLog(@"Server started on port %d", port);
                    source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self.sRef, 0);
                    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
                    CFRelease(source);
                    CFRunLoopRun();
                }
            }
        }
    }
    
    return self;
}

void acceptConnectionString(CFSocketRef sRef, CFSocketCallBackType cType, CFDataRef address, const void *data, void *info) {
    CFSocketNativeHandle csock = *(CFSocketNativeHandle *)data;
    CFSocketRef sn;
    CFRunLoopSourceRef source;
    
    const CFSocketContext context = {0, NULL, NULL, NULL, NULL};
    sn = CFSocketCreateWithNative(NULL, csock, kCFSocketDataCallBack, receiveData, &context);
    source = CFSocketCreateRunLoopSource(NULL, sn, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
    CFRelease(sn);
}

void receiveData(CFSocketRef sRef, CFSocketCallBackType cType, CFDataRef address, const void *data, void *info) {
    CFDataRef df = (CFDataRef) data;
    long len = CFDataGetLength(df);
    
    if (len <= 0) {
        return;
    }
    
    UInt8 buf[len];
    CFRange range = CFRangeMake(0, len);
    CFDataGetBytes(df, range, buf);
    buf[len] = '\0';
    NSString *str = [[NSString alloc] initWithData:(__bridge NSData *)data encoding:NSASCIIStringEncoding];
    
    // TODO: Change to binary
    NSLog(@"Received %@", str);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedmessage" object:str];
    CFSocketSendData(sRef, address, df, 0);
}

void acceptConnectionData(CFSocketRef sRef, CFSocketCallBackType cType, CFDataRef address, const void *data, void *info) {
    CFSocketNativeHandle csock = *(CFSocketNativeHandle *)data;
    CFSocketRef sn;
    CFRunLoopSourceRef source;
    const CFSocketContext context = {0, NULL, NULL, NULL, NULL};
    sn = CFSocketCreateWithNative(NULL, csock, kCFSocketDataCallBack, receiveDataBinary, &context);
    
    source = CFSocketCreateRunLoopSource(NULL, sn, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
    CFRelease(sn);
}

void receiveDataBinary(CFSocketRef sRef, CFSocketCallBackType cType, CFDataRef address, const void *data, void *info) {
    CFDataRef df = (CFDataRef) data;
    NSData *mediaData = (__bridge NSData *)df;
    struct sockaddr_in addr = *(struct sockaddr_in *)CFDataGetBytePtr(address);
    char buf[INET6_ADDRSTRLEN];
    NSString *connStr = [NSString stringWithFormat:@"Connection:  %s | Port: %d", inet_ntop(AF_INET, &addr.sin_addr, buf ,sizeof(buf)), ntohs(addr.sin_port)];
    NSLog(@"%@", connStr);
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONDATA object:mediaData];
}

@end
