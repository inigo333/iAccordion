//
//  ViewController.h
//  KPAccardion
//
//  Created by Inigo Mato on 6/27/13.
//  Copyright (c) 2013 Inigo Mato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KPAccordionView : UIView < UIGestureRecognizerDelegate >

@property (nonatomic, assign) NSInteger topStackNotShownHeight;
@property (nonatomic, assign) NSInteger topStackShownHeight;
@property (nonatomic, assign) NSInteger bottomStackShownHeight;
@property (nonatomic, assign) NSInteger bottomStackNotShownHeight;

@property (nonatomic, assign) NSInteger maxTopStackNotShownAmount;
@property (nonatomic, assign) NSInteger maxTopStackShownAmount;
@property (nonatomic, assign) NSInteger maxBottomStackShownAmount;
@property (nonatomic, assign) NSInteger maxBottomStackNotShownAmount;

@property (nonatomic, assign) NSInteger currentCardYOrigin;
@property (nonatomic, assign) NSInteger nextCardVerticalDistance;
@property (nonatomic, assign) NSInteger horizontalMarginInset;
@property (nonatomic, assign) NSInteger startingCurrentIndex;

@property (nonatomic, assign) NSInteger speedMediumFastThreshold;
@property (nonatomic, assign) NSInteger speedFastThreshold;
@property (nonatomic, assign) CGFloat   slowSpeed;
@property (nonatomic, assign) CGFloat   mediumSpeed;
@property (nonatomic, assign) CGFloat   fastSpeed;

- (void)setupWithViewArray:(NSArray *)views;

@end
