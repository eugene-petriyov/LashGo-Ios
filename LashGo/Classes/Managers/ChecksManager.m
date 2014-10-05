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

- (void) getVotePhotosForCheck: (LGCheck *) check {
	[_viewControllersManager.rootNavigationController addWaitViewControllerOfClass: [VoteViewController class]];
	[_dataProvider checkVotePhotosFor: check.uid];
}

- (void) stopWaitingVotePhotos {
	[_viewControllersManager.rootNavigationController removeWaitViewControllerOfClass: [VoteViewController class]];
}

- (void) voteForPhoto: (LGPhoto *) photo {
	[_viewControllersManager.rootNavigationController addWaitViewControllerOfClass: [VoteViewController class]];
	[_dataProvider photoVoteFor: photo.uid];
}

- (void) openCheckCardViewController {
	[_viewControllersManager openCheckCardViewController];
	if ([_kernel.storage.checks count] <= 0) {
		[_dataProvider checks];
	}
}

- (void) openCheckListViewController {
	[_viewControllersManager openCheckListViewController];
	if ([_kernel.storage.checks count] <= 0) {
		[_dataProvider checks];
	}
}

- (void) openPhotoViewControllerForCheck: (LGCheck *) check {
	PhotoViewController *vc = _viewControllersManager.photoViewController;
	vc.check = check;
	vc.photoURL = check.taskPhotoUrl;
	[_viewControllersManager openViewController: vc animated: YES];
}

- (void) openVoteViewControllerForCheck: (LGCheck *) check {
	VoteViewController *voteViewController = _viewControllersManager.voteViewController;
	voteViewController.check = check;
	[_viewControllersManager openViewController: voteViewController animated: YES];
}

@end
