#import "common.h"
#import "XPToastWindowController.h"

@implementation XPToastWindow
- (BOOL)_ignoresHitTest{
    return YES;
}

+ (BOOL)_isSecure{
    return YES;
}
@end

static int kWidth = 40;
static int kHeight = 15;
static float kPositionY = 0;
static float kPositionX = 0;
static CGAffineTransform newTransform;

static void orientationChanged()
{
    [[XPToastWindowController sharedInstance] orientationChanged];
}

@implementation XPToastWindowController
@synthesize toastWindow, label, backView, content;
/*
+ (void)load {
    @autoreleasepool {
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                
                BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                
                if (isSpringBoard) {
                    [self sharedInstance];
                    
                }
            }
        }
    }
}
*/
+ (instancetype)sharedInstance {
    static dispatch_once_t once = 0;
    __strong static id sharedInstance = nil;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    if ((self = [super init])) {
        _messagingCenter = [CPDistributedMessagingCenter centerNamed:kIPCCenterToast];
        rocketbootstrap_distributedmessagingcenter_apply(_messagingCenter);
        
        [_messagingCenter runServerOnCurrentThread];
        [_messagingCenter registerForMessageName:@"showToastRequest" target:self selector:@selector(showToastRequest:withUserInfo:)];
        
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("com.apple.springboard.screenchanged"), NULL, 0);
        CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("UIWindowDidRotateNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
    }
    
    
    return self;
}

-(void)dismissToastWithDelay{
    [UIView animateWithDuration:0.2
                     animations:^{
        self.toastWindow.alpha = 0.0;}
                     completion:^(BOOL finished){ [self.toastWindow setHidden:YES]; }];
}

-(NSDictionary *)updateToastXY{
    int xLoc;
    int yLoc;
    UIDeviceOrientation orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
    float kScreenW = [[UIScreen mainScreen] bounds].size.width;
    float kScreenH = [[UIScreen mainScreen] bounds].size.height;
    
    float positionX = kPositionX;
    float positionY = kPositionY;
    
#define DegreesToRadians(degrees) (degrees * M_PI / 180)
    switch (orientation) {
        case UIDeviceOrientationLandscapeRight: {
            yLoc = (kScreenW*positionX)-(kWidth/2);
            xLoc = (kScreenH*positionY);
            newTransform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            yLoc = (kScreenW*positionX)-(kWidth/2);
            xLoc = kScreenH-(kScreenH*positionY);
            newTransform = CGAffineTransformMakeRotation(DegreesToRadians(90));
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            yLoc = (kScreenH*positionY)-(kHeight/2);
            xLoc = (kScreenW*positionX)-(kWidth/2);
            //HBLogDebug(@"TOAST X: %d, Y: %d", yLoc, xLoc);
            newTransform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            break;
        }
        case UIDeviceOrientationPortrait:
        default: {
            yLoc = (kScreenH*positionY);
            xLoc = (kScreenW*positionX)-(kWidth/2);
            newTransform = CGAffineTransformMakeRotation(DegreesToRadians(0));
            break;
        }
    }
    return @{@"kLocX":[NSNumber numberWithInt:xLoc],@"kLocY":[NSNumber numberWithInt:yLoc]};
}

- (NSDictionary *)orientationChanged
{
    //if (![toastWindow isHidden]){
    NSDictionary *transformation = [self updateToastXY];
    
    if (![toastWindow isHidden]){
        [UIView animateWithDuration:0.3f animations:^{
            [toastWindow setTransform:newTransform];
            CGRect frame = toastWindow.frame;
            frame.origin.y = [transformation[@"kLocY"] intValue];
            frame.origin.x = [transformation[@"kLocX"] intValue];
            toastWindow.frame = frame;
        } completion:nil];
    }else{
        [toastWindow setTransform:newTransform];
        CGRect frame = toastWindow.frame;
        frame.origin.y = [transformation[@"kLocY"] intValue];
        frame.origin.x = [transformation[@"kLocX"] intValue];
        toastWindow.frame = frame;
    }
    return transformation;
    //}
}



-(void)presentToastWindowWithMessage:(NSString *)kMessage Width:(int)kWidth Height:(int)kHeight X:(int)kLocX Y:(int)kLocY Alpha:(float)kAlpha Radius:(float)kRadius backgroundColor:(UIColor *)kColor textColor:(UIColor *)kColorLabel numberOfLines:(int)kLines imagePath:(NSString *)kImagePath imageTint:(UIColor *)kImageTint displayType:(int)kDisplayType{
            //float kScreenW = [[UIScreen mainScreen] bounds].size.width;
            //float kScreenH = [[UIScreen mainScreen] bounds].size.height;
            
            toastWindow = [[XPToastWindow alloc] initWithFrame:CGRectMake(kLocX, kLocY, kWidth, kHeight)];
            toastWindow.windowLevel = 9999999999;
            [toastWindow setHidden:YES];
            toastWindow.alpha = kAlpha;
            [toastWindow _setSecure:YES];
            [toastWindow setUserInteractionEnabled:NO];
            toastWindow.layer.cornerRadius = kRadius;
            toastWindow.layer.masksToBounds = YES;
            toastWindow.layer.shouldRasterize  = NO;
            
            backView = [UIView new];
            backView.frame = CGRectMake(0, 0, toastWindow.frame.size.width, toastWindow.frame.size.height);
            backView.backgroundColor = kColor;
            backView.alpha = kAlpha;
            [(UIView *)toastWindow addSubview:backView];
            
            content = [UIView new];
            content.alpha = 0.9f;
            content.frame = CGRectMake(4, 0, toastWindow.frame.size.width-8, toastWindow.frame.size.height);
            label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, content.frame.size.width, content.frame.size.height)];
            label.numberOfLines = kLines;
            label.textColor = kColorLabel;
            label.baselineAdjustment = YES;
            label.adjustsFontSizeToFitWidth = YES;
            //label.adjustsLetterSpacingToFitWidth = YES;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = kMessage;
            [content addSubview:label];
            
            if (kDisplayType == 1){
                [(UIView *)toastWindow addSubview:content];
            }else{
                UIImage *toastImage;
                if (@available(iOS 13.0, *)){
                    if ([kImagePath containsString:@"CUSTOM_"]){
                        NSString *customImagePath = [kImagePath stringByReplacingOccurrencesOfString:@"CUSTOM_" withString:@""];
                        toastImage = [[UIImage imageWithContentsOfFile:customImagePath] imageWithTintColor:kImageTint];
                    }else{
                        toastImage = [UIImage systemImageNamed:kImagePath];
                    }
                }else{
                    if ([kImagePath containsString:@"CUSTOM_"]){
                        NSString *customImagePath = [kImagePath stringByReplacingOccurrencesOfString:@"CUSTOM_" withString:@""];
                        toastImage = [[UIImage imageWithContentsOfFile:customImagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    }else{
                        toastImage = [UIImage imageNamed:kImagePath inBundle:[NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/UIKitCore.framework/Artwork.bundle"] compatibleWithTraitCollection:NULL];
                    }
                }
                UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(4, 4, toastWindow.frame.size.width-8, toastWindow.frame.size.height-8)];
                image.image = toastImage;
                image.tintColor = kImageTint;
                [(UIView *)toastWindow addSubview:image];
            }
            

}


-(BOOL)_ignoresHitTest {
    return YES;
}

-(UIColor *)convertStringToColor:(NSString *)colorname{
    CIColor *coreColor = [CIColor colorWithString:colorname];
    UIColor *color = [UIColor colorWithRed:coreColor.red green:coreColor.green blue:coreColor.blue alpha:coreColor.alpha];
    return color;
}

- (NSDictionary *)showToastRequest:(NSString *)name withUserInfo:(NSDictionary *)userInfo{
    int kLocX = 0;
    int kLocY = 0;
    float kAlpha = [[userInfo objectForKey:@"alpha"] floatValue];
    float kRadius = [[userInfo objectForKey:@"radius"] floatValue];
    int kLines = 1;
    kWidth = [[userInfo objectForKey:@"width"] intValue];
    kHeight = [[userInfo objectForKey:@"height"] intValue];
    kPositionX = [[userInfo objectForKey:@"positionX"] floatValue];
    kPositionY = [[userInfo objectForKey:@"positionY"] floatValue];
    NSString *kImagePath = [userInfo objectForKey:@"imagepath"];
    NSString *kMessage = [userInfo objectForKey:@"message"];
    UIColor *kColorLabel = [self convertStringToColor:[userInfo objectForKey:@"textColor"]];
    UIColor *kColor = [self convertStringToColor:[userInfo objectForKey:@"backgroundColor"]];
    UIColor *kImageTint = [self convertStringToColor:[userInfo objectForKey:@"imagetint"]];
    double t = [[userInfo objectForKey:@"duration"] doubleValue];
    int kDisplayType = [[userInfo objectForKey:@"displayType"] intValue];

    [self presentToastWindowWithMessage:(NSString *)kMessage Width:kWidth Height:kHeight X:kLocX Y:kLocY Alpha:kAlpha Radius:kRadius backgroundColor:kColor textColor:kColorLabel numberOfLines:kLines imagePath:kImagePath imageTint:kImageTint displayType:kDisplayType];
    [self orientationChanged];
    [toastWindow setHidden:NO];
    
    [UIView animateWithDuration:0.2
                     animations:^{
        toastWindow.alpha = 1.0;
    }
                     completion:nil];
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissToastWithDelay) object:self];
    [self performSelector:@selector(dismissToastWithDelay) withObject:self afterDelay:t];
    return @{};
}
@end
