//
//  SDTimeLineCellOperationMenu.m
//  GSD_WeiXin(wechat)
//
//  Created by aier on 16/4/2.
//  Copyright © 2016年 GSD. All rights reserved.
//

#import "RadiumFriendsCircleCellOperationMenu.h"
#import <SDAutoLayout/SDAutoLayout.h>
#define SDColor(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]

@implementation RadiumFriendsCircleCellOperationMenu
{
    UIButton *_likeButton;
    UIButton *_commentButton;
    UIButton *_shareButton;
    UIButton *_complaintsButton;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    self.backgroundColor = SDColor(69, 74, 76, 1);
    
    _likeButton = [self creatButtonWithTitle:@"赞赏" image:[UIImage imageNamed:@"home_hongbao"] selImage:[UIImage imageNamed:@""] target:self selector:@selector(likeButtonClicked)];
    _commentButton = [self creatButtonWithTitle:@"评论" image:[UIImage imageNamed:@"home_comment"] selImage:[UIImage imageNamed:@""] target:self selector:@selector(commentButtonClicked)];
    _shareButton = [self creatButtonWithTitle:@"分享" image:[UIImage imageNamed:@"home_share"] selImage:[UIImage imageNamed:@""] target:self selector:@selector(shareButtonClicked)];
    
    _complaintsButton = [self creatButtonWithTitle:@"举报" image:[UIImage imageNamed:@"jubao"] selImage:[UIImage imageNamed:@""] target:self selector:@selector(complaintsButtonClicked)];
    
    UIView *centerLine = [UIView new];
    centerLine.backgroundColor = [UIColor grayColor];
    
    UIView *centerLine2 = [UIView new];
    centerLine2.backgroundColor = [UIColor grayColor];
    
    UIView *centerLine3 = [UIView new];
    centerLine3.backgroundColor = [UIColor grayColor];
    
    [self sd_addSubviews:@[_likeButton, _commentButton,_shareButton, _complaintsButton, centerLine,centerLine2,centerLine3]];
    
    CGFloat margin = 5;
    
    _likeButton.sd_layout
    .leftSpaceToView(self, margin)
    .topEqualToView(self)
    .bottomEqualToView(self)
    .widthIs(50);
    
    centerLine.sd_layout
    .leftSpaceToView(_likeButton, margin)
    .topSpaceToView(self, margin)
    .bottomSpaceToView(self, margin)
    .widthIs(1);
    
    
    
    _commentButton.sd_layout
    .leftSpaceToView(centerLine, margin)
    .topEqualToView(_likeButton)
    .bottomEqualToView(_likeButton)
    .widthRatioToView(_likeButton, 1);
    
    centerLine2.sd_layout
    .leftSpaceToView(_commentButton, margin)
    .topSpaceToView(self, margin)
    .bottomSpaceToView(self, margin)
    .widthIs(1);
    
    _shareButton.sd_layout
    .leftSpaceToView(centerLine2, margin)
    .topEqualToView(_commentButton)
    .bottomEqualToView(_commentButton)
    .widthRatioToView(_commentButton, 1);
    
    centerLine3.sd_layout
    .leftSpaceToView(_shareButton, margin)
    .topSpaceToView(self, margin)
    .bottomSpaceToView(self, margin)
    .widthIs(1);
    
    _complaintsButton.sd_layout
    .leftSpaceToView(centerLine3, margin)
    .topEqualToView(_shareButton)
    .bottomEqualToView(_shareButton)
    .widthRatioToView(_shareButton, 1);
}

- (UIButton *)creatButtonWithTitle:(NSString *)title image:(UIImage *)image selImage:(UIImage *)selImage target:(id)target selector:(SEL)sel
{
    UIButton *btn = [UIButton new];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:selImage forState:UIControlStateSelected];
    [btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    return btn;
}

- (void)likeButtonClicked
{
    if (self.likeButtonClickedOperation) {
        self.likeButtonClickedOperation();
    }
    self.show = NO;
}

- (void)commentButtonClicked
{
    if (self.commentButtonClickedOperation) {
        self.commentButtonClickedOperation();
    }
    self.show = NO;
}
- (void)shareButtonClicked{
    if (self.shareButtonClickedOperation) {
        self.shareButtonClickedOperation();
    }
    self.show = NO;

}

- (void)complaintsButtonClicked {
    if (self.complaintsButtonClickedOperation) {
        self.complaintsButtonClickedOperation();
    }
    self.show = NO;
}

- (void)setShow:(BOOL)show
{
    _show = show;
    
    [UIView animateWithDuration:0.2 animations:^{
        if (!show) {
            [self clearAutoWidthSettings];
            self.sd_layout
            .widthIs(0);
        } else {
            self.fixedWidth = nil;
            [self setupAutoWidthWithRightView:_complaintsButton rightMargin:5];
        }
        [self updateLayoutWithCellContentView:self.superview];
    }];
}

@end
