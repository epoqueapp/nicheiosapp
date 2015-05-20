//
//  NCMessageTableViewCell.m
//  Niche
//
//  Created by Maximilian Alexander on 3/21/15.
//  Copyright (c) 2015 Epoque. All rights reserved.
//

#import "NCMessageTableViewCell.h"

@implementation NCMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self configureSubviews];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

-(void)configureSubviews{
    [self.contentView addSubview:self.spriteImageView];
    [self.contentView addSubview:self.userNameLabel];
    [self.contentView addSubview:self.textMessageLabel];
    [self.contentView addSubview:self.attachmentImageView];
    [self.contentView addSubview:self.timeLabel];
    
    NSDictionary *views = @{@"spriteImageView": self.spriteImageView,
                            @"userNameLabel": self.userNameLabel,
                            @"textMessageLabel": self.textMessageLabel,
                            @"attachmentImageView": self.attachmentImageView,
                            @"timeLabel": self.timeLabel
                            };
    
    NSDictionary *metrics = @{
                              @"spriteImageViewWidth": @(kAvatarSize),
                              @"spriteImageViewHeight": @(48),
                              @"timeLabelWidth": @(40),
                              @"trailing": @10,
                              @"leading": @10,
                              @"attachmentImageViewSize": @(300),
                              };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[spriteImageView(spriteImageViewWidth)]-trailing-[userNameLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[spriteImageView(spriteImageViewWidth)]-trailing-[textMessageLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[spriteImageView(spriteImageViewWidth)]-trailing-[attachmentImageView]-trailing-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[timeLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-leading-[userNameLabel]-leading-[textMessageLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[timeLabel]-leading-[textMessageLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[spriteImageView]" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[userNameLabel]-leading-[attachmentImageView(>=0,<=attachmentImageViewSize)]-trailing-|" options:0 metrics:metrics views:views]];
    
    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.attachmentImageView.image = nil;
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

-(UILabel *)userNameLabel{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc]init];
        _userNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _userNameLabel.font = [UIFont fontWithName:kTrocchiBoldFontName size:10.0];
        _userNameLabel.numberOfLines = 0;
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedUserNameLabel:)];
        [_userNameLabel addGestureRecognizer:tapGesture];
    }
    return _userNameLabel;
}

-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLabel.font = [UIFont fontWithName:kTrocchiFontName size:10.0];
        _timeLabel.numberOfLines = 0;
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.text = @"3:00pm";
        _timeLabel.userInteractionEnabled = NO;
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

-(void)tappedUserNameLabel:(id)sender{
    if ([self.delegate respondsToSelector:@selector(tappedUserNameLabel:)]) {
        [self.delegate tappedUserNameLabel:self.indexPath];
    }
}

-(TTTAttributedLabel *)textMessageLabel{
    if (!_textMessageLabel) {
        _textMessageLabel = [[TTTAttributedLabel alloc]init];
        _textMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _textMessageLabel.text = @"";
        _textMessageLabel.numberOfLines = 0;
        _textMessageLabel.textColor = [UIColor whiteColor];
        _textMessageLabel.verticalAlignment = VerticalAlignmentTop;
        _textMessageLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        _textMessageLabel.linkAttributes = @{
                                                 NSForegroundColorAttributeName: [UIColor colorWithRed:127.0/255.0 green:211.0/255.0 blue:92.0/255.0 alpha:1.0],
                                                 NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        _textMessageLabel.font = [UIFont fontWithName:kTrocchiFontName size:16.0];
        _textMessageLabel.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
        _textMessageLabel.layer.cornerRadius = 4.0;
        _textMessageLabel.layer.masksToBounds = YES;
        _textMessageLabel.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _textMessageLabel.layer.borderWidth = 1.0;
        _textMessageLabel.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return _textMessageLabel;
}

-(UIImageView *)spriteImageView{
    if (!_spriteImageView) {
        _spriteImageView = [UIImageView new];
        _spriteImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _spriteImageView.userInteractionEnabled = YES;
        _spriteImageView.contentMode = UIViewContentModeScaleAspectFit;
        _spriteImageView.layer.masksToBounds = YES;
        _spriteImageView.layer.magnificationFilter = kCAFilterNearest;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedSpriteImageView:)];
        [_spriteImageView addGestureRecognizer:tapGesture];
    }
    return _spriteImageView;
}

-(void)tappedSpriteImageView:(id)sender{
    if ([self.delegate respondsToSelector:@selector(tappedSpriteImageView:)]) {
        [self.delegate tappedSpriteImageView:self.indexPath];
    }
}

-(UIImageView *)attachmentImageView{
    if (!_attachmentImageView) {
        _attachmentImageView = [UIImageView new];
        _attachmentImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _attachmentImageView.userInteractionEnabled = NO;
        _attachmentImageView.backgroundColor = [UIColor clearColor];
        _attachmentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _attachmentImageView.layer.cornerRadius = 4.0;
        _attachmentImageView.layer.masksToBounds = YES;
    }
    return _attachmentImageView;
}

-(void)setMessageModel:(MessageModel *)messageModel{
    self.userNameLabel.text = messageModel.userName;
    [self.spriteImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.userSpriteUrl]];
    if (![NSString isStringEmpty:messageModel.messageImageUrl]) {
        self.textMessageLabel.hidden = YES;
        self.attachmentImageView.hidden = NO;
        [self.attachmentImageView sd_setImageWithURL:[NSURL URLWithString:messageModel.messageImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    }else{
        self.textMessageLabel.hidden = NO;
        self.attachmentImageView.hidden = YES;
        self.textMessageLabel.text = messageModel.messageText;
    }
    if ([[NSUserDefaults standardUserDefaults].userModel.userId isEqualToString:messageModel.userId]) {
        self.textMessageLabel.backgroundColor = [UIColor colorWithHexString:@"#739DFF" alpha:0.2];
        self.userNameLabel.textColor = [UIColor colorWithHexString:@"#739DFF" alpha:1];
    }else{
        self.textMessageLabel.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.4];
        self.userNameLabel.textColor = [UIColor whiteColor];
    }
    self.timeLabel.text = [messageModel.timestamp tableViewCellTimeString];
}

@end
