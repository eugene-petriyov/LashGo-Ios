//
//  ChecksManager.h
//  LashGo
//
//  Created by Vitaliy Pykhtin on 11.08.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

@class Kernel;
@class DataProvider;
@class ViewControllersManager;

@class LGCheck;
@class LGCommentAction;
@class LGPhoto;
@class LGVoteAction;

@interface ChecksManager : NSObject

- (instancetype) initWithKernel: (Kernel *) kernel
				   dataProvider: (DataProvider *) dataProvider
					  vcManager: (ViewControllersManager *) vcManager;

- (void) getChecks;
//- (void) getChecksActions;
- (void) getChecksSearch: (NSString *) searchText;

- (void) getCommentsForPhoto: (LGPhoto *) photo;

- (void) addPhotoForCheck: (LGCheck *) check;

- (void) getPhotosForCheck: (LGCheck *) check;
- (void) getPhotoCountersForPhoto: (LGPhoto *) photo;
- (void) getPhotoVotesForPhoto: (LGPhoto *) photo;
- (void) getUsersForCheck: (LGCheck *) check;
- (void) getVotePhotosForCheck: (LGCheck *) check;
- (void) stopWaitingVotePhotos;

- (void) sendCommentWith: (LGCommentAction *) commentAction;
- (void) removeCommentWith: (LGCommentAction *) commentAction;
- (void) voteWith: (LGVoteAction *) voteAction;

- (void) openCheckCardViewController;
- (void) openCheckCardViewControllerWith: (LGCheck *) check;
///YES - check opened, NO - check not found
- (BOOL) openCheckCardViewControllerForCheckUID: (int64_t) checkUID;
- (void) openCheckCardViewControllerWithFetchForCheckUID: (int64_t) checkUID;
- (void) openCheckListViewController;
- (void) openCheckActionCardViewControllerWith: (LGCheck *) check;
- (void) openCheckActionListViewController;
- (void) openCheckActionWinnerViewControllerWith: (LGCheck *) check;

- (void) openCheckDetailViewControllerAdminFor: (LGCheck *) check;
- (void) openCheckDetailViewControllerUserFor: (LGCheck *) check;
- (void) openCheckDetailViewControllerWinnerFor: (LGCheck *) check;
- (void) openViewControllerFor: (LGPhoto *) photo;

- (void) openCheckPhotosViewControllerForCheck: (LGCheck *) check;
- (void) openCheckUsersViewControllerForCheck: (LGCheck *) check;
- (void) openVoteViewControllerForCheck: (LGCheck *) check;

- (void) openPhotoCommentsViewControllerFor: (LGPhoto *) photo;
- (void) openPhotoVotesViewControllerFor: (LGPhoto *) photo;

@end
