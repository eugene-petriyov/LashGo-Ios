//
//  JSONParser.m
//  LashGo
//
//  Created by Vitaliy Pykhtin on 24.05.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "JSONParser.h"

#import "Common.h"
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
			NSDictionary *parsedError = jsonDataObj[@"result"];
			
			if (parsedError != nil) {
				NSString *msg;
				
				msgCode = parsedError[@"msgCode"];
				code = [parsedError[@"code"] intValue];
				msg = parsedError[@"msg"];
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
				errorMsg = @{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode: code]};
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

- (NSArray *) parseChecks: (NSData *) jsonData {
	NSArray *rawData = [self parseJSONData: jsonData][@"resultCollection"];
	
	NSMutableArray *checks = [NSMutableArray array];
	
	for (NSDictionary *rawCheck in rawData) {
		LGCheck *check = [[LGCheck alloc] init];
		
		check.name =		rawCheck[@"name"];
		check.descr	=		rawCheck[@"description"];
		check.startDate =	rawCheck[@"startDate"];
		check.duration =	[rawCheck[@"duration"] intValue];
		check.photoUrl =	rawCheck[@"photoURL"];
		
		[checks addObject: check];
	}
	
	if ([checks count] <= 0) {
		checks = nil;
	}
	return checks;
}

@end
