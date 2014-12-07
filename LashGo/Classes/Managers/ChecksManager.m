//
//  ChecksManager.m
//  LashGo
//
//  Created by Vitaliy Pykhtin on 11.08.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "ChecksManager.h"

#import "Kernel.h"
#import "DataProvider.h"
#import "ViewControllersManager.h"

#import "LGPhoto.h"

@interface ChecksManager () {
	Kernel __weak *_kernel;
	DataProvider __weak *_dataProvider;
	ViewControllersManager __weak *_viewControllersManager;
}

@end

@implementation ChecksManager

- (instancetype) initWithKernel: (Kernel *) kernel
				   dataProvider: (DataProvider *) dataProvider
					  vcManager: (ViewControllersManager *) vcManager {
	if (self = [super init]) {
		_kernel = kernel;
		_dataProvider = dataProvider;
		_viewControllersManager = vcManager;
	}
	return self;
}

#pragma mark -

- (void) addPhotoForCheck: (LGCheck *) check {
	[_dataProvider checkAddPhoto: check];
}

#pragma mark -

- (void) getPhotosForCheck: (LGCheck *) check {
	[_viewControllersManager.rootNavigationController addWaitViewControllerOfClass: [CheckPhotosViewController class]];
	[_dataProvider checkPhotosFor: check.uid];
}

- (void) getUsersForCheck: (LGCheck *) check {
	[_dataProvider checkUsersFor: check];
}

- (void) getVotePhotosForCheck: (LGCheck *) check {
	[_viewControllersManager.rootNavigationController addWaitViewControllerOfClass: [VoteViewController class]];
	[_dataProvider checkVotePhotosFor: check.uid];
}

- (void) stopWaitingVotePhotos {
	[_viewControllersManager.rootNavigationController removeWaitViewControllerOfClass: [VoteViewController class]];
}

- (void) voteWith: (LGVoteAction *) voteAction  {
	[_viewControllersManager.rootNavigationController addWaitViewControllerOfClass: [VoteViewController class]];
	[_dataProvider photoVote: voteAction];
}

- (void) openCheckCardViewController {
	[_viewControllersManager openCheckCardViewController];
	if ([_kernel.storage.checks count] <= 0) {
		[_dataProvider checks];
	}
}

- (void) openCheckCardViewControllerFor: (LGCheck *) check {
	NSUInteger index = [_kernel.storage.checks indexOfObject: check];
	if (index != NSNotFound) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow: index inSection: 0];
		_viewControllersManager.checkCardViewController.indexToShowOnAppear = indexPath;
	}
	[_viewControllersManager openCheckCardViewController];
	if ([_kernel.storage.checks count] <= 0) {
		[_dataProvider checks];
	}
}

- (void) openCheckCardViewControllerForCheckUID: (int64_t) checkUID {
	for (LGCheck *item in _kernel.storage.checks) {
		if (item.uid == checkUID) {
			[self openCheckCardViewControllerFor: item];
			return;
		}
	}
}

- (void) openCheckListViewController {
	[_viewControllersManager openCheckListViewController];
	if ([_kernel.storage.checks count] <= 0) {
		[_dataProvider checks];
	}
}

- (void) openCheckDetailViewControllerAdminFor: (LGCheck *) check {
	CheckDetailViewController *vc = _viewControllersManager.checkDetailViewController;
	vc.check = check;
	vc.mode = CheckDetailViewModeAdminPhoto;
	[_viewControllersManager openViewController: vc animated: YES];
}

- (void) openCheckDetailViewControllerUserFor: (LGCheck *) check {
	CheckDetailViewController *vc = _viewControllersManager.checkDetailViewController;
	vc.check = check;
	vc.mode = CheckDetailViewModeUserPhoto;
	[_viewControllersManager openViewController: vc animated: YES];
}

- (void) openCheckDetailViewControllerWinnerFor: (LGCheck *) check {
	CheckDetailViewController *vc = _viewControllersManager.checkDetailViewController;
	vc.check = check;
	vc.mode = CheckDetailViewModeWinnerPhoto;
	[_viewControllersManager openViewController: vc animated: YES];
}

- (void) openViewControllerFor: (LGPhoto *) photo {
	CheckDetailViewController *vc = _viewControllersManager.checkDetailViewController;
	vc.check = nil;
	vc.photo = photo;
	[_viewControllersManager openViewController: vc animated: YES];
}

- (void) openCheckPhotosViewControllerForCheck: (LGCheck *) check {
	CheckPhotosViewController *vc = _viewControllersManager.checkPhotosViewController;
	vc.check = check;
	[_viewControllersManager openViewController: vc animated: YES];
}

- (void) openCheckUsersViewControllerForCheck: (LGCheck *) check {
	SubscriptionViewController *vc = _viewControllersManager.subscriptionViewController;
	vc.context = check;
    vc.mode = SubscriptionViewControllerModeCheckUsers;
	[_viewControllersManager openViewController: vc animated: YES];
}

- (void) openVoteViewControllerForCheck: (LGCheck *) check {
	VoteViewController *voteViewController = _viewControllersManager.voteViewController;
	voteViewController.check = check;
	[_viewControllersManager openViewController: voteViewController animated: YES];
}

@end
