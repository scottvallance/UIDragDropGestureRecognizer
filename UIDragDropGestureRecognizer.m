//
//  DragDropGestureRecognizer.m
//
//The MIT License (MIT)
//Copyright © 2012 Scott Vallance, http://scottvallanceapps.com
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the “Software”), to deal in
//the Software without restriction, including without limitation the rights to use,
//copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
//AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIDragDropGestureRecognizer.h"
#import <UIKit/UIGestureRecognizer.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation UIDragDropGestureRecognizer
@synthesize dragables = _dragables;
@synthesize dropTargets = _dropTargets;
@synthesize dragView = _dragView;
@synthesize startView = _startView;
@synthesize endView = _endView;

- (id)initWithTarget:(id)target action:(SEL)action andDragables:(NSArray *)dragables andDropTargets:(NSArray *)dropTargets {
    self = [super initWithTarget:target action:action];
    if (self) {
        _dropTargets = dropTargets;
        _dragables = dragables;
        _dragView = nil;
        _startView = nil;
        _endView = nil;
    }
    
    return self;
}

-(void) setDelegate:(id<UIDragDropGestureRecognizerDelegate>) delegate {
    [super setDelegate: delegate];
}
- (id) delegate {
    return [super delegate];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    switch (self.state) {
        case UIGestureRecognizerStatePossible: {
            if(!self.dragView) {
                for (UIView *dragable in _dragables) {
                    CGPoint pointInView = [self locationInView:dragable];
                    if ([dragable pointInside:pointInView withEvent:nil]) {
                        UIView *dragView = dragable;
                        if([self.delegate respondsToSelector:@selector(dragDropGestureRecognizer:dragViewForView:)]) {
                            dragView = [self.delegate performSelector:@selector(dragDropGestureRecognizer:dragViewForView:) withObject:self withObject:dragable];
                        }
                        
                        self.dragView = dragView;
                        self.startPoint = dragView.frame.origin;
                        self.startView = dragView.superview;
                        self.endView = nil;
                        [dragView removeFromSuperview];
                        [self.view addSubview:dragView];
                        [self dragObject];
                    }
                }
                if(self.dragView) {
                    self.state = UIGestureRecognizerStateBegan;
                } else {
                    self.state = UIGestureRecognizerStateFailed;
                }
            }
        }
            break;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    switch(self.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            [self dragObject];
            self.state = UIGestureRecognizerStateChanged;
        }
            break;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    switch(self.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStatePossible: {
            self.state = UIGestureRecognizerStateFailed;
        }
            break;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    switch(self.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStatePossible: {
            if (self.dragView) {
                BOOL dropped = NO;
                for (UIView *dropArea in self.dropTargets) {
                    CGPoint dropPoint = [self locationInView:dropArea];
                    if ([dropArea pointInside:dropPoint withEvent:nil]) {
                        if([self.delegate respondsToSelector:@selector(dragDropGestureRecognizer:canDropView:inView:)]) {
                            NSMethodSignature* sig = [self.delegate methodSignatureForSelector:@selector(dragDropGestureRecognizer:canDropView:inView:)];
                            NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
                            [inv setTarget:self.delegate];
                            [inv setSelector:@selector(dragDropGestureRecognizer:canDropView:inView:)];
                            [inv setArgument:(void *)(&self) atIndex:2];
                            [inv setArgument:(&_dragView) atIndex:3];
                            [inv setArgument:(void *)(&dropArea) atIndex:4];
                            [inv invoke];
                            BOOL result;
                            [inv getReturnValue:&result];
                            if(!result) {
                                continue;
                            }
                        }
                        
                        dropped = YES;
                        [self.dragView removeFromSuperview];
                        [dropArea addSubview:self.dragView];
                        self.dragView.frame = (CGRect) {.origin = CGPointMake(dropPoint.x - self.dragView.frame.size.width/2.0,
                                                                              dropPoint.y - self.dragView.frame.size.height/2.0),
                            .size = self.dragView.frame.size};
                        self.endView = dropArea;
                        self.state = UIGestureRecognizerStateEnded;
                        
                        break;
                    }
                }
                
                if (!dropped) {
                    [self.dragView removeFromSuperview];
                    [self.startView addSubview:self.dragView];
                    self.dragView.frame = (CGRect){.origin = self.startPoint, .size=self.dragView.frame.size};
                    self.state = UIGestureRecognizerStateFailed;
                }
            }
            self.state = UIGestureRecognizerStateFailed;
        }
            break;
    }
}

- (void)reset {
    [super reset];
    self.dragView = nil;
    self.startView = nil;
    self.endView = nil;
    self.state = UIGestureRecognizerStatePossible;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer {
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer {
    if(self.dragView) {
        return YES;
    }
    return NO;
}

- (void)dragObject {
    if (self.dragView) {
        CGPoint pointOnView = [self locationInView:self.view];
        self.dragView.center = pointOnView;
    }
}

@end