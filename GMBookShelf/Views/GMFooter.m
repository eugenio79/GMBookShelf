//
//  GMFooter.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 06/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMFooter.h"
#import "GMActivityIndicatorView.h"

@interface GMFooter()
@property (weak, nonatomic) IBOutlet GMActivityIndicatorView *actInd;
@end

@implementation GMFooter

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.actInd = [GMActivityIndicatorView createIndicatorForView:self];
        [self.actInd show];
    }
    return self;
}

@end
