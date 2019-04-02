//
//  GlobalegrowSubmitNoteView.m
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/5.
//

#import "GlobalegrowSubmitNoteView.h"
#import <Masonry/Masonry.h>

@interface GlobalegrowSubmitNoteView ()

/**
 备注的文本提示框
 */
@property (nonatomic, strong) UILabel *noteTitleLabel;
/**
 备注的文本框
 */
@property (nonatomic, strong) UITextView *noteTextView;
/**
 取消的按钮
 */
@property (nonatomic, strong) UIButton *cancelButton;
/**
 提交备注的按钮
 */
@property (nonatomic, strong) UIButton *submitNoteButton;

@end

@implementation GlobalegrowSubmitNoteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor colorWithRed:1 green:0.855 blue:0.227 alpha:1];
        [self addSubview:self.noteTitleLabel];
        [self addSubview:self.noteTextView];
        [self addSubview:self.cancelButton];
        [self addSubview:self.submitNoteButton];
        [self.noteTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(5);
            make.centerX.equalTo(self);
        }];
        [self.noteTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_offset(20);
            make.trailing.mas_offset(-20);
            make.top.equalTo(self.noteTitleLabel.mas_bottom).offset(5);
            make.height.mas_equalTo(80);
        }];
        [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_offset(20);
            make.width.equalTo(self.submitNoteButton);
            make.bottom.mas_offset(-20);
            make.height.mas_equalTo(40);
        }];
        [self.submitNoteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.width.height.equalTo(self.cancelButton);
            make.trailing.mas_offset(-20);
            make.leading.equalTo(self.cancelButton.mas_trailing).offset(30);
        }];
    }
    return self;
}

- (void)cancelButtonClick {
    if (self.didClickCancelButtonBlock) {
        self.didClickCancelButtonBlock();
    }
}

- (void)submitNoteButtonClick {
    if (self.didClickSubmitNoteButtonClick) {
        self.didClickSubmitNoteButtonClick(self.noteTextView.text);
    }
}

- (CGSize)intrinsicContentSize {
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 40;
    CGFloat height = 5 + self.noteTitleLabel.intrinsicContentSize.height + 5 + 80 + 10 + 40 + 20;
    return CGSizeMake(maxWidth, height);
}

#pragma mark - Getter
- (UITextView *)noteTextView {
    if (!_noteTextView) {
        _noteTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _noteTextView.layer.masksToBounds = YES;
        _noteTextView.layer.cornerRadius = 5;
    }
    return _noteTextView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.backgroundColor = [UIColor whiteColor];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.cornerRadius = 5;
    }
    return _cancelButton;
}

- (UIButton *)submitNoteButton {
    if (!_submitNoteButton) {
        _submitNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_submitNoteButton setTitle:@"Submit" forState:UIControlStateNormal];
        [_submitNoteButton addTarget:self action:@selector(submitNoteButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _submitNoteButton.backgroundColor = [UIColor whiteColor];
        [_submitNoteButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _submitNoteButton.layer.masksToBounds = YES;
        _submitNoteButton.layer.cornerRadius = 5;
    }
    return _submitNoteButton;
}

- (UILabel *)noteTitleLabel {
    if (!_noteTitleLabel) {
        _noteTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _noteTitleLabel.text = @"Please Input Bug Note:";
    }
    return _noteTitleLabel;
}

@end
