//
//  Server.h
//  MultiMServer
//
//  Created by Shavit Tzuriel on 2/11/19.
//  Copyright © 2019 demo. All rights reserved.
//

#ifndef Server_h
#define Server_h

#import <Foundation/Foundation.h>
#import "ErrorCodes.h"

typedef NS_ENUM(NSUInteger, ServerType) {
    SERVERTYPESTRING,
    SERVERTYPEDATA
};

#define NOTIFICATIONSTRING @"receivedmessage"
#define NOTIFICATIONDATA @"receiveddata"

@interface MediaServer : NSObject

@property (nonatomic) CFSocketRef sRef;

@property (nonatomic) int listenfd, errorCode;

- (instancetype) initOnPort: (int)port serverType:(int)serverType;

@end


#endif /* Server_h */
