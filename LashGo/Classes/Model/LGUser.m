//
//  LGUser.m
//  LashGo
//
//  Created by Vitaliy Pykhtin on 24.05.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "LGUser.h"

#import "Common.h"

@implementation LGUser

- (NSString *) fio {
	if (_fio == nil) {
		return _login;
	}
	return _fio;
}

#pragma mark JSONSerializableProtocol implementation

- (NSDictionary *) JSONObject {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								   @(_uid), @"id",
								   _login, @"login", nil];
	if ([Common isEmptyString: _fio] == NO) {
		result[@"fio"] = _fio;
	}
	if ([Common isEmptyString: _about] == NO) {
		result[@"about"] = _about;
	}
	if ([Common isEmptyString: _city] == NO) {
		result[@"city"] = _city;
	}
	if ([Common isEmptyString: _email] == NO) {
		result[@"email"] = _email;
	}
	return result;
}

#pragma mark - NSCoding protocol implementation

-(void) encodeWithCoder: (NSCoder*) coder {
	[coder encodeInt32: self.uid forKey: @"uid"];
	[coder encodeObject: self.login forKey: @"login"];
	[coder encodeObject: self.fio forKey: @"fio"];
	[coder encodeObject: self.about forKey: @"about"];
	[coder encodeObject: self.city forKey: @"city"];
	//date NSDate
	[coder encodeObject: self.avatar forKey: @"avatar"];
	[coder encodeObject: self.email forKey: @"email"];
	
	[coder encodeInt32: self.userSubscribes forKey: @"userSubscribes"];
	[coder encodeInt32: self.userSubscribers forKey: @"userSubscribers"];
	[coder encodeInt32: self.checksCount forKey: @"checksCount"];
	[coder encodeInt32: self.commentsCount forKey: @"commentsCount"];
	[coder encodeInt32: self.likesCount forKey: @"likesCount"];
	
	[coder encodeObject: _newsLastViewDate forKey: NSStringFromSelector(@selector(newsLastViewDate))];
	[coder encodeObject: _subscriptionsLastViewDate forKey: NSStringFromSelector(@selector(subscriptionsLastViewDate))];
}

-(id) initWithCoder: (NSCoder*) coder {
	if (self = [super init]) {
		self.uid =			[coder decodeInt32ForKey: @"uid"];
		self.login =		[coder decodeObjectForKey: @"login"];
		self.fio =			[coder decodeObjectForKey: @"fio"];
		self.about =		[coder decodeObjectForKey: @"about"];
		self.city =			[coder decodeObjectForKey: @"city"];
		//date
		self.avatar =		[coder decodeObjectForKey: @"avatar"];
		self.email =		[coder decodeObjectForKey: @"email"];
		
		self.userSubscribes =	[coder decodeInt32ForKey: @"userSubscribes"];
		self.userSubscribers =	[coder decodeInt32ForKey: @"userSubscribers"];
		self.checksCount =		[coder decodeInt32ForKey: @"checksCount"];
		self.commentsCount =	[coder decodeInt32ForKey: @"commentsCount"];
		self.likesCount =		[coder decodeInt32ForKey: @"likesCount"];
		
		self.newsLastViewDate =	[coder decodeObjectOfClass: [NSDate class]
													forKey: NSStringFromSelector(@selector(newsLastViewDate))];
		self.subscriptionsLastViewDate = [coder decodeObjectOfClass: [NSDate class]
															 forKey: NSStringFromSelector(@selector(subscriptionsLastViewDate))];
	}
	return self;
}

@end
