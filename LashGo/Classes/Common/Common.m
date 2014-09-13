//
//  Common.m
//  DevLib
//
//  Created by Vitaliy Pykhtin on 23.04.14.
//  Copyright (c) 2014 Vitaliy Pykhtin. All rights reserved.
//

#import "Common.h"

static NSString *const kUUIDDeviceKey = @"lg_uuid_device_key";

@implementation NSString (CommonExtension)

@dynamic commonLocalizedString;

#pragma mark - Properties

- (NSString *) commonLocalizedString {
	return NSLocalizedStringFromTable(self, @"Localizable", nil);
}

#pragma mark - Methods

+ (NSString *) stringWithData: (NSData *) data {
	return [ [NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

- (NSString *) stringBetweenString:(NSString*)start
						 andString:(NSString*)end {
	NSScanner* scanner = [NSScanner scannerWithString: self];
	[scanner setCharactersToBeSkipped:nil];
	[scanner scanUpToString:start intoString:NULL];
	if ([scanner scanString:start intoString:NULL]) {
		NSString* result = nil;
		if ([scanner scanUpToString:end intoString:&result]) {
			return result;
		}
	}
	return nil;
}

@end

@implementation Common

+ (NSString *) appBuild {
	return [ [ [NSBundle mainBundle] infoDictionary] valueForKey: @"CFBundleVersion"];
}

+ (NSString *) appVersion {
	return [ [ [NSBundle mainBundle] infoDictionary] valueForKey: @"CFBundleShortVersionString"];
}

#pragma mark -

+ (NSString *) deviceUUID {
	static NSString *deviceID = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *udid = [userDefaults stringForKey: kUUIDDeviceKey];
		if ([Common isEmptyString:udid] == YES) {
			udid = [Common generateUUID];
			[userDefaults setValue:udid forKey:kUUIDDeviceKey];
			[userDefaults synchronize];
		}
		deviceID = udid;
	});
	
	return deviceID;
}

+ (NSString *) generateUUID {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef str = CFUUIDCreateString(NULL, uuid);
	NSString *result = [NSString stringWithString: (__bridge NSString *) str];
	CFRelease(uuid);
	CFRelease(str);
	
	return result;
}

+ (NSString *) generateUniqueString {
	NSMutableString *result = [NSMutableString stringWithString: [Common generateUUID]];
	[result replaceOccurrencesOfString: @"-" withString: @"" options: NSLiteralSearch
								 range: NSMakeRange(0, [result length]) ];
	return result;
}

#pragma mark -

+ (BOOL) is568hMode {
	return [UIScreen mainScreen].bounds.size.height > 480;
}

+ (BOOL) isEmptyString: (NSString *) string {
	if (string != nil &&
		[[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]]
		 isEqualToString: @""] == NO) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - 

- (UIImage *) squareImageFromImage: (UIImage *) image {
    UIImage *squareImage = nil;
    CGSize imageSize = [image size];
    
    if (imageSize.width == imageSize.height) {
        squareImage = image;
    } else {
        // Compute square crop rect
        CGFloat smallerDimension = MIN(imageSize.width, imageSize.height);
        CGRect cropRect = CGRectMake(0, 0, smallerDimension, smallerDimension);
        
        // Center the crop rect either vertically or horizontally, depending on which dimension is smaller
        if (imageSize.width <= imageSize.height) {
            cropRect.origin = CGPointMake(0, rintf((imageSize.height - smallerDimension) / 2.0));
        } else {
            cropRect.origin = CGPointMake(rintf((imageSize.width - smallerDimension) / 2.0), 0);
        }
        
        CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        squareImage = [UIImage imageWithCGImage:croppedImageRef scale: image.scale orientation: UIImageOrientationUp];
        CGImageRelease(croppedImageRef);
		//	// Create path.
		//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		//	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
		//
		//	// Save image.
		//	[UIImagePNGRepresentation(squareImage) writeToFile:filePath atomically:YES];
		//
		//	UIImage *storedImage = [UIImage imageWithContentsOfFile: filePath];
    }
    
    return squareImage;
}

- (UIImage *) generateThumbnailForImage: (UIImage *) image withSize: (CGSize) size {
//	CGFloat imageDiameter = MIN(self.frame.size.width, self.frame.size.height) - self.imageCaps * 2;
	CGRect contextBounds = CGRectZero;
//	contextBounds.size = CGSizeMake(imageDiameter, imageDiameter);
	contextBounds.size = size;
	
	UIImage *sourceImage = image;
	UIImage *squareImage = [self squareImageFromImage: sourceImage];
	
	UIGraphicsBeginImageContextWithOptions(contextBounds.size, YES, 0.0);
	
	[squareImage drawInRect:contextBounds];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	//	//Should be stored with scale == 1 for correct image dpi settings
	//	UIImage *imageToStore = [UIImage imageWithCGImage: scaledImage.CGImage
	//												scale: 1
	//										  orientation: UIImageOrientationUp];
	
	UIGraphicsEndImageContext();
	
	//	// Create path.
	//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image@2x.png"];
	//
	//	// Save image.
	//	[UIImagePNGRepresentation(imageToStore) writeToFile:filePath atomically:YES];
	//
	//	UIImage *storedImage = [UIImage imageWithContentsOfFile: filePath];
	
	return scaledImage;
}

#pragma mark -

+ (void) logScaleAndParamsForTwoSizes: (float) in1 and: (float) in2 {
	float min = MIN(in1, in2);
	float max = MAX(in1, in2);
	float increasingScale = max / min;
	float a = (increasingScale - 1) / 88;
	float b = 1 - 480 * a;
	NSLog(@"(%.3f * screenHeight + %.2f) resultScale: %f", a, b, increasingScale);
}

@end
