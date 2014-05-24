//
//  NetworkDownloadManager.m
//  DevLib
//
//  Created by Vitaliy Pykhtin on 27.02.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "NetworkDownloadManager.h"

static NetworkDownloadManager *networkDownloadManager;

@implementation NetworkDownloadManager

+ (NetworkDownloadManager *) sharedManager {
	if (networkDownloadManager == nil) {
		networkDownloadManager = [ [NetworkDownloadManager alloc] init];
	}
	return networkDownloadManager;
}

- (id) init {
	if (self = [super init]) {
		delegatesforContentItem = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) dealloc {
	[delegatesforContentItem release];
	
	[super dealloc];
}

- (void) downloadFilesForObjectInBackground: (id<DownloadableContentProtocol>) objectWithContent {
	NetworkDownloader *downloader = [[[NetworkDownloader alloc] init] autorelease];
	downloader.delegate = self;
	[downloader downloadFilesForObjectInBackground: objectWithContent];
}

- (void) setDelegate: (id<NetworkDownloadManagerDelegate>) delegate
		   forObject: (id<DownloadableContentProtocol>) objectWithContent {
	[delegatesforContentItem setObject: delegate forKey: objectWithContent.uid];
}

- (void) removeDelegate: (id<NetworkDownloadManagerDelegate>) delegate {
	NSArray *keysToRemove = [delegatesforContentItem allKeysForObject: delegate];
	[delegatesforContentItem removeObjectsForKeys: keysToRemove];
}

#pragma mark - NetworkDownloaderDelegate implementation

- (void) networkDownloader: (NetworkDownloader *) downloader didDownloadContentForItem: (DownloadableItem *) objectItem
				  inObject: (id<DownloadableContentProtocol>) objectWithContent {
	id<NetworkDownloadManagerDelegate> delegate = [delegatesforContentItem objectForKey: objectWithContent.uid];
	if (delegate != nil && [delegate respondsToSelector: @selector(didDownloadContentForItem:inObject:)] == YES) {
		[delegate didDownloadContentForItem: objectItem inObject: objectWithContent];
	}
}

- (void) networkDownloader: (NetworkDownloader *) downloader didDownloadContentForAllItemsInObject: (id<DownloadableContentProtocol>) objectWithContent {
	id<NetworkDownloadManagerDelegate> delegate = [delegatesforContentItem objectForKey: objectWithContent.uid];
	if (delegate != nil && [delegate respondsToSelector: @selector(didDownloadContentForAllItemsInObject:)] == YES) {
		[delegate didDownloadContentForAllItemsInObject: objectWithContent];
	}
}

@end
