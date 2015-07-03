//
//  KPItemView.m
//  KPAccardion
//
//  Created by Inigo Mato on 7/1/13.
//  Copyright (c) 2013 Inigo Mato. All rights reserved.
//

#import "AccordionItemView.h"


@implementation AccordionItemView


- (id)initWithDelegate:(id)delegate
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.delegate = delegate;
        [self setupGestureRecognizers];
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Gesture Recognizers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupGestureRecognizers
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(didTap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(didPan:)];
    //panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:panGestureRecognizer];
}


- (void)didTap:(UITapGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(didTap:view:)])
    {
            [self.delegate performSelector:@selector(didTap:view:)
                                withObject:recognizer
                                withObject:self];
    }
}


- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(didPan:view:)])
    {
        [self.delegate performSelector:@selector(didPan:view:)
                            withObject:recognizer
                            withObject:self];
    }
}


//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
//{
//    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]])
//    {
//        UIPanGestureRecognizer *panGestureRecognozer = (UIPanGestureRecognizer *)recognizer;
//        CGPoint translation = [panGestureRecognozer translationInView:self];
//
//        if (fabsf(translation.x) > fabsf(translation.y))
//        {
//            return NO;
//        }
//    }
//    
//    return YES;
//}


@end
