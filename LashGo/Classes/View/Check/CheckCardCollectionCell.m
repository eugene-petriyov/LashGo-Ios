//
//  CheckCardCollectionCell.m
//  LashGo
//
//  Created by Vitaliy Pykhtin on 14.07.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "CheckCardCollectionCell.h"
#import "FontFactory.h"

NSString *const kCheckCardCollectionCellReusableId = @"kCheckCardCollectionCellReusableId";

@interface CheckCardCollectionCell () {
	CheckDetailView *_checkView;
	CheckDetailView *_userPhotoView;
}

@end

@implementation CheckCardCollectionCell

@dynamic mainImage, secondImage;
@dynamic type;

#pragma mark - Properties

- (UIImage *) mainImage {
	return _checkView.image;
}

- (void) setMainImage:(UIImage *)mainImage {
	_checkView.image = mainImage;
}

- (UIImage *) secondImage {
	return _userPhotoView.image;
}

- (void) setSecondImage:(UIImage *)secondImage {
	_userPhotoView.image = secondImage;
}

- (CheckDetailType) type {
	return _checkView.type;
}

- (void) setType:(CheckDetailType) type {
	_checkView.type = type;
	[_checkView refresh];
}

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		CGFloat offsetY = 21;
		
		_textLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, offsetY, self.contentView.frame.size.width, 20)];
		_textLabel.font = [FontFactory fontWithType: FontTypeCheckCardTitle];
		_textLabel.textAlignment = NSTextAlignmentCenter;
		_textLabel.textColor = [FontFactory fontColorForType: FontTypeCheckCardTitle];
		_textLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview: _textLabel];
		
		offsetY += _textLabel.frame.size.height + 24;
		
		float cvOffsetX = 58;
		
		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(cvOffsetX, offsetY,
																				   self.contentView.frame.size.width - cvOffsetX * 2, 204)];
		scrollView.clipsToBounds = NO;
		scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 2, scrollView.frame.size.height);
		scrollView.delegate = self;
		scrollView.pagingEnabled = YES;
		scrollView.showsHorizontalScrollIndicator = NO;
		[self.contentView addSubview: scrollView];
		
		CGRect checkViewFrame = CGRectMake(0, 0, 204, 204);
		
		_checkView = [[CheckDetailView alloc] initWithFrame: checkViewFrame
												  imageCaps: 18 progressLineWidth: 10];
		[scrollView addSubview: _checkView];
		
		checkViewFrame.origin.x += checkViewFrame.size.width;
		
		_userPhotoView = [[CheckDetailView alloc] initWithFrame: checkViewFrame
													  imageCaps: 18 progressLineWidth: 10];
		_userPhotoView.displayPreview = YES;
		[scrollView addSubview: _userPhotoView];
		
		offsetY += scrollView.frame.size.height + 23;
		
		CGFloat descrHeight = 69;
		
		_detailTextLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, offsetY, self.contentView.frame.size.width, descrHeight)];
		_detailTextLabel.font = [FontFactory fontWithType: FontTypeCheckCardDescription];
		_detailTextLabel.numberOfLines = 3;
		_detailTextLabel.textAlignment = NSTextAlignmentCenter;
		_detailTextLabel.textColor = [FontFactory fontColorForType: FontTypeCheckCardDescription];
		_detailTextLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview: _detailTextLabel];
		
		[NSTimer scheduledTimerWithTimeInterval:1 target: self selector:@selector(updateProgress) userInfo:nil repeats:YES];
    }
    return self;
}

- (NSString *) reuseIdentifier {
	return kCheckCardCollectionCellReusableId;
}

- (void) updateProgress {
	static CGFloat a = 0;
	a += 0.1;
	if (a < 2.0) {
		_checkView.progressValue = a;
		_userPhotoView.progressValue = a;
	}
}

#pragma mark - UIScrollViewDelegate implementation

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	_checkView.displayPreview = scrollView.contentOffset.x > 0;
//	if (scrollView.contentOffset.x < scrollView.frame.size.width) {
		_userPhotoView.displayPreview = scrollView.contentOffset.x < scrollView.frame.size.width;
//	}
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
