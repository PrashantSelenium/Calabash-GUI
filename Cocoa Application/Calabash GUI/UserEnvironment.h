//
//  UserEnvironment.h
//  Calabash GUI
//
//  Created by James Wegner on 7/23/13.
//  Copyright (c) 2013 James Wegner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserEnvironment : NSObject

@property (strong, nonatomic) NSTask* task;
@property (strong, nonatomic) NSString* pathVariable;

-(NSString*) getUserEnvironment;
-(void)notifiedForStdOutput:(NSNotification*)notification;
-(void)notifiedForStdError:(NSNotification*)notification;
-(void)notifiedForComplete:(NSNotification*)notification;

@end
