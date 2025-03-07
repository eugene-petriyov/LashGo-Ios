//
//  JSONParser.m
//  LashGo
//
//  Created by Vitaliy Pykhtin on 24.05.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "JSONParser.h"

#import "Common.h"
#import "NSDateFormatter+CustomFormats.h"
#import "URLConnection.h"

@implementation JSONParser

#define SHOW_RECEIVED_JSON

- (id) parseJSONData: (NSData *) jsonData {
	NSError *error = nil;
	
#if defined SHOW_RECEIVED_JSON && defined DEBUG
	NSString *jsonString = [NSString stringWithData: jsonData];
	DLog(@"%@", jsonString);
#endif
	
	id jsonObj = [NSJSONSerialization JSONObjectWithData: jsonData options: 0 error: &error];
	if (error != nil) {
		DLog(@"JSON parsing error: %@", error.description);
	}
	return jsonObj;
}

- (NSError *) parseError: (URLConnection *) connection {
	NSError *error = connection.error;
	if (error == nil) {
		NSString *msgCode;
		int code;
		NSDictionary *errorMsg;
		
		@try {
			NSDictionary *jsonDataObj = [self parseJSONData: connection.downloadedData];
			NSDictionary *parsedError = jsonDataObj[@"error"];
			
			if (parsedError != nil) {
				NSString *msg;
				
				msgCode = parsedError[@"errorCode"];
				code = (int)connection.response.statusCode;
				msg = msgCode.commonLocalizedString;
				if ([msgCode isEqualToString: msg] == YES) {
					msg = @"ErrorServerErrorParsingMessage".commonLocalizedString;
				}
#ifdef DEBUG
				NSArray *parsedData = jsonDataObj[@"data"][@"fields"];
				NSMutableString *debugString = [NSMutableString string];
				for (NSDictionary *field in parsedData) {
					[debugString appendFormat: @"\n %@ -> %@", field[@"name"], field[@"msg"]];
				}
				msg = [msg stringByAppendingFormat: @"\n<DEBUG: %@>", debugString];
#endif
				errorMsg = @{NSLocalizedDescriptionKey: msg};
			} else {
				msgCode = @"ErrorServerErrorParsingTitle".commonLocalizedString;
				code = (int)connection.response.statusCode;
				errorMsg = @{NSLocalizedDescriptionKey: @"ErrorServerErrorParsingMessage".commonLocalizedString};
			}
		}
		@catch (NSException *exception) {
			msgCode = @"ErrorServerErrorParsingTitle".commonLocalizedString;
			code = 400;
			errorMsg = @{NSLocalizedDescriptionKey: @"ErrorServerErrorParsingMessage".commonLocalizedString};
		}
		@finally {
			error = [NSError errorWithDomain: msgCode
										code: code
									userInfo: errorMsg];
		}
	}
	//	DLog(@"Error for connection: %@", error.description);
	return error;
}

#pragma mark -

- (NSArray *) parseEvents: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	
	NSMutableArray *events = [NSMutableArray array];
	
	for (NSDictionary *rawEvent in rawData) {
		LGEvent *event = [[LGEvent alloc] init];
		
		event.uid =		[rawEvent[@"id"] longLongValue];
		event.action =	rawEvent[@"action"];
		
		NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFullDateFormat];
		
		NSString *str =		rawEvent[@"eventDate"];
		event.eventDate =	[dateFormatter dateFromString: str];
		event.check =		[self parseCheck: rawEvent[@"check"]];
		event.user =		[self parseUser: rawEvent[@"user"]];
		
		[events addObject: event];
	}
	
	if ([events count] <= 0) {
		events = nil;
	}
	return  events;
}

- (LGCheck *) parseCheck: (NSDictionary *) jsonDataObj {
	LGCheck *check = nil;
	
	if ([jsonDataObj count] > 0) {
		NSDictionary *rawCheck = jsonDataObj;
		
		check = [[LGCheck alloc] init];
		
		check.uid =			[rawCheck[@"id"] longLongValue];
		check.name =		rawCheck[@"name"];
		check.descr	=		rawCheck[@"description"];
		
		NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFullDateFormat];
		
		NSString *str =		rawCheck[@"startDate"];
		check.startDate =	[[dateFormatter dateFromString: str] timeIntervalSinceReferenceDate];
		
		short durationSectionSeconds = 3600;
		
		check.duration =	[rawCheck[@"duration"] intValue] * durationSectionSeconds;
		check.voteDuration = [rawCheck[@"voteDuration"] intValue] * durationSectionSeconds;
		
		NSString *rawType = rawCheck[@"checkType"];
		if ([rawType isEqualToString: kCheckTypeAction] == YES) {
			check.type = CheckTypeAction;
		}
		
		check.voteDate =	check.startDate + check.duration;
		check.closeDate =	check.voteDate + check.voteDuration;
		
		check.taskPhotoUrl =	rawCheck[@"taskPhotoUrl"];
		
		LGCheckCounters *counters = [[LGCheckCounters alloc] init];
		counters.playersCount =	[rawCheck[@"playersCount"] intValue];
		
		check.counters = counters;
		
		check.userPhoto =	[self parsePhoto: rawCheck[@"userPhotoDto"]];
		check.winnerPhoto =	[self parsePhoto: rawCheck[@"winnerPhotoDto"]];
		check.winnerPhoto.user = [self parseUser: rawCheck[@"winnerInfo"]];
	}
	return check;
}

- (LGCheck *) parseCheckData: (NSData *) jsonData {
	NSDictionary *rawData = [self parseJSONData: jsonData][@"result"];
	LGCheck *check = [self parseCheck: rawData];
	return check;
}

- (NSArray *) parseChecks: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	
	NSMutableArray *checks = [NSMutableArray array];
	
	for (NSDictionary *rawCheck in rawData) {
		LGCheck *check = [[LGCheck alloc] init];
		
		check.uid =			[rawCheck[@"id"] longLongValue];
		check.name =		rawCheck[@"name"];
		check.descr	=		rawCheck[@"description"];
		
		NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFullDateFormat];
		
		NSString *str =		rawCheck[@"startDate"];
		check.startDate =	[[dateFormatter dateFromString: str] timeIntervalSinceReferenceDate];
		
		short durationSectionSeconds = 3600;
		
		check.duration =	[rawCheck[@"duration"] intValue] * durationSectionSeconds;
		check.voteDuration = [rawCheck[@"voteDuration"] intValue] * durationSectionSeconds;
		
		NSString *rawType = rawCheck[@"checkType"];
		if ([rawType isEqualToString: kCheckTypeAction] == YES) {
			check.type = CheckTypeAction;
		}
		
		check.voteDate =	check.startDate + check.duration;
		check.closeDate =	check.voteDate + check.voteDuration;
		
		check.taskPhotoUrl =	rawCheck[@"taskPhotoUrl"];
		
		LGCheckCounters *counters = [[LGCheckCounters alloc] init];
		counters.playersCount =	[rawCheck[@"playersCount"] intValue];
		
		check.counters = counters;
		
		check.userPhoto =	[self parsePhoto: rawCheck[@"userPhotoDto"]];
		check.winnerPhoto =	[self parsePhoto: rawCheck[@"winnerPhotoDto"]];
		check.winnerPhoto.user = [self parseUser: rawCheck[@"winnerInfo"]];
		
		[checks addObject: check];
	}
	
	if ([checks count] <= 0) {
		checks = nil;
	}
	return checks;
}

- (NSArray *) parsePhotos: (NSArray *) jsonDataObj {
	NSMutableArray *photos = [NSMutableArray array];
	
	for (NSDictionary *rawPhoto in jsonDataObj) {
		LGPhoto *photo = [self parsePhoto: rawPhoto];
		if (photo != nil) {
			[photos addObject: photo];
		}
	}
	
	if ([photos count] <= 0) {
		photos = nil;
	}
	return photos;
}

- (NSArray *) parseCheckPhotos: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	NSArray *checkPhotos = [self parsePhotos: rawData];
	return  checkPhotos;
}

- (NSArray *) parseComments: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	
	NSMutableArray *comments = [NSMutableArray array];
	
	for (NSDictionary *rawComment in rawData) {
		LGComment *comment = [[LGComment alloc] init];
		
		comment.uid =			[rawComment[@"id"] longLongValue];
		comment.content =		rawComment[@"content"];
		
		NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFullDateFormat];
		
		NSString *str =			rawComment[@"createDate"];
		comment.createDate =	[dateFormatter dateFromString: str];
		comment.user =			[self parseUser: rawComment[@"user"]];
		
		[comments addObject: comment];
	}
	
	if ([comments count] <= 0) {
		comments = nil;
	}
	return  comments;
}

- (LGCounters *) parseCounters: (NSData *) jsonData {
	NSDictionary *rawData = [self parseJSONData: jsonData][@"result"];
	
	LGCounters *counters = nil;
	
	if ([rawData.allKeys count] > 0) {
		counters = [[LGCounters alloc] init];
		
		counters.commentsCount =	[rawData[@"commentsCount"] intValue];
		counters.likesCount =		[rawData[@"likesCount"] intValue];
	}
	
	return counters;
}

- (NSArray *) parseSubscriptions: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	NSMutableArray *users = [NSMutableArray array];
	
	for (NSDictionary *rawSubscription in rawData) {
		LGSubscription *subscription = [self parseSubscription: rawSubscription];
		if (subscription != nil) {
			[users addObject: subscription];
		}
	}
	
	if ([users count] <= 0) {
		users = nil;
	}
	return users;
}

- (LGVotePhotosResult *) parseCheckVotePhotos: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	
	LGVotePhotosResult *result = nil;
//	result.photosCount = [rawData[@"photosCount"] intValue];
	NSMutableArray *votePhotos = [[NSMutableArray alloc] init];
	
	for (NSDictionary *rawVotePhoto in rawData) {
		LGPhoto *photo = [self parsePhoto: rawVotePhoto[@"photoDto"]];
		if (photo != nil) {
			LGVotePhoto *votePhoto = [[LGVotePhoto alloc] init];
			votePhoto.photo =	photo;
			votePhoto.isShown =	[rawVotePhoto[@"shown"] boolValue];
			votePhoto.isVoted =	[rawVotePhoto[@"voted"] boolValue];
			[votePhotos addObject: votePhoto];
		}
	}
	
	if ([votePhotos count] > 0) {
		result = [[LGVotePhotosResult alloc] init];
		result.votePhotos = votePhotos;
	}
	
	return result;
}

- (LGPhoto *) parsePhoto: (NSDictionary *) jsonDataObj {
	LGPhoto *photo = nil;
	
	if ([jsonDataObj count] > 0) {
		NSDictionary *rawPhoto = jsonDataObj;
		
		photo = [[LGPhoto alloc] init];
		
		photo.uid =	[rawPhoto[@"id"] longLongValue];
		photo.url =	rawPhoto[@"url"];
		photo.user = [self parseUser: rawPhoto[@"user"]];
		photo.check = [self parseCheck: rawPhoto[@"check"]];
		
		photo.isBanned = [rawPhoto[@"banned"] boolValue];
		photo.isWinner = [rawPhoto[@"winner"] boolValue];
	}
	return photo;
}

- (LGSessionInfo *) parseSessionInfo: (NSDictionary *) jsonDataObj {
	LGSessionInfo *sessionInfo = nil;
	
	if ([jsonDataObj.allKeys count] > 0) {
		sessionInfo = [[LGSessionInfo alloc] init];
		
		sessionInfo.uid =		jsonDataObj[@"sessionId"];
		sessionInfo.userUID =	[jsonDataObj[@"userId"] intValue];
	}
	return sessionInfo;
}

- (LGMainScreenInfo *) parseMainScreenInfo: (NSData *) jsonData {
	NSDictionary *rawData = [self parseJSONData: jsonData][@"result"];
	
	LGMainScreenInfo *mainScreenInfo = [[LGMainScreenInfo alloc] init];
	
	mainScreenInfo.tasksCount		= [rawData[@"tasksCount"] intValue];
	mainScreenInfo.newsCount		= [rawData[@"newsCount"] intValue];
	mainScreenInfo.subscribesCount	= [rawData[@"subscribesCount"] intValue];
	mainScreenInfo.actionCount		= [rawData[@"actionCount"] intValue];
	
#ifdef USE_PREFETCHED_DATA
	mainScreenInfo.tasksCount		= 125;
	mainScreenInfo.newsCount		= 3;
	mainScreenInfo.subscribesCount	= 7;
	mainScreenInfo.actionCount		= 2;
#endif
	
	return mainScreenInfo;
}

- (LGRegisterInfo *) parseLoginInfo: (NSData *) jsonData {
	NSDictionary *rawData = [self parseJSONData: jsonData][@"result"];
	
	LGSessionInfo *sessionInfo = [self parseSessionInfo: rawData];
	
	LGUser *user = [[LGUser alloc] init];
	user.uid = sessionInfo.userUID;
	
	LGRegisterInfo *registerInfo = [[LGRegisterInfo alloc] init];
	registerInfo.user =			user;
	registerInfo.sessionInfo =	sessionInfo;
	
	return registerInfo;
}

- (LGRegisterInfo *) parseRegisterInfo: (NSData *) jsonData {
	NSDictionary *rawData = [self parseJSONData: jsonData][@"result"];
	
	LGRegisterInfo *registerInfo = [[LGRegisterInfo alloc] init];
	
	LGUser *user =					[self parseUser: rawData[@"userDto"]];
	LGSessionInfo *sessionInfo =	[self parseSessionInfo: rawData[@"sessionInfo"]];
	
	if (user == nil) {
		user = [[LGUser alloc] init];
		user.uid = sessionInfo.userUID;
	}
	
	registerInfo.user =			user;
	registerInfo.sessionInfo =	sessionInfo;
	
	return registerInfo;
}

- (LGSubscription *) parseSubscription: (NSDictionary *) jsonDataObj {
	LGSubscription *subscription = nil;
	
	if ([jsonDataObj count] > 0) {
		NSDictionary *rawSubscription = jsonDataObj;
		
		LGUser *user = [[LGUser alloc] init];
		
		user.uid =		[rawSubscription[@"userId"] intValue];
		user.avatar =	rawSubscription[@"userAvatar"];
		user.login =	rawSubscription[@"userLogin"];
		user.fio =		rawSubscription[@"fio"];
		
		subscription = [[LGSubscription alloc] init];
		
		subscription.uid =			[rawSubscription[@"id"] intValue];
		subscription.user =			user;
		
		id subscriptionFlag = rawSubscription[@"amISubscribed"];
		if (subscriptionFlag == nil) {
			subscription.isSubscribed = YES;
		} else {
			subscription.isSubscribed =	[subscriptionFlag boolValue];
		}
	}
	return subscription;
}

- (LGUser *) parseUser: (NSDictionary *) jsonDataObj {
	LGUser *user = nil;
	
	if ([jsonDataObj count] > 0) {
		NSDictionary *rawUser = jsonDataObj;
		
		user = [[LGUser alloc] init];
		
		user.uid =		[rawUser[@"id"] intValue];
		user.fio =		rawUser[@"fio"];
		user.login =	rawUser[@"login"];
		user.about =	rawUser[@"about"];
		user.city =		rawUser[@"city"];
//		user.birthDate;
		user.avatar =	rawUser[@"avatar"];
		user.email =	rawUser[@"email"];
		
		user.userSubscribes =	[rawUser[@"userSubscribes"] intValue];
		user.userSubscribers =	[rawUser[@"userSubscribers"] intValue];
		user.checksCount =		[rawUser[@"checksCount"] intValue];
		user.commentsCount =	[rawUser[@"commentsCount"] intValue];
		user.likesCount =		[rawUser[@"likesCount"] intValue];
		
		user.subscription =		[rawUser[@"subscription"] boolValue];
	}
	return user;
}

- (NSArray *) parseUserPhotos: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	
	NSMutableArray *userPhotos = [NSMutableArray array];
	
	for (NSDictionary *rawPhoto in rawData) {
		LGPhoto *photo = [self parsePhoto: rawPhoto];
		if (photo != nil) {
			[userPhotos addObject: photo];
		}
	}
	
	if ([userPhotos count] <= 0) {
		userPhotos = nil;
	}
	return userPhotos;
}

- (LGUser *) parseUserProfile: (NSData *) jsonData {
	NSDictionary *rawData = [self parseJSONData: jsonData][@"result"];
	LGUser *user = [self parseUser: rawData];
	return user;
}

@end
