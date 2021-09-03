#import "common.h"
#import "XPad.h"

extern id delegate;
extern UIKeyboardImpl *kbImpl;
extern UIColor *currentTintColor;
extern UIColor *toastTintColor;
extern UIColor *toastBackgroundTintColor;
extern NSMutableDictionary *prefs;
extern BOOL isCopyLogInstalled;
extern BOOL isSpringBoard;
extern BOOL isApplication;
extern BOOL isSafari;
extern KeyboardController *kbController;
extern BOOL shouldUpdateTrueKBType;
extern UISystemInputAssistantViewController *systemAssistantController;
extern BOOL doubleTapEnabled ;
extern NSBundle *tweakBundle;
extern BOOL firstInit;
extern DXStudlyCapsType spongebobEntropy;

#ifdef __cplusplus
extern "C" {
#endif

BOOL preferencesBool(NSString* key, BOOL fallback);
float preferencesFloat(NSString* key, float fallback);
int preferencesInt(NSString* key, int fallback);
long long preferencesLongLong(NSString* key, long long fallback);
NSString *preferencesSelectorForIdentifier(NSString* identifier, int selectorNum, int gestureType, NSString *fallback);

void showCopypastaWithNotification() __attribute__((weak));
void flipLoupeEnableSwitch(BOOL enable) __attribute__((weak));
BOOL loupeSwitchState() __attribute__((weak));

#ifdef __cplusplus
}
#endif
