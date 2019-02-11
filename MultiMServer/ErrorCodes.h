//
//  ErrorCodes.h
//  MultiMServer
//
//  Created by Shavit Tzuriel on 2/11/19.
//  Copyright © 2019 demo. All rights reserved.
//

#ifndef ErrorCodes_h
#define ErrorCodes_h

typedef NS_ENUM(NSUInteger, ServerErrorCode) {
    NOERROR,
    SOCKETERROR,
    BINDERROR,
    LISTENERROR,
    SOCKETCREATERROR,
    ACCEPTINGERROR,
    
    CONNECTERROR,
    READERROR,
    WRITEERROR
};

#endif /* ErrorCodes_h */
