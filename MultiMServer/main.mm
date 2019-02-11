//
//  main.m
//  MultiMServer
//
//  Created by Shavit Tzuriel on 2/11/19.
//  Copyright © 2019 demo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MediaServer *server = [[MediaServer alloc] initOnPort:1930 serverType:SERVERTYPEDATA];
        NSLog(@"Starting the server");
    }
    return 0;
}
