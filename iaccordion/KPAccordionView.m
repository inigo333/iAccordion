//
//  ViewController.m
//  iCard
//
//  Created by Inigo Mato on 6/24/13.
//  Copyright (c) 2013 Inigo Mato. All rights reserved.
//

#import "KPAccordionView.h"
#import "KPAccordionConfiguration.h"

//String definitions
#define TOP_STACK_NOT_SHOWN_AMOUNT      @"topStackNotShown"
#define TOP_STACK_SHOWN_AMOUNT          @"topStackShown"
#define BOTTOM_STACK_SHOWN_AMOUNT       @"bottomStackShown"
#define BOTTOM_STACK_NOT_SHOWN_AMOUNT   @"bottomStackNotShown"
#define BOTTOM_STACK_HIDDEN_AMOUNT      @"bottomStackHidden"


@interface KPAccordionView ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *yOriginsArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIView *currentView;

@property (nonatomic, assign) NSInteger topStackNotShownAmount;
@property (nonatomic, assign) NSInteger topStackShownAmount;
@property (nonatomic, assign) NSInteger bottomStackShownAmount;
@property (nonatomic, assign) NSInteger bottomStackNotShownAmount;
@property (nonatomic, assign) NSInteger bottomStackHiddenAmount;

@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, assign) BOOL originalDirection;
@property (nonatomic, assign) BOOL dragging;

@end


@implementation KPAccordionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.topStackNotShownHeight         = TOP_STACK_NOT_SHOWN_HEIGHT;
        self.topStackShownHeight            = TOP_STACK_SHOWN_HEIGHT;
        self.bottomStackShownHeight         = BOTTOM_STACK_SHOWN_HEIGHT;
        self.bottomStackNotShownHeight      = BOTTOM_STACK_NOT_SHOWN_HEIGHT;
        
        self.maxTopStackNotShownAmount      = TOP_STACK_MAX_NOT_SHOWN_AMOUNT;
        self.maxTopStackShownAmount         = TOP_STACK_MAX_SHOWN_AMOUNT;
        self.maxBottomStackShownAmount      = BOTTOM_STACK_MAX_SHOWN_AMOUNT;
        self.maxBottomStackNotShownAmount   = BOTTOM_STACK_MAX_NOT_SHOWN_AMOUNT;
        
        self.currentCardYOrigin             = CURRENT_CARD_Y_ORIGIN;
        self.nextCardVerticalDistance       = NEXT_CARD_VERTICAL_DISTANCE;
        self.horizontalMarginInset          = HORIZONTAL_MARGIN_INSET;
        self.startingCurrentIndex           = STARTING_CURRENT_INDEX;
        
        self.speedMediumFastThreshold       = SPEED_MEDIUM_FAST_THRESHOLD;
        self.speedFastThreshold             = SPEED_FAST_THRESHOLD;
        self.slowSpeed                      = SLOW_SPEED;
        self.mediumSpeed                    = MEDIUM_SPEED;
        self.fastSpeed                      = FAST_SPEED;
        
        [self setupView];
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Life cycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupView
{
    self.items = [NSMutableArray array];
    
    self.currentIndex = self.startingCurrentIndex;
        
    [self setupGestureRecognizers];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initial setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    NSDictionary *indexes = [self indexesForCurrentIndex:_currentIndex];
    
    self.topStackNotShownAmount =     [[indexes valueForKey:TOP_STACK_NOT_SHOWN_AMOUNT] integerValue];
    self.topStackShownAmount =        [[indexes valueForKey:TOP_STACK_SHOWN_AMOUNT] integerValue];
    self.bottomStackShownAmount =     [[indexes valueForKey:BOTTOM_STACK_SHOWN_AMOUNT] integerValue];
    self.bottomStackNotShownAmount =  [[indexes valueForKey:BOTTOM_STACK_NOT_SHOWN_AMOUNT] integerValue];
    self.bottomStackHiddenAmount =    [[indexes valueForKey:BOTTOM_STACK_HIDDEN_AMOUNT] integerValue];
}


/*
    Calculate the number of cards that will be on each of the stacks:
    top-hidden, top-notShown, top-Shown and bottom, bottom-Shown, bottom-notSHown and bottom-hidden
*/
- (NSDictionary *)indexesForCurrentIndex:(NSInteger)currentIndex
{
    NSInteger listSize = (NSInteger)[self.items count];
    
    NSInteger topStackNotShownAmount =      (listSize - currentIndex - self.maxTopStackShownAmount) > 0 ? (listSize - currentIndex - self.maxTopStackShownAmount) : 0;
    NSInteger topStackShownAmount =         (listSize - currentIndex) > self.maxTopStackShownAmount ? self.maxTopStackShownAmount : (listSize - currentIndex);
    NSInteger bottomStackShownAmount =      currentIndex > self.maxBottomStackShownAmount ? self.maxBottomStackShownAmount : currentIndex;
    NSInteger bottomStackNotShownAmount =   (listSize - topStackNotShownAmount - topStackShownAmount - bottomStackShownAmount) > self.maxBottomStackNotShownAmount ?
                                            self.maxBottomStackNotShownAmount : (listSize - topStackNotShownAmount - topStackShownAmount - bottomStackShownAmount);
    NSInteger bottomStackHiddenAmount =     (listSize - topStackNotShownAmount - topStackShownAmount - bottomStackShownAmount - bottomStackNotShownAmount);
    
    NSDictionary *indexes = @{TOP_STACK_NOT_SHOWN_AMOUNT :     [NSNumber numberWithInteger:topStackNotShownAmount],
                              TOP_STACK_SHOWN_AMOUNT :         [NSNumber numberWithInteger:topStackShownAmount],
                              BOTTOM_STACK_SHOWN_AMOUNT :      [NSNumber numberWithInteger:bottomStackShownAmount],
                              BOTTOM_STACK_NOT_SHOWN_AMOUNT :  [NSNumber numberWithInteger:bottomStackNotShownAmount],
                              BOTTOM_STACK_HIDDEN_AMOUNT :     [NSNumber numberWithInteger:bottomStackHiddenAmount]};
    return indexes;
}


- (void)setupWithViewArray:(NSArray *)views
{
    for(UIView *view in views)
    {
        [self.items addObject:view];
        
        view.frame = CGRectMake(round((self.frame.size.width - view.frame.size.width)/2),
                                0,
                                view.frame.size.width,
                                view.frame.size.height);
        
        [self insertSubview:view atIndex:0];
    }
    
    [self setupFrames];
}


- (UIView *)viewForObject:(NSNumber *)object
{
    return nil;
}


- (void)setupFrames
{
    [self setupFramesWithSpeed:0.3];
}


- (void)setupFramesWithSpeed:(CGFloat)speed
{
    NSArray *yOriginsArray = [self yOriginsForCurrentIndex:self.currentIndex];
    
    for (int i = 0; i < [self.items count]; i++)
    {
        UIView *view = (UIView *)(self.items[i]);
        
        [UIView animateWithDuration:speed
                         animations:^
         {
             view.frame = CGRectMake(round((self.frame.size.width - view.frame.size.width)/2),
                                     [yOriginsArray[i] floatValue],
                                     view.frame.size.width,
                                     view.frame.size.height);
         }
                         completion:nil];
        
        self.items[i] = view;
    }
    
    self.currentView = ((UIView *)self.items[self.currentIndex]);
}


/*
    Calculate all the card's Y origins on every stack for a given currentIndex
*/
- (NSMutableArray *)yOriginsForCurrentIndex:(NSInteger)currentIndex
{
    NSMutableArray *yOriginsArray = [NSMutableArray array];
    
    NSDictionary *indexes = [self indexesForCurrentIndex:currentIndex];
    NSInteger topStackNotShownAmount =    [[indexes valueForKey:TOP_STACK_NOT_SHOWN_AMOUNT]      integerValue];
    NSInteger topStackShownAmount =       [[indexes valueForKey:TOP_STACK_SHOWN_AMOUNT]          integerValue];
    NSInteger bottomStackShownAmount =    [[indexes valueForKey:BOTTOM_STACK_SHOWN_AMOUNT]       integerValue];
    NSInteger bottomStackNotShownAmount = [[indexes valueForKey:BOTTOM_STACK_NOT_SHOWN_AMOUNT]   integerValue];
    NSInteger bottomStackHiddenAmount =   [[indexes valueForKey:BOTTOM_STACK_HIDDEN_AMOUNT]      integerValue];
    
    int j = 1;
    int k = 1;
    
    for (int i = 0; i < [self.items count]; i++)
    {
        CGFloat yOrigin;
        
        if(i < bottomStackHiddenAmount)                                                                                   //bottom hidden cards
        {
            yOrigin = self.frame.size.height;
        }
        else if((bottomStackNotShownAmount > 0) && (i < currentIndex - self.maxBottomStackShownAmount))                          //bottom not shown cards
        {
            yOrigin = self.frame.size.height - j*self.bottomStackNotShownHeight;
            j++;
        }
        else if((bottomStackNotShownAmount > 0) && (i < currentIndex))                                                    //bottom cards
        {
            yOrigin = [yOriginsArray[i-1] floatValue] - self.bottomStackShownHeight;
        }
        else if((bottomStackNotShownAmount == 0) && (i < bottomStackShownAmount))                                               //bottom shown cards ONLY
        {
            yOrigin = self.frame.size.height -(i+1)*self.bottomStackShownHeight;
        }
        else if (i == currentIndex)                                                                                 //current card
        {
            yOrigin = self.currentCardYOrigin;
        }
        else if ((topStackShownAmount > 1) && (i < currentIndex + self.maxTopStackShownAmount))                                  //top shown cards
        {
            yOrigin = self.currentCardYOrigin - k*self.topStackShownHeight;
            k++;
        }
        else if ((topStackNotShownAmount > 0) && (i < (currentIndex + self.maxTopStackShownAmount + self.maxTopStackNotShownAmount))) //top not shown cards
        {
            yOrigin = [yOriginsArray[i-1] floatValue] - (self.topStackNotShownHeight/self.maxTopStackNotShownAmount);
        }
        else                                                                                                       //top hidden
        {
            yOrigin = [yOriginsArray[i-1] floatValue];
        }
        
        yOriginsArray[i] = [NSNumber numberWithFloat:yOrigin];
    }
    
    return yOriginsArray;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Gesture Recognizers
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setupGestureRecognizers
{
    UISwipeGestureRecognizer *swipeGestureRecognizerDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                     action:@selector(didSwipeDown:)];
    swipeGestureRecognizerDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeGestureRecognizerDown.delegate = self;
    [self addGestureRecognizer:swipeGestureRecognizerDown];

    UISwipeGestureRecognizer *swipeGestureRecognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(didSwipeUp:)];
    swipeGestureRecognizerUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGestureRecognizerUp.delegate = self;
    [self addGestureRecognizer:swipeGestureRecognizerUp];
}


- (void)didSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
    if(self.currentIndex < [self.items count] - 1)
    {
        self.currentIndex++;
        [self setupFrames];
    }
}


- (void)didSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
    if (self.currentIndex != 0)
    {
        self.currentIndex--;
        [self setupFrames];
    }
}


- (void)didPan:(UIPanGestureRecognizer *)recognizer
          view:(UIView *)view
{
    NSInteger index = [self.items indexOfObject:view];

    CGPoint touchLocation = [recognizer locationInView:self];
    CGPoint velocity = [recognizer velocityInView:self];

    if (index != self.currentIndex)
    {
        if(velocity.y > 0)
        {
            self.currentIndex = (index < ([self.items count]-1)) ? index + 1 : index;
        }
        else
        {
            self.currentIndex = index;
        }
        
        if(view == self.currentView)
        {
            [self setupFramesWithSpeed:[self scaledSpeed:velocity]];
        }
        else
        {
            [self setupFrames];
        }
        
        return;
    }
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.originalDirection = YES;
        
        if (CGRectContainsPoint(self.currentView.frame, touchLocation) && !self.dragging)
        {
            self.dragging = YES;
            
            self.touchOffset = CGPointMake(self.currentView.center.x - touchLocation.x,
                                           self.currentView.center.y - touchLocation.y);
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {        
        if(self.dragging)
        {
            [self scrollWithLocation:touchLocation
                            velocity:velocity];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {        
        if(self.dragging)
        {
            self.dragging = NO;

            [self scrollItemsToFinalPosition:self.items
                                    velocity:velocity];
        }
    }
}


- (void)didTap:(UITapGestureRecognizer *)recognizer
          view:(UIView *)view
{
    NSInteger index = [self.items indexOfObject:view];
    
    if(self.currentIndex != index)
    {
        self.currentIndex = index;
        [self setupFrames];
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - View Scrolling
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollWithLocation:(CGPoint)touchLocation
                  velocity:(CGPoint)velocity
{
    NSArray *yOriginsArrayUp =      [self yOriginsForCurrentIndex:self.currentIndex - 1];
    NSArray *yOriginsArrayNow =     [self yOriginsForCurrentIndex:self.currentIndex];
    NSArray *yOriginsArrayDown =    [self yOriginsForCurrentIndex:self.currentIndex + 1];
    
    NSArray *yOriginsArray = [NSArray array];
    
    CGFloat currentViewPossibleYOrigin = touchLocation.y + self.touchOffset.y - self.currentView.frame.size.height/2;

    /*
        Dragging the current view with the finger on the enclosed area
    */
    if((currentViewPossibleYOrigin <= [yOriginsArrayDown[self.currentIndex] floatValue]) &&
       (currentViewPossibleYOrigin >= [yOriginsArrayUp[self.currentIndex] floatValue]))
    {
        if(((touchLocation.x + self.touchOffset.x - self.currentView.frame.size.width/2) <= self.frame.origin.x + self.horizontalMarginInset) ||
           ((touchLocation.x + self.touchOffset.x + self.currentView.frame.size.width/2) >= self.frame.size.width - self.horizontalMarginInset))
        {
            self.currentView.center = CGPointMake(self.currentView.center.x,
                                                  touchLocation.y + self.touchOffset.y);
        }
        else
        {
            self.currentView.center = CGPointMake(touchLocation.x + self.touchOffset.x,
                                                  touchLocation.y + self.touchOffset.y);
        }
    }
    else if(!(((touchLocation.x + self.touchOffset.x - self.currentView.frame.size.width/2) <= self.frame.origin.x + self.horizontalMarginInset) ||
             ((touchLocation.x + self.touchOffset.x + self.currentView.frame.size.width/2) >= self.frame.size.width - self.horizontalMarginInset)))
    {
        self.currentView.center = CGPointMake(touchLocation.x + self.touchOffset.x,
                                              self.currentView.center.y);
    }
    
    /*
        Make other cards to follow the current one (accordion effect)
    */
    CGFloat scrollPercentage = [self scrollPercentageWithVelocity:velocity];

    if ((self.currentView.frame.origin.y >= self.currentCardYOrigin))
    {
        if (velocity.y >= 0)
        {
            yOriginsArray = yOriginsArrayDown;
        }
        else
        {
            self.originalDirection = NO;
            yOriginsArray = yOriginsArrayNow;
            yOriginsArrayNow = yOriginsArrayDown;
        }
    }
    else
    {
        if (velocity.y <= 0)
        {
            yOriginsArray = yOriginsArrayUp;
            
            if (self.currentIndex != 0)
            {
                [self updateFrameForViewAtIndex:(self.currentIndex - 1)
                               scrollPercentage:scrollPercentage
                                         origin:([yOriginsArrayNow[self.currentIndex - 1] floatValue])
                                            end:([yOriginsArrayNow[self.currentIndex - 1] floatValue] - self.nextCardVerticalDistance)];
            }
        }
        else
        {
            self.originalDirection = NO;
            yOriginsArray = yOriginsArrayNow;
            yOriginsArrayNow = yOriginsArrayUp;
            
            if (self.currentIndex != 0)
            {
                [self updateFrameForViewAtIndex:(self.currentIndex - 1)
                               scrollPercentage:scrollPercentage
                                         origin:([yOriginsArray[self.currentIndex - 1] floatValue] - self.nextCardVerticalDistance)
                                            end:([yOriginsArray[self.currentIndex - 1] floatValue])];
            }
        }
    }
    
    for (int i = self.currentIndex + 1; i < [self.items count]; i++)
    {
        [self updateFrameForViewAtIndex:i
                    scrollPercentage:scrollPercentage
                              origin:[yOriginsArrayNow[i] floatValue]
                                 end:[yOriginsArray[i] floatValue]];
    }
}


- (void)scrollItemsToFinalPosition:(NSMutableArray *)items
                          velocity:(CGPoint)velocity
{
    [self updateCurrentIndexWithVelocity:velocity];
    [self setupFramesWithSpeed:[self scaledSpeed:velocity]];
}


- (CGFloat)scaledSpeed:(CGPoint)velocity
{
    if (fabsf(velocity.y) > self.speedFastThreshold)
    {
        return self.fastSpeed;
    }
    else if (fabsf(velocity.y) > self.speedMediumFastThreshold)
    {
        return self.mediumSpeed;
    }
    
    return self.slowSpeed;
}


- (void)updateCurrentIndexWithVelocity:(CGPoint)velocity
{
    if(self.originalDirection)
    {
        if ((velocity.y >= 0) && (self.currentIndex < [self.items count] - 1))
        {
            self.currentIndex++;
        }
        else if ((velocity.y < 0) && (self.currentIndex !=0))
        {
            self.currentIndex--;
        }
    }
}


- (CGFloat)scrollPercentageWithVelocity:(CGPoint)velocity
{
    CGFloat scrollPercentage = 0;
    NSArray *yOriginsArrayUp = [self yOriginsForCurrentIndex:self.currentIndex - 1];
    NSArray *yOriginsArrayNow = [self yOriginsForCurrentIndex:self.currentIndex];
    NSArray *yOriginsArrayDown = [self yOriginsForCurrentIndex:self.currentIndex + 1];
    
    if ((self.currentView.frame.origin.y >= self.currentCardYOrigin))
    {
        if (velocity.y >= 0)
        {
            scrollPercentage =
            fabsf(([yOriginsArrayNow[self.currentIndex] floatValue] - self.currentView.frame.origin.y)/
                  ([yOriginsArrayNow[self.currentIndex] floatValue] - [yOriginsArrayDown[self.currentIndex] floatValue]));
        }
        else
        {
            scrollPercentage =
            fabsf(([yOriginsArrayDown[self.currentIndex] floatValue] - self.currentView.frame.origin.y)/
                  ([yOriginsArrayDown[self.currentIndex] floatValue] - [yOriginsArrayNow[self.currentIndex] floatValue]));
        }
    }
    else
    {
        if (velocity.y <= 0)
        {
            scrollPercentage =
            fabsf(([yOriginsArrayNow[self.currentIndex] floatValue] - self.currentView.frame.origin.y)/
                  ([yOriginsArrayNow[self.currentIndex] floatValue] - [yOriginsArrayUp[self.currentIndex] floatValue]));
        }
        else
        {
            scrollPercentage =
            fabsf(([yOriginsArrayUp[self.currentIndex] floatValue] - self.currentView.frame.origin.y)/
                  ([yOriginsArrayUp[self.currentIndex] floatValue] - [yOriginsArrayNow[self.currentIndex] floatValue]));
        }
    }
        
    return scrollPercentage;
}


- (void)updateFrameForViewAtIndex:(NSInteger)index
                 scrollPercentage:(CGFloat)scrollPercentage
                           origin:(CGFloat)origin
                              end:(CGFloat)end
{
    UIView *view = ((UIView *)self.items[index]);
     
    view.frame = CGRectMake(view.frame.origin.x,
                             origin + scrollPercentage*(end-origin),
                             view.frame.size.width,
                             view.frame.size.height);
}

@end

