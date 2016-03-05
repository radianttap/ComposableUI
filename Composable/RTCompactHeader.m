//
//  RTCompactHeader.m
//  ComposableUI
//
//  Created by Aleksandar Vacić on 5.3.16..
//  Copyright © 2016. Radiant Tap. All rights reserved.
//

#import "RTCommon.h"
#import "RTCompactHeader.h"

@interface RTCompactHeader ()

@property (nonatomic, weak) IBOutlet UILabel *captionLabel;

@end

@implementation RTCompactHeader

+ (NSString *)reuseIdentifier {
	return [NSStringFromClass([self class]) uppercaseString];
}

+ (UINib *)nib {
	return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (instancetype)nibInstance {
	return [[[self nib] instantiateWithOwner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
	[super awakeFromNib];

	self.backgroundColor = [UIColor clearColor];
}

@end
