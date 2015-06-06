//
//  Storage.h
//  LashGo
//
//  Created by Vitaliy Pykhtin on 07.08.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "LGUser.h"
#import "LGVotePhotosResult.h"

@interface Storage : NSObject

@property (nonatomic, readonly) NSArray *checks;
@property (nonatomic, strong) NSArray *checksActions;
@property (nonatomic, strong) NSArray *checkPhotos;
@property (nonatomic, strong) LGVotePhotosResult *checkVotePhotos;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *news;
@property (nonatomic, strong) LGUser *lastViewProfileDetail;
@property (nonatomic, strong) NSArray *searchChecks;
@property (nonatomic, strong) NSArray *searchUsers;

- (void) updateChecksWith: (NSArray *) newValues;

@end
