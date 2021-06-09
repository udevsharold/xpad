#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
#include <HBLog.h>

#import "PrefsManager.h"

#define bundlePath @"/Library/PreferenceBundles/XPadPrefs.bundle"
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]

#define kIdentifier @"com.udevs.xpad"
#define kIPCCenterPrefsManager @"com.udevs.xpad.prefsmanager"
#define kIPCCenterToast @"com.udevs.xpad.toast"
#define kIPCCenterXPad @"com.udevs.xpad"
#define kPrefsChangedIdentifier @"com.udevs.xpad/prefschanged"
#define kAutoCorrectionChangedIdentifier @"com.udevs.xpad/autocorrectionchanged"
#define kAutoCapitalizationChangedIdentifier @"com.udevs.xpad/autocapitalizationchanged"
#define kLoupeChangedIdentifier @"com.udevs.xpad/loupechanged"
#define kPrefsPath @"/var/mobile/Library/Preferences/com.udevs.xpad.plist"

#define kCopyLogOpenVewIdentifier @"me.tomt000.copylog.showView"
#define kPasitheaOpenVewIdentifier @"com.ichitaso.pasithea-showmenu"

#define kEnabledkey @"enabledBOOL"
#define kEnabledHaptickey @"hapticBOOL"
#define kShakeShortcutkey @"shakeBOOL"
#define kToastkey @"toastBOOL"
#define kToastPx @"toastpx"
#define kToastPy @"toastpy"
#define kShortcutskey @"shortcuts"
#define kToastDurationkey @"toastduration"
#define kColorEnabledkey @"colorBOOL"
#define kModekey @"mode"
#define kMaxVisiblekey @"maxvisible"
#define kMaxVisibleFloatkey @"maxvisiblefloat"
#define kCollapseCopyLogkey @"collapsecopylogBOOL"
#define kDisplayTypekey @"displaytype"
#define kCustomActionskey @"customactions"
#define kShortcutsTintEnabled @"shortcutstintBOOL"
#define kToastTintEnabled @"toasttintBOOL"
#define kToastBackgroundTintEnabled @"toastbackgroundtintBOOL"
#define kKeyboardTypekey @"keyboardtype"
#define kPasteAndGoEnabledkey @"pasteandgo"
#define kCustomActionsDTkey @"customactionsdt"
#define kCustomActionsSTkey @"customactionsst"
#define kEnabledDoubleTapkey @"doubletapBOOL"
#define kEnabledSmartDeletekey @"smartdeleteBOOL"
#define kEnabledSmartDeleteForwardkey @"smartdeleteforwardBOOL"
#define kEnabledSkipEmojikey @"skipEmojiInputBOOL"
#define kCachekey @"cache"
#define kUpdateCachekey @"updateCache"

#define toastWidth 50
#define toastHeight 50
#define toastPositionX 0.5f
#define toastPositionY 0.5f
#define toastDuration 0.2
#define toastAlpha 0.95
#define toastRadius 6
#define toastTextColor [UIColor whiteColor]
#define toastBackgroundColor [UIColor blackColor]
#define toastImageTintColor [UIColor whiteColor]

#define kbuttonsImages12 0
#define kbuttonsImages13 1
#define kselectors 2
#define kselectorsLP 3

#define maxShortcuts 8
#define maxdefaultshortcuts 5
#define maxBeforeBundle 4
#define maxBeforeBundleFloat 3

#define maxdefaultshortcutskbtype 3

#define secondActionDelay 0.05

@interface CPDistributedMessagingCenter : NSObject
+ (id)centerNamed:(id)arg1;
- (void)runServerOnCurrentThread;
- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;
- (NSDictionary *)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
@end

@interface SpringBoard : NSObject
- (NSDictionary *)showToastRequest:(NSString *)name withUserInfo:(NSDictionary *)userInfo;
@end

@interface SBSRelaunchAction : NSObject
@property (nonatomic, readonly) unsigned long long options;
@property (nonatomic, readonly, copy) NSString *reason;
@property (nonatomic, readonly, retain) NSURL *targetURL;
+ (id)actionWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (id)initWithReason:(id)arg1 options:(unsigned long long)arg2 targetURL:(id)arg3;
- (unsigned long long)options;
- (id)reason;
- (id)targetURL;

@end

@interface FBSSystemService : NSObject
+ (id)sharedService;
- (void)sendActions:(id)arg1 withResult:(/*^block*/id)arg2;
@end

@interface UIKeyboardPreferencesController : NSObject
@property (assign) long long handBias;
+(UIKeyboardPreferencesController *)sharedPreferencesController;
+(id)valueForPreferenceKey:(id)arg1 domain:(id)arg2 ;
-(void)setHandBias:(long long)arg1 ; //0 -normal,2-left, 1-right
-(BOOL)boolForKey:(int)arg1 ;
-(void)setValue:(id)arg1 forKey:(int)arg2 ;
-(void)synchronizePreferences;
@end
