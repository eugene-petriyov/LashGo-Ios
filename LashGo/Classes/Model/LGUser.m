//
//  LGUser.m
//  LashGo
//
//  Created by Vitaliy Pykhtin on 24.05.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "LGUser.h"

@implementation LGUser

@synthesize uid, login, fio, about, city, birthDate, avatar, email;

- (NSString *) fio {
	if (fio == nil) {
		return login;
	}
	return fio;
}

@end
