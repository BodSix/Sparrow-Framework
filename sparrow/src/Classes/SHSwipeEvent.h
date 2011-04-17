//
//  SHSwipeEvent.h
//  Sparrow
//
//  Created by Shilo White on 3/10/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#define SH_EVENT_TYPE_SWIPE @"swipe"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SPEvent.h"
#import "SPStage.h"

@class SPPoint;
@class SPDisplayObject;

typedef enum {
	SHSwipeDirectionRight = UISwipeGestureRecognizerDirectionRight,
	SHSwipeDirectionLeft  = UISwipeGestureRecognizerDirectionLeft,
	SHSwipeDirectionUp    = UISwipeGestureRecognizerDirectionUp,
	SHSwipeDirectionDown  = UISwipeGestureRecognizerDirectionDown
} SHSwipeDirection;

@interface SHSwipeEvent : SPEvent {
	SPPoint *mLocation;
	SHSwipeDirection mDirection;
}

@property (nonatomic, readonly) SPPoint *location;
@property (nonatomic, readonly) SHSwipeDirection direction;

- (id)initWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction;
- (id)initWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction bubbles:(BOOL)bubbles;
+ (SHSwipeEvent *)eventWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction;
+ (SHSwipeEvent *)eventWithType:(NSString *)type location:(SPPoint *)location direction:(SHSwipeDirection)direction bubbles:(BOOL)bubbles;
- (SPPoint *)locationInSpace:(SPDisplayObject *)space;
- (SHSwipeDirection)directionInSpace:(SPDisplayObject *)space;
@end

@interface SPStage (swipe)
- (void)startSwipeRecognizer;
- (void)stopSwipeRecognizer;
@end