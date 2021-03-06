//
//  GlobalegrowSubmitNoteView.h
//  GlobalegrowBugTagSDK
//
//  Created by 张行 on 2019/3/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalegrowSubmitNoteView : UIView

@property (nonatomic, copy) void (^didClickCancelButtonBlock)(void);
@property (nonatomic, copy) void (^didClickSubmitNoteButtonClick)(NSString *note);



@end

NS_ASSUME_NONNULL_END
