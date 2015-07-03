//
//  ViewController.m
//  iCard
//
//  Created by Inigo Mato on 6/24/13.
//  Copyright (c) 2013 Inigo Mato. All rights reserved.
//

#import "AccordionViewController.h"
#import "AccordionItemView.h"

//Number of points
#define HORIZONTAL_OFFSET 50

#define TOP_STACK_NOT_SHOWN_HEIGHT 35
#define TOP_SHOWN_HEIGHT 35
#define BOTTOM_SHOWN_HEIGHT 20
#define BOTTOM_NOT_SHOWN_HEIGHT 10


#define NEXT_CARD_VERTICAL_DISTANCE 30


#warning IM get rid of these
#define CARD_WIDTH 280
#define CARD_HEIGHT 190
#define CARD_ORIGIN_Y 150


//Number of views
#define TOP_MAX_NOT_SHOWN 3
#define TOP_MAX_SHOWN 3
#define BOTTOM_MAX_SHOWN 2
#define BOTTOM_MAX_NOT_SHOWN 3


//String definitions
#define TOP_STACK_NOT_SHOWN @"topStackNotShown"
#define TOP_STACK_SHOWN @"topStackShown"
#define BOTTOM_STACK_SHOWN @"bottomStackShown"
#define BOTTOM_STACK_NOT_SHOWN @"bottomStackNotShown"
#define BOTTOM_STACK_HIDDEN @"bottomStackHidden"


@interface AccordionViewController ()

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *yOriginsArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIView *currentView;

@property (nonatomic, assign) NSInteger topStackNotShown;
@property (nonatomic, assign) NSInteger topStackShown;
@property (nonatomic, assign) NSInteger bottomStackShown;
@property (nonatomic, assign) NSInteger bottomStackNotShown;
@property (nonatomic, assign) NSInteger bottomStackHidden;

@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, assign) BOOL originalDirection;
@property (nonatomic, assign) BOOL dragging;
@end

@implementation AccordionViewController

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Life cycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.items = [NSMutableArray array];
    
    self.currentIndex = 4;//set it to the default card? first (0)?
    
    [self setupViewsWithArray:[self fakeItems]];
    
    [self setupGestureRecognizers];
}


- (CGFloat)listSize
{
    return 20;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Initial setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSArray *)fakeItems
{
    NSMutableArray *fakeItems = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self listSize]; i++)
    {
        [fakeItems addObject:[NSNumber numberWithInt:i]];
    }
    return fakeItems;
}


- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
    NSDictionary *indexes = [self indexesForCurrentIndex:_currentIndex];
    
    self.topStackNotShown =     [[indexes valueForKey:TOP_STACK_NOT_SHOWN] integerValue];
    self.topStackShown =        [[indexes valueForKey:TOP_STACK_SHOWN] integerValue];
    self.bottomStackShown =     [[indexes valueForKey:BOTTOM_STACK_SHOWN] integerValue];
    self.bottomStackNotShown =  [[indexes valueForKey:BOTTOM_STACK_NOT_SHOWN] integerValue];
    self.bottomStackHidden =    [[indexes valueForKey:BOTTOM_STACK_HIDDEN] integerValue];
}


- (NSDictionary *)indexesForCurrentIndex:(NSInteger)currentIndex
{
    NSInteger listSize = (NSInteger)[self.items count];
    
    NSInteger topStackNotShown = (listSize - currentIndex - TOP_MAX_SHOWN) > 0 ? (listSize - currentIndex - TOP_MAX_SHOWN) : 0;
    NSInteger topStackShown = (listSize - currentIndex) > TOP_MAX_SHOWN ? TOP_MAX_SHOWN : (listSize - currentIndex);
    NSInteger bottomStackShown = currentIndex > BOTTOM_MAX_SHOWN ? BOTTOM_MAX_SHOWN : currentIndex;
    NSInteger bottomStackNotShown = (listSize - topStackNotShown - topStackShown - bottomStackShown) > BOTTOM_MAX_NOT_SHOWN ?
    BOTTOM_MAX_NOT_SHOWN : (listSize - topStackNotShown - topStackShown - bottomStackShown);
    NSInteger bottomStackHidden = (listSize - topStackNotShown - topStackShown - bottomStackShown - bottomStackNotShown);
    
    NSDictionary *indexes = @{TOP_STACK_NOT_SHOWN :     [NSNumber numberWithInteger:topStackNotShown],
                              TOP_STACK_SHOWN :         [NSNumber numberWithInteger:topStackShown],
                              BOTTOM_STACK_SHOWN :      [NSNumber numberWithInteger:bottomStackShown],
                              BOTTOM_STACK_NOT_SHOWN :  [NSNumber numberWithInteger:bottomStackNotShown],
                              BOTTOM_STACK_HIDDEN :     [NSNumber numberWithInteger:bottomStackHidden]};
    return indexes;
}


- (void)setupViewsWithArray:(NSArray *)items
{
    for(NSNumber *object in items)
    {
        AccordionItemView *view = [self viewForObject:object];
        [self.items addObject:view];
        [self.view insertSubview:view atIndex:0];
    }
    
    [self setupFrames];
}


- (AccordionItemView *)viewForObject:(NSNumber *)object
{
    AccordionItemView *view = [[AccordionItemView alloc] initWithDelegate:self];
    UILabel *label = [[UILabel alloc] init];
    
    view.backgroundColor = [self stackColor];
    label.text = [NSString stringWithFormat:@"%i", [object intValue]];
    label.backgroundColor = view.backgroundColor;
    [view addSubview:label];
    label.frame = CGRectMake(5, 2, 20, 15);
    return view;
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
             view.frame = CGRectMake(HORIZONTAL_OFFSET,
                                     [yOriginsArray[i] floatValue],
                                     CARD_WIDTH,
                                     CARD_HEIGHT);
         }
                         completion:nil];
        
        self.items[i] = view;
    }
    
    self.currentView = ((UIView *)self.items[self.currentIndex]);
}


- (NSMutableArray *)yOriginsForCurrentIndex:(NSInteger)currentIndex
{
    NSMutableArray *yOriginsArray = [NSMutableArray array];
    
    NSDictionary *indexes = [self indexesForCurrentIndex:currentIndex];
    NSInteger topStackNotShown =    [[indexes valueForKey:TOP_STACK_NOT_SHOWN]      integerValue];
    NSInteger topStackShown =       [[indexes valueForKey:TOP_STACK_SHOWN]          integerValue];
    NSInteger bottomStackShown =    [[indexes valueForKey:BOTTOM_STACK_SHOWN]       integerValue];
    NSInteger bottomStackNotShown = [[indexes valueForKey:BOTTOM_STACK_NOT_SHOWN]   integerValue];
    NSInteger bottomStackHidden =   [[indexes valueForKey:BOTTOM_STACK_HIDDEN]      integerValue];
    
    int j = 1;
    int k = 1;
    
    for (int i = 0; i < [self.items count]; i++)
    {
        CGFloat yOrigin;
        
        if(i < bottomStackHidden)                                                                 //bottom hidden cards
        {
            yOrigin = self.view.frame.size.height;
        }
        else if((bottomStackNotShown > 0) && (i < currentIndex - BOTTOM_MAX_SHOWN))               //bottom not shown cards
        {
            yOrigin = self.view.frame.size.height - j*BOTTOM_NOT_SHOWN_HEIGHT;
            j++;
        }
        else if((bottomStackNotShown > 0) && (i < currentIndex))                                  //bottom cards
        {
            yOrigin = [yOriginsArray[i-1] floatValue] - BOTTOM_SHOWN_HEIGHT;
        }
        else if((bottomStackNotShown == 0) && (i < bottomStackShown))                             //bottom shown cards only
        {
            yOrigin = self.view.frame.size.height -(i+1)*BOTTOM_SHOWN_HEIGHT;
        }
        else if (i == currentIndex)                                                               //current card
        {
            yOrigin = CARD_ORIGIN_Y;
        }
        else if ((topStackShown > 1) && (i < currentIndex + TOP_MAX_SHOWN))                       //top shown cards
        {
            yOrigin = CARD_ORIGIN_Y - k*TOP_SHOWN_HEIGHT;
            k++;
        }
        else if ((topStackNotShown > 0) && (i < (currentIndex+TOP_MAX_SHOWN+TOP_MAX_NOT_SHOWN))) //top not shown cards
        {
            yOrigin = [yOriginsArray[i-1] floatValue] - (TOP_STACK_NOT_SHOWN_HEIGHT/TOP_MAX_NOT_SHOWN);
        }
        else
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
    [self.view addGestureRecognizer:swipeGestureRecognizerDown];
    
    UISwipeGestureRecognizer *swipeGestureRecognizerUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                                   action:@selector(didSwipeUp:)];
    swipeGestureRecognizerUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeGestureRecognizerUp.delegate = self;
    [self.view addGestureRecognizer:swipeGestureRecognizerUp];
}


- (void)didSwipeDown:(UISwipeGestureRecognizer *)recognizer
{
    //NSLog(@"didSwipeDown");
    
    if(self.currentIndex < [self.items count] - 1)
    {
        self.currentIndex++;
        [self setupFrames];
    }
}


- (void)didSwipeUp:(UISwipeGestureRecognizer *)recognizer
{
    //NSLog(@"didSwipeUp");
    
    if (self.currentIndex !=0)
    {
        self.currentIndex--;
        [self setupFrames];
    }
}


- (void)didPan:(UIPanGestureRecognizer *)recognizer
          view:(AccordionItemView *)view
{
    CGPoint touchLocation = [recognizer locationInView:self.view];
    NSInteger index = [self.items indexOfObject:view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (index != self.currentIndex)
    {
        if(velocity.y > 0)
        {
            self.currentIndex = (index < ([self.items count]-1)) ? index+1 : index;
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
        //NSLog(@"UIGestureRecognizerStateBegan");
        //self.originalDirectionDown = [recognizer velocityInView:self.view].y > 0 ? TRUE : FALSE;
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
        //NSLog(@"UIGestureRecognizerStateChanged");
        
        if(self.dragging)
        {
            [self scrollWithLocation:touchLocation
                            velocity:velocity];
        }
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        //NSLog(@"UIGestureRecognizerStateEnded");
        
        if(self.dragging)
        {
            [self scrollItemsToFinalPosition:self.items
                                    velocity:velocity];
            
            self.dragging = NO;
        }
    }
}


- (void)didTap:(UITapGestureRecognizer *)recognizer
          view:(AccordionItemView *)view
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
    NSArray *yOriginsArrayUp = [self yOriginsForCurrentIndex:self.currentIndex - 1];
    NSArray *yOriginsArrayNow = [self yOriginsForCurrentIndex:self.currentIndex];
    NSArray *yOriginsArrayDown = [self yOriginsForCurrentIndex:self.currentIndex + 1];
    
    NSArray *yOriginsArray = [NSArray array];
    
    CGFloat currentViewPossibleYOrigin = touchLocation.y + self.touchOffset.y - CARD_HEIGHT/2;
    CGFloat xOffset = -5;
    
    if((currentViewPossibleYOrigin <= [yOriginsArrayDown[self.currentIndex] floatValue]) &&
       (currentViewPossibleYOrigin >= [yOriginsArrayUp[self.currentIndex] floatValue]))
    {
        if(((touchLocation.x + self.touchOffset.x - CARD_WIDTH/2) <= self.view.frame.origin.x - xOffset) ||
           ((touchLocation.x + self.touchOffset.x + CARD_WIDTH/2) >= self.view.frame.size.width + xOffset))
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
    else
    {
        if(!(((touchLocation.x + self.touchOffset.x - CARD_WIDTH/2) <= self.view.frame.origin.x - xOffset) ||
             ((touchLocation.x + self.touchOffset.x + CARD_WIDTH/2) >= self.view.frame.size.width + xOffset)))
        {
            self.currentView.center = CGPointMake(touchLocation.x + self.touchOffset.x,
                                                  self.currentView.center.y);
        }
    }
    
    CGFloat scrollPercentage = [self scrollPercentageWithVelocity:velocity];
    
    if ((self.currentView.frame.origin.y >= CARD_ORIGIN_Y))
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
                ((UIView *)self.items[self.currentIndex - 1]).frame = [self setFrameWithScrollPercentage:scrollPercentage
                                                                                                  origin:([yOriginsArrayNow[self.currentIndex - 1] floatValue])
                                                                                                     end:([yOriginsArrayNow[self.currentIndex - 1] floatValue] - NEXT_CARD_VERTICAL_DISTANCE)];
            }
        }
        else
        {
            self.originalDirection = NO;
            yOriginsArray = yOriginsArrayNow;
            yOriginsArrayNow = yOriginsArrayUp;
            
            if (self.currentIndex != 0)
            {
                ((UIView *)self.items[self.currentIndex - 1]).frame = [self setFrameWithScrollPercentage:scrollPercentage
                                                                                                  origin:([yOriginsArray[self.currentIndex - 1] floatValue] - NEXT_CARD_VERTICAL_DISTANCE)
                                                                                                     end:([yOriginsArray[self.currentIndex - 1] floatValue])];
            }
        }
    }
    
    for (int i = self.currentIndex - 1; i < [self.items count]; i++)
    {
        UIView *view = ((UIView *)self.items[i]);
        
        if (i == (self.currentIndex - 1))
        {
            
        }
        else if(i != self.currentIndex)
        {
            view.frame = [self setFrameWithScrollPercentage:scrollPercentage
                                                     origin:[yOriginsArrayNow[i] floatValue]
                                                        end:[yOriginsArray[i] floatValue]];
        }
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
    if (fabsf(velocity.y) > 300)
    {
        return 0.1;
    }
    else if (fabsf(velocity.y) > 200)
    {
        return 0.2;
    }
    
    return 0.3;
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
    
    if ((self.currentView.frame.origin.y >= CARD_ORIGIN_Y))
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


- (CGRect)setFrameWithScrollPercentage:(CGFloat)scrollPercentage
                                origin:(CGFloat)origin
                                   end:(CGFloat)end
{
    CGRect rect = CGRectMake(HORIZONTAL_OFFSET,
                             origin + scrollPercentage*(end-origin),
                             CARD_WIDTH,
                             CARD_HEIGHT);
    return rect;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Delete when finished
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor *)stackColor
{
    static int colorNumber = 0;
    colorNumber = colorNumber % 8;
    colorNumber++;
    
    switch (colorNumber)
    {
        case 0:
            return [UIColor blackColor];
            break;
        case 1:
            return [UIColor orangeColor];
            break;
        case 2:
            return [UIColor yellowColor];
            break;
        case 3:
            return [UIColor greenColor];
            break;
        case 4:
            return [UIColor blueColor];
            break;
        case 5:
            return [UIColor redColor];
            break;
        case 6:
            return [UIColor whiteColor];
            break;
        case 7:
            return [UIColor brownColor];
            break;
        case 8:
            return [UIColor magentaColor];
            break;
        default:
            break;
    }
    return [UIColor blackColor];
}


@end


