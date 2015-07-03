//
//  KPAccordionConfiguration.h
//  KPAccardion
//
//  Created by Inigo Mato on 7/3/13.
//  Copyright (c) 2013 Inigo Mato. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * STACK HEIGHTS
 *
 * TOP_STACK_NOT_SHOWN_HEIGHT       - The height in pixels of the top not shown stack
 * TOP_STACK_SHOWN_HEIGHT           - The height in pixels of the top shown cards
 * BOTTOM_STACK_SHOWN_HEIGHT        - The height in pixels of the bottom stack shown cards
 * BOTTOM_STACK_NOT_SHOWN_HEIGHT    - The height in pixels of the bottom stack not shown cards
 *
 */
#define TOP_STACK_NOT_SHOWN_HEIGHT      35
#define TOP_STACK_SHOWN_HEIGHT          35
#define BOTTOM_STACK_SHOWN_HEIGHT       20
#define BOTTOM_STACK_NOT_SHOWN_HEIGHT   10


/*
 * STACK AMOUNTS
 *
 * TOP_STACK_MAX_NOT_SHOWN_AMOUNT       - The max amount of cards that are almost not showing up on the top stack
 * TOP_STACK_MAX_SHOWN_AMOUNT           - The max amount of cards that are showing up on the top stack
 * BOTTOM_STACK_MAX_SHOWN_AMOUNT        - The max amount of cards that are showing up on the bottom stack
 * BOTTOM_STACK_MAX_NOT_SHOWN_AMOUNT    - The max amount of cards that are almost not showing up on the bottom stack
 *
 */
#define TOP_STACK_MAX_NOT_SHOWN_AMOUNT        2
#define TOP_STACK_MAX_SHOWN_AMOUNT            3
#define BOTTOM_STACK_MAX_SHOWN_AMOUNT         2
#define BOTTOM_STACK_MAX_NOT_SHOWN_AMOUNT     3

/*
 * ACCORDION VARIABLES
 *
 * CURRENT_CARD_Y_ORIGIN        - The Y origin of the current view
 * NEXT_CARD_VERTICAL_DISTANCE  - The max amount of pixels that the view previous to the current one will show up when pulling the latter.
 * HORIZONTAL_MARGIN_INSET      - The amount of pixels used for the horizontal margin when dragging the current view
 * STARTING_CURRENT_INDEX       - The desired index of the current view in order to set the initial status of the whole view
 *
 */
#define CURRENT_CARD_Y_ORIGIN           150
#define NEXT_CARD_VERTICAL_DISTANCE     30
#define HORIZONTAL_MARGIN_INSET         5
#define STARTING_CURRENT_INDEX          1

//SPEED VARIABLES

/*
 * SPEED VARIABLES
 *
 * SPEED_MEDIUM_FAST_THRESHOLD  - Threshold taken by trial error from the velocity.y variable in the UIPanGestureRecognizer
 * SPEED_FAST_THRESHOLD         - Threshold taken by trial error from the velocity.y variable in the UIPanGestureRecognizer
 * SLOW_SPEED                   - Animation duration used by default
 * MEDIUM_SPEED                 - Animation duration used when speed is higher than SPEED_MEDIUM_FAST_THRESHOLD
 * FAST_SPEED                   - Animation duration used when speed is higher than SPEED_FAST_THRESHOLD
 *
 */
#define SPEED_MEDIUM_FAST_THRESHOLD     200
#define SPEED_FAST_THRESHOLD            300
#define SLOW_SPEED                      0.3
#define MEDIUM_SPEED                    0.2
#define FAST_SPEED                      0.1