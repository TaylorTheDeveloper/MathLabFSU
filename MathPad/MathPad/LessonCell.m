//
//  LessonCell.m
//  MathPad
//
//  Created by Alex Muller on 8/15/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "LessonCell.h"

@implementation LessonCell

@synthesize sectionLabel = _sectionLabel;
@synthesize descriptionLabel = _descriptionLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 70, 30)];
        _sectionLabel.font = [UIFont systemFontOfSize:13];
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 240, 55)];
        _descriptionLabel.numberOfLines = 0;
        _descriptionLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_sectionLabel];
        [self.contentView addSubview:_descriptionLabel];
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
