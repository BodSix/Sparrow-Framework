//
//  SHSwipeEvent.m
//  Sparrow
//
//  Created by Shilo White on 3/10/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#define SH_EXC_NATIVEVIEW_NIL @"NativeViewDoesNotExist"
#define PI 3.14159265359f
#define SP_R2D(rad) ((rad) / PI * 180.0f)

#import "SHSwipeEvent.h"
#import "SPPoint.h"
#import "SPDisplayObject.h"
#import "SPMatrix.h"

@implementation SHSwipeEvent

@synthesize location = mLocation;
@synthesize direction = mDirection;

- (id)initWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction {
	return [self initWithType:type location:location direction:direction bubbles:YES];
}

- (id)initWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction bubbles:(BOOL)bubbles {
	if ((self = [super initWithType:type bubbles:bubbles])) {        
		mLocation = location;
		mDirection = direction;
  }
  return self;
}


+ (SHSwipeEvent *)eventWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction {
	return [[[SHSwipeEvent alloc] initWithType:type location:location direction:direction bubbles:YES] autorelease];
}

+ (SHSwipeEvent *)eventWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction bubbles:(BOOL)bubbles {
	return [[[SHSwipeEvent alloc] initWithType:type location:location direction:direction bubbles:bubbles] autorelease];
}

- (SPPoint *)locationInSpace:(SPDisplayObject *)space {
	SPDisplayObject *mTarget = (SPDisplayObject *)self.target;
	SPPoint *point = [SPPoint pointWithX:mLocation.x y:mLocation.y];
  SPMatrix *transformationMatrix = [mTarget.root transformationMatrixToSpace:space];
  return [transformationMatrix transformPoint:point];
}

- (SHSwipeDirection)directionInSpace:(SPDisplayObject *)space {
	float swipeAngle = 0;
	if (mDirection == SHSwipeDirectionUp) {
		swipeAngle = 0;
	} else if (mDirection == SHSwipeDirectionDown) {
		swipeAngle = 180.0f;
	} else if (mDirection == SHSwipeDirectionLeft) {
		swipeAngle = 270.0f;
	} else if (mDirection == SHSwipeDirectionRight) {
		swipeAngle = 90.0f;
	}
	
	float spaceRotation = 0;
	while (space.parent) {
		spaceRotation += space.rotation;
		space = space.parent;
	}
	spaceRotation = SP_R2D(spaceRotation);
	
	swipeAngle -= spaceRotation;
	if (swipeAngle < 0) swipeAngle += 360;
	
	if ((swipeAngle >= 315 && swipeAngle <= 360) || (swipeAngle >= 0 && swipeAngle < 45)) {
		return SHSwipeDirectionUp;
	} else if (swipeAngle >= 45 && swipeAngle < 135) {
		return SHSwipeDirectionRight;
	} else if (swipeAngle >= 135 && swipeAngle < 225) {
		return SHSwipeDirectionDown;
	} else {
		return SHSwipeDirectionLeft;
	}
}
@end

@implementation SPStage (swipe)

static UISwipeGestureRecognizer *mUpSwipeRecognizer;
static UISwipeGestureRecognizer *mDownSwipeRecognizer;
static UISwipeGestureRecognizer *mLeftSwipeRecognizer;
static UISwipeGestureRecognizer *mRightSwipeRecognizer;

- (void)startSwipeRecognizer {
	UIView *nativeView = self.nativeView;
	if (!nativeView) [NSException raise:SH_EXC_NATIVEVIEW_NIL format:@"nativeView not linked to stage yet.", NSStringFromSelector(_cmd)];
	if (mUpSwipeRecognizer) return;
	
	mUpSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeUp:)];
	mUpSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
	mUpSwipeRecognizer.cancelsTouchesInView = NO;
	mUpSwipeRecognizer.delaysTouchesBegan = NO;
	mUpSwipeRecognizer.delaysTouchesEnded = NO;
	
	mDownSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeDown:)];
	mDownSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
	mDownSwipeRecognizer.cancelsTouchesInView = NO;
	mDownSwipeRecognizer.delaysTouchesBegan = NO;
	mDownSwipeRecognizer.delaysTouchesEnded = NO;
	
	mLeftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeLeft:)];
	mLeftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	mLeftSwipeRecognizer.cancelsTouchesInView = NO;
	mLeftSwipeRecognizer.delaysTouchesBegan = NO;
	mLeftSwipeRecognizer.delaysTouchesEnded = NO;
	
	mRightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeRight:)];
	mRightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	mRightSwipeRecognizer.cancelsTouchesInView = NO;
	mRightSwipeRecognizer.delaysTouchesBegan = NO;
	mRightSwipeRecognizer.delaysTouchesEnded = NO;
  
	[nativeView addGestureRecognizer:mUpSwipeRecognizer];
	[nativeView addGestureRecognizer:mDownSwipeRecognizer];
	[nativeView addGestureRecognizer:mLeftSwipeRecognizer];
	[nativeView addGestureRecognizer:mRightSwipeRecognizer];
	
	[mUpSwipeRecognizer release];
	[mDownSwipeRecognizer release];
	[mLeftSwipeRecognizer release];
	[mRightSwipeRecognizer release];
}

- (void)stopSwipeRecognizer {
	UIView *nativeView = self.nativeView;
	if (!nativeView) [NSException raise:SH_EXC_NATIVEVIEW_NIL format:@"nativeView not linked to stage yet.", NSStringFromSelector(_cmd)];
	
	[nativeView removeGestureRecognizer:mUpSwipeRecognizer];
	[nativeView removeGestureRecognizer:mDownSwipeRecognizer];
	[nativeView removeGestureRecognizer:mLeftSwipeRecognizer];
	[nativeView removeGestureRecognizer:mRightSwipeRecognizer];
	
	mUpSwipeRecognizer = mDownSwipeRecognizer = mLeftSwipeRecognizer = mRightSwipeRecognizer = nil;
}

- (void)onSwipeUp:(UISwipeGestureRecognizer *)upSwipeRecognizer {
	CGPoint location = [upSwipeRecognizer locationInView:self.nativeView];
	SHSwipeDirection direction = (SHSwipeDirection)upSwipeRecognizer.direction;
	SHSwipeEvent *event = [[SHSwipeEvent alloc] initWithType:SH_EVENT_TYPE_SWIPE location:[SPPoint pointWithX:location.x y:location.y] direction:direction];
	[self dispatchEvent:event];
	[event release];
}

- (void)onSwipeDown:(UISwipeGestureRecognizer *)downSwipeRecognizer {
	CGPoint location = [downSwipeRecognizer locationInView:self.nativeView];
	SHSwipeDirection direction = (SHSwipeDirection)downSwipeRecognizer.direction;
	SHSwipeEvent *event = [[SHSwipeEvent alloc] initWithType:SH_EVENT_TYPE_SWIPE location:[SPPoint pointWithX:location.x y:location.y] direction:direction];
	[self dispatchEvent:event];
	[event release];
}

- (void)onSwipeLeft:(UISwipeGestureRecognizer *)leftSwipeRecognizer {
	CGPoint location = [leftSwipeRecognizer locationInView:self.nativeView];
	SHSwipeDirection direction = (SHSwipeDirection)leftSwipeRecognizer.direction;
	SHSwipeEvent *event = [[SHSwipeEvent alloc] initWithType:SH_EVENT_TYPE_SWIPE location:[SPPoint pointWithX:location.x y:location.y] direction:direction];
	[self dispatchEvent:event];
	[event release];
}

- (void)onSwipeRight:(UISwipeGestureRecognizer *)rightSwipeRecognizer {
	CGPoint location = [rightSwipeRecognizer locationInView:self.nativeView];
	SHSwipeDirection direction = (SHSwipeDirection)rightSwipeRecognizer.direction;
	SHSwipeEvent *event = [[SHSwipeEvent alloc] initWithType:SH_EVENT_TYPE_SWIPE location:[SPPoint pointWithX:location.x y:location.y] direction:direction];
	[self dispatchEvent:event];
	[event release];
}
@end