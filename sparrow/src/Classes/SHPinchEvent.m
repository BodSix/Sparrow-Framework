//
//  SHPinchEvent.m
//  Sparrow
//
//  Created by Shilo White on 6/4/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#define SH_EXC_NATIVEVIEW_NIL @"NativeViewDoesNotExist"

#import "SHPinchEvent.h"
#import "SPPoint.h"
#import "SPDisplayObject.h"
#import "SPMatrix.h"

@implementation SHPinchEvent

@synthesize location = mLocation;
@synthesize scale = mScale;
@synthesize velocity = mVelocity;
@synthesize numberOfTouches = mNumberOfTouches;

- (id)initWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches {
	return [self initWithType:type location:location scale:scale velocity:velocity numberOfTouches:numberOfTouches bubbles:YES];
}

- (id)initWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches bubbles:(BOOL)bubbles {
	if ((self = [super initWithType:type bubbles:bubbles])) {        
		mLocation = location;
		mScale = scale;
        mVelocity = velocity;
        mNumberOfTouches = numberOfTouches;
    }
    return self;
}


+ (SHPinchEvent *)eventWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches {
	return [[[SHPinchEvent alloc] initWithType:type location:location scale:scale velocity:velocity numberOfTouches:numberOfTouches bubbles:YES] autorelease];
}

+ (SHPinchEvent *)eventWithType:(NSString *)type location:(SPPoint *)location scale:(float)scale velocity:(float)velocity numberOfTouches:(uint)numberOfTouches bubbles:(BOOL)bubbles {
	return [[[SHPinchEvent alloc] initWithType:type location:location scale:scale velocity:velocity numberOfTouches:numberOfTouches bubbles:bubbles] autorelease];
}

- (SPPoint *)locationInSpace:(SPDisplayObject *)space {
	SPDisplayObject *mTarget = (SPDisplayObject *)self.target;
	SPPoint *point = [SPPoint pointWithX:mLocation.x y:mLocation.y];
    SPMatrix *transformationMatrix = [mTarget.root transformationMatrixToSpace:space];
    return [transformationMatrix transformPoint:point];
}

@end

@implementation SPStage (pinch)

static UIPinchGestureRecognizer *mPinchRecognizer;

- (void)startPinchRecognizer {
  UIView *nativeView = self.nativeView;
	if (!nativeView) [NSException raise:SH_EXC_NATIVEVIEW_NIL format:@"nativeView not linked to stage yet.", NSStringFromSelector(_cmd)];
	if (mPinchRecognizer) return;
    
  mPinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(_onPinch:)];
  mPinchRecognizer.cancelsTouchesInView = NO;
	mPinchRecognizer.delaysTouchesBegan = NO;
	mPinchRecognizer.delaysTouchesEnded = NO;
  [nativeView addGestureRecognizer:mPinchRecognizer];
  [mPinchRecognizer release];
}

- (void)stopPinchRecognizer {
  UIView *nativeView = self.nativeView;
	if (!nativeView) [NSException raise:SH_EXC_NATIVEVIEW_NIL format:@"nativeView not linked to stage yet.", NSStringFromSelector(_cmd)];
    
  [nativeView removeGestureRecognizer:mPinchRecognizer];
  mPinchRecognizer = nil;
}

- (void)_onPinch:(UIPinchGestureRecognizer *)pinchRecognizer {
  CGPoint location = [pinchRecognizer locationInView:self.nativeView];
  SPPoint *touchLocation = [SPPoint pointWithX:location.x y:location.y];
  SPDisplayObject *object = [self hitTestPoint:touchLocation forTouch:YES];
  if (!object) return;
  
  SPMatrix *transformationMatrix = [self transformationMatrixToSpace:object];
  SPPoint *localLocation = [transformationMatrix transformPoint:touchLocation];

  SHPinchEvent *event = [[SHPinchEvent alloc] initWithType:SH_EVENT_TYPE_PINCH location:localLocation scale:pinchRecognizer.scale velocity:pinchRecognizer.velocity numberOfTouches:pinchRecognizer.numberOfTouches];
  [object dispatchEvent:event];
	[event release];
}
@end