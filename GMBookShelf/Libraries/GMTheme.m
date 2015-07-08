//
//  GMThemeManager.m
//  GMBookShelf
//
//  Created by Giuseppe Morana on 08/07/15.
//  Copyright (c) 2015 eugenio. All rights reserved.
//

#import "GMTheme.h"

@implementation GMTheme

+ (UIImage *)placeholder {
    return [UIImage imageNamed:@"placeholder"];
}

+ (UIImage *)placeholderBig {
    return [UIImage imageNamed:@"placeholder_big"];
}

+ (UIColor *)backgroundColor {
    return [UIColor colorWithRed:(243.0f / 255.0f) green:(238.0f / 255.0f) blue:(234.0f / 255.0f) alpha:1.0f];
}

+ (UIColor *)foregroundColor {
    return [UIColor colorWithRed:(113.0f / 255.0f) green:(98.0f / 255.0f) blue:(98.0f / 255.0f) alpha:1.0f];
}

@end
