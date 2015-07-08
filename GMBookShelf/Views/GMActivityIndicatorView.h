//
//  GMActivityIndicatorView.h
//  GMBookShelf
//
//  Created by Giuseppe Morana on 05/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMActivityIndicatorView : UIView

+ (instancetype)createIndicatorForView:(UIView *)view;

- (void)show;
- (void)hide;

@end
