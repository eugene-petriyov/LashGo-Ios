//
//  NSMutableURLRequest+ParamsManipulation.h
//  LashGo
//
//  Created by Vitaliy Pykhtin on 19.04.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

typedef enum {
	URLConnectionTypeGET = 0,
	URLConnectionTypePOST = 1,
	URLConnectionTypePUT = 2,
	URLConnectionTypeDELETE
} URLConnectionType;

@interface NSMutableURLRequest (ParamsManipulation)

+ (NSMutableURLRequest *) requestWithURL: (NSString *) url
									type: (URLConnectionType) theType
							   getParams: (NSDictionary *) getParams
							  postParams: (NSDictionary *) postParams
							headerParams: (NSDictionary *) headerParams;

- (void) addValue: (NSString *) value forQueryParameter: (NSString *) name;

@end
