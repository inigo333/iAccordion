//
//  KPItemView.h
//  KPAccardion
//
//  Created by Inigo Mato on 7/1/13.
//  Copyright (c) 2013 Inigo Mato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccordionItemView : UIView

@property (nonatomic, weak) id delegate;

- (id)initWithDelegate:(id)delegate;

@end
