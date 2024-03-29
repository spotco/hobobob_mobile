/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * File autogenerated with Xcode. Adapted for cocos2d needs.
 */

#import "CCResponder.h"
#import "CCDirector.h"
#import "CCDirector_Private.h"

// -----------------------------------------------------------------

@implementation CCResponder
{
}
-(BOOL)fullScreenTouch { return NO; }
// -----------------------------------------------------------------

- (id)init
{
    self = [super init];
    NSAssert(self, @"Unable to create class");

    // initialize
    _userInteractionEnabled = NO;
    _claimsUserInteraction = YES;
    _multipleTouchEnabled = NO;
    _exclusiveTouch = NO;
    
    // done
    return(self);
}

// -----------------------------------------------------------------

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    if (_userInteractionEnabled == userInteractionEnabled) return;
    _userInteractionEnabled = userInteractionEnabled;
    [[[CCDirector sharedDirector] responderManager] markAsDirty];
}

// -----------------------------------------------------------------
// override for touch and mouse functionality

- (BOOL)hitTestWithWorldPos:(CGPoint)pos
{
    return(NO);
}

// -----------------------------------------------------------------
#pragma mark - iOS
// -----------------------------------------------------------------

#if __CC_PLATFORM_IOS || __CC_PLATFORM_ANDROID

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{    
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

#else

// -----------------------------------------------------------------
#pragma mark - OSX
// -----------------------------------------------------------------

- (void)mouseDown:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    [[CCDirector sharedDirector].responderManager discardCurrentEvent];
}

#endif

// -----------------------------------------------------------------

@end
