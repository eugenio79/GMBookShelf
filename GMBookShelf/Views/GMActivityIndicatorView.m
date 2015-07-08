//
//  GMActivityIndicatorView.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 05/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMActivityIndicatorView.h"

@interface GMActivityIndicatorView() {
    BOOL _visible;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInd;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) UIView *container;
@end

@implementation GMActivityIndicatorView

+ (instancetype)createIndicatorForView:(UIView *)view {
    
    NSAssert(view != nil, @"view should be not nil");
    
    GMActivityIndicatorView *actInd = [[[NSBundle mainBundle] loadNibNamed:@"GMActivityIndicatorView" owner:self options:nil] objectAtIndex:0];
    actInd.container = view;

    return actInd;
}

- (void)show {
    
    if (_visible) return;
    
    [self.container addSubview:self];
    
    self.center = self.container.center;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    [self.actInd startAnimating];
    
    _visible = YES;
}

- (void)hide {
    if (!_visible) return;
    
    [self.actInd stopAnimating];
    [self removeFromSuperview];
    
    _visible = NO;
}


@end
