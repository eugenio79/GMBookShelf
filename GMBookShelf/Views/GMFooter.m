//
//  GMFooter.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 06/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMFooter.h"

@interface GMFooter() {
    BOOL _started;
}
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actInd;
@end

@implementation GMFooter

- (void)layoutSubviews {
    if (!_started && self.actInd != nil)
        [self.actInd startAnimating];
}

@end
