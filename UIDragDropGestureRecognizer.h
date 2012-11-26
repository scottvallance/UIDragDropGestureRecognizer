//
//  DragDropGestureRecognizer.h
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

#import <Foundation/Foundation.h>

@class UIDragDropGestureRecognizer;

@protocol UIDragDropGestureRecognizerDelegate <UIGestureRecognizerDelegate>

- (UIView*) dragDropGestureRecognizer:(UIDragDropGestureRecognizer*)dragDropGestureRecognizer dragViewForView:(UIView*)view;
- (BOOL) dragDropGestureRecognizer:(UIDragDropGestureRecognizer *)dragDropGestureRecognizer canDropView:(UIView*)dragView inView:(UIView*)inView;

@end

@interface UIDragDropGestureRecognizer : UIGestureRecognizer

@property (nonatomic, strong) UIView* dragView;
@property (nonatomic, strong) UIView* startView;
@property (nonatomic, strong) UIView* endView;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, strong) NSArray *dropTargets;
@property (nonatomic, strong) NSArray *dragables;
@property (nonatomic, assign) id<UIDragDropGestureRecognizerDelegate> delegate;

- (id)initWithTarget:(id)target action:(SEL)action andDragables:(NSArray *)dragables andDropTargets:(NSArray *)dropTargets;

@end
