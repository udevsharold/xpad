#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface XPPGesturePickerController : PSListController{
    UILabel *_label;
}
@property (nonatomic,readwrite) NSString *identifier;
@property (nonatomic, strong) NSArray *fullOrder;
@end

@interface PSSpecifier (XPPGesturePickerController)
-(void)setValues:(id)arg1 titles:(id)arg2;
@end
