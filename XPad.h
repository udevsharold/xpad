#import "XPToastWindowController.h"
#import <RocketBootstrap/rocketbootstrap.h>
#import "XPShortcutsGenerator.h"

#ifdef __cplusplus
extern "C" {
#endif

void showCopypastaWithNotification() __attribute__((weak));
void flipLoupeEnableSwitch(BOOL enable) __attribute__((weak));
BOOL loupeSwitchState() __attribute__((weak));

#ifdef __cplusplus
}
#endif

@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
@end


@interface UIKeyboardExtensionInputMode : UITextInputMode
-(BOOL)isDefaultRightToLeft;
@end

@protocol UITextInputTraits_Private <NSObject,UITextInputTraits>
@property (assign,nonatomic) CFCharacterSetRef textTrimmingSet;
@property (assign,nonatomic) unsigned long long insertionPointWidth;
@property (assign,nonatomic) int textLoupeVisibility;
@property (assign,nonatomic) int textSelectionBehavior;
@property (assign,nonatomic) id textSuggestionDelegate;
@property (assign,nonatomic) BOOL isSingleLineDocument;
@property (assign,nonatomic) BOOL contentsIsSingleValue;
@property (assign,nonatomic) BOOL acceptsEmoji;
@property (assign,nonatomic) BOOL forceEnableDictation;
@property (assign,nonatomic) int emptyContentReturnKeyType;
@property (assign,nonatomic) BOOL returnKeyGoesToNextResponder;
@property (assign,nonatomic) BOOL acceptsFloatingKeyboard;
@property (assign,nonatomic) BOOL acceptsSplitKeyboard;
@property (assign,nonatomic) BOOL displaySecureTextUsingPlainText;
@property (assign,nonatomic) BOOL learnsCorrections;
@property (assign,nonatomic) int shortcutConversionType;
@property (assign,nonatomic) BOOL suppressReturnKeyStyling;
@property (assign,nonatomic) BOOL useInterfaceLanguageForLocalization;
@property (assign,nonatomic) BOOL deferBecomingResponder;
@property (assign,nonatomic) BOOL enablesReturnKeyOnNonWhiteSpaceContent;
@property (assign,nonatomic) BOOL disablePrediction;
@optional
-(int)textSelectionBehavior;
-(BOOL)displaySecureTextUsingPlainText;
-(CFCharacterSetRef)textTrimmingSet;
-(BOOL)acceptsSplitKeyboard;
-(int)shortcutConversionType;
-(BOOL)acceptsFloatingKeyboard;
-(BOOL)disablePrediction;
-(BOOL)learnsCorrections;
-(void)setLearnsCorrections:(BOOL)arg1;
-(void)setTextTrimmingSet:(CFCharacterSetRef)arg1;
-(unsigned long long)insertionPointWidth;
-(void)setInsertionPointWidth:(unsigned long long)arg1;
-(int)textLoupeVisibility;
-(void)setTextLoupeVisibility:(int)arg1;
-(void)setTextSelectionBehavior:(int)arg1;
-(id)textSuggestionDelegate;
-(void)setTextSuggestionDelegate:(id)arg1;
-(BOOL)isSingleLineDocument;
-(void)setIsSingleLineDocument:(BOOL)arg1;
-(BOOL)contentsIsSingleValue;
-(void)setContentsIsSingleValue:(BOOL)arg1;
-(BOOL)acceptsEmoji;
-(void)setAcceptsEmoji:(BOOL)arg1;
-(BOOL)forceEnableDictation;
-(void)setForceEnableDictation:(BOOL)arg1;
-(int)emptyContentReturnKeyType;
-(void)setEmptyContentReturnKeyType:(int)arg1;
-(BOOL)returnKeyGoesToNextResponder;
-(void)setReturnKeyGoesToNextResponder:(BOOL)arg1;
-(void)setAcceptsFloatingKeyboard:(BOOL)arg1;
-(void)setAcceptsSplitKeyboard:(BOOL)arg1;
-(void)setDisplaySecureTextUsingPlainText:(BOOL)arg1;
-(void)setShortcutConversionType:(int)arg1;
-(BOOL)suppressReturnKeyStyling;
-(void)setSuppressReturnKeyStyling:(BOOL)arg1;
-(BOOL)useInterfaceLanguageForLocalization;
-(void)setUseInterfaceLanguageForLocalization:(BOOL)arg1;
-(BOOL)deferBecomingResponder;
-(void)setDeferBecomingResponder:(BOOL)arg1;
-(BOOL)enablesReturnKeyOnNonWhiteSpaceContent;
-(void)setEnablesReturnKeyOnNonWhiteSpaceContent:(BOOL)arg1;
-(void)setDisablePrediction:(BOOL)arg1;

@required
-(void)takeTraitsFrom:(id)arg1;

@end

@protocol UITextInputPrivate <UITextInput,UITextInputTokenizer,UITextInputTraits_Private>
@property (nonatomic,readonly) UITextInteractionAssistant * interactionAssistant;
@property (assign,nonatomic) long long selectionGranularity;
@optional
-(void)replaceRangeWithTextWithoutClosingTyping:(id)arg1 replacementText:(id)arg2;
-(void)insertDictationResult:(id)arg1 withCorrectionIdentifier:(id)arg2;
-(id)rangeWithTextAlternatives:(id*)arg1 atPosition:(id)arg2;
-(id)metadataDictionariesForDictationResults;
-(id)textColorForCaretSelection;
-(long long)selectionGranularity;
-(void)setSelectionGranularity:(long long)arg1;
-(id)automaticallySelectedOverlay;
-(void)setBottomBufferHeight:(double)arg1;
-(BOOL)requiresKeyEvents;
-(void)handleKeyWebEvent:(id)arg1;
-(void)streamingDictationDidBegin;
-(void)streamingDictationDidEnd;
-(void)acceptedAutoFillWord:(id)arg1;
-(BOOL)isAutoFillMode;
-(double)_delayUntilRepeatInsertText:(id)arg1;
-(BOOL)_shouldRepeatInsertText:(id)arg1;
-(id)fontForCaretSelection;
-(void)_insertAttributedTextWithoutClosingTyping:(id)arg1;

@required
-(UITextInteractionAssistant *)interactionAssistant;
-(id)textInputTraits;
-(void)selectAll;
-(NSRange*)selectionRange;
-(BOOL)hasSelection;
-(BOOL)hasContent;

@end


@interface UITextInputAssistantItem  (XPXPad)
@property (setter=_setDetachedTintColor:,getter=_detachedTintColor,nonatomic,retain) UIColor * detachedTintColor;
@property (nonatomic,copy) NSArray * leadingBarButtonGroups;
@end

@interface UIBarButtonItemGroup (XPXPad)
@property (getter=_items,nonatomic,readonly) NSArray * items;
@end

@interface TUIAssistantButtonBarView : UIView
@property (nonatomic,retain) NSArray  *buttonGroups;
@end

@interface TUIPredictionView : UIView
@end

@interface TUISystemInputAssistantView : UIView
@property (nonatomic,retain) TUIAssistantButtonBarView * leftButtonBar;
@property (nonatomic,retain) TUIAssistantButtonBarView * unifiedButtonBar;
@property (nonatomic,readonly) id  predictionView;
@property (nonatomic,retain) UIView * centerView;
@property (assign,nonatomic) BOOL centerViewHidden;
@property (nonatomic,retain) UITextInputAssistantItem * systemInputAssistantItem;
@end

@interface UISystemInputAssistantViewController : NSObject
@property (nonatomic,readonly) UITextInputAssistantItem *inputAssistantItem;
@property (assign,nonatomic) UITextInputAssistantItem * observedInputAssistantItem;
@property (nonatomic,readonly) TUISystemInputAssistantView * systemInputAssistantView;
-(id)_defaultTintColor;
-(void)installGesturesForButtonGroupIndex:(NSInteger)groupindex groups:(NSArray <UIBarButtonItemGroup *> *)groups popOver:(BOOL)popOver;

@end

@interface UIInputResponderController : NSObject
@property (nonatomic,readonly) UISystemInputAssistantViewController * systemInputAssistantViewController;
+(void)initialize;
@end


@interface _UIKBRTKeyboardTouchObserver : NSObject
@property (nonatomic,retain) NSMutableDictionary * touches;
@end

@interface _UIKBRTFingerDetection : _UIKBRTKeyboardTouchObserver
@end

@interface UIKeyboardLayout : UIView
@property (nonatomic,retain) _UIKBRTFingerDetection * fingerDetection;
@property (nonatomic,readonly) long long orientation;
@end

@interface UIKeyboardImpl : UIView{
    UIKeyboardLayout* m_layout;
}
+(UIWindow *)keyboardWindow;
+(CGPoint)floatingNormalizedPersistentOffset;
+(CGPoint)floatingPersistentOffset;
+ (UIKeyboardImpl*)activeInstance;
+(CGPoint)_screenPointFromNormalizedPoint:(CGPoint)arg1 ;
+(CGPoint)normalizedPersistentOffset;
+(id)keyboardScreen;
+(BOOL)isFloating;
- (BOOL)isLongPress;
- (void)handleDelete;
- (void)insertText:(id)text;
- (void)clearAnimations;
- (void)clearTransientState;
- (void)setCaretBlinks:(BOOL)arg1;
- (void)deleteFromInput;
- (void)dismissKeyboard;
-(void)pasteOperation;
-(void)cutOperation;
-(void)copyOperation;
-(void)deleteFromInput;
-(BOOL)caretVisible;
-(BOOL)caretBlinks;
-(BOOL)isUsingDictationLayout;
-(void)clearSelection;
-(void)flushDelayedTasks;
-(void)dismissKeyboard;
-(void)deleteBackward;
-(BOOL)deleteForwardAndNotify:(BOOL)arg1 ;
@property (readonly, assign, nonatomic) UIResponder <UITextInputPrivate> *privateInputDelegate;
@property (readonly, assign, nonatomic) UIResponder <UITextInput> *inputDelegate;
@property (nonatomic,readonly) UIResponder <UITextInput> *selectableInputDelegate;
@end

@interface _UIButtonBarButton  : UIControl 

@end

@interface UIBarButtonItem(XPXPad)
-(_UIButtonBarButton *)view;
-(void)_setGestureRecognizers:(id)arg1 ;
@end

/*
 //crashed in microsoft apps
@interface UIWindow (iOS13)
@end

@implementation UIWindow (iOS13)
+ (UIWindow*)keyWindow{
   NSPredicate *isKeyWindow = [NSPredicate predicateWithFormat:@"isKeyWindow == YES"];
   return [[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate:isKeyWindow].firstObject;
}

@end
*/

@interface PSRootController : UIViewController
- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier;
@end

@interface PSListController : UIViewController
- (instancetype)initForContentSize:(CGSize)contentSize;
@property (nonatomic, retain) PSRootController *rootController;
@property (nonatomic, retain) UIViewController *parentController;
@end

typedef enum PSCellType {
    PSGroupCell,
    PSLinkCell,
    PSLinkListCell,
    PSListItemCell,
    PSTitleValueCell,
    PSSliderCell,
    PSSwitchCell,
    PSStaticTextCell,
    PSEditTextCell,
    PSSegmentCell,
    PSGiantIconCell,
    PSGiantCell,
    PSSecureEditTextCell,
    PSButtonCell,
    PSEditTextViewCell,
} PSCellType;

@interface PSSpecifier : NSObject
@property (nonatomic, retain) NSString *identifier;
+ (instancetype)preferenceSpecifierNamed:(NSString *)name target:(id)target set:(SEL)setter get:(SEL)getter detail:(Class)detailClass cell:(PSCellType)cellType edit:(Class)editClass;
@end

@interface KeyboardController : PSListController
-(id)init;
-(id)specifierByName:(id)arg1 ;
-(NSArray *)loadAllKeyboardPreferences;
-(void)setKeyboardPreferenceValue:(id)arg1 forSpecifier:(id)arg2 ;
@end

@interface WKContentView : NSObject
-(void)executeEditCommandWithCallback:(id)arg1;
-(void)_defineForWebView:(id)arg1 ;
-(void)_showDictionary:(id)arg1 ;
-(void)selectWordBackward;
-(void)_define:(id)arg1 ;
-(void)_selectionChanged;
-(void)_updateChangedSelection:(BOOL)arg1 ;
-(id)selectedText;
-(void)select:(id)arg1 ;
-(id)_moveToStartOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
-(void)moveBackward:(unsigned)arg1 ;
-(id)_moveLeft:(BOOL)arg1 withHistory:(id)arg2 ;
-(void)moveForward:(unsigned)arg1 ;
-(id)_moveRight:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveDown:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveUp:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfDocument:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfDocument:(BOOL)arg1 withHistory:(id)arg2 ;
- (void)clearSelection;
-(void)setSelectedTextRange:(UITextRange *)arg1 ;
- (void)endSelectionChange;
- (void)beginSelectionChange;
@end


@interface UIResponder(Private)
@property (nonatomic,readonly) UIKeyboardExtensionInputMode * textInputMode;
@property (nonatomic,readonly) NSArray * keyCommands;
@property (nonatomic,readonly) UIResponder * _editingDelegate;
@property (nonatomic,readonly) UIResponder * _responderForEditing;
@property (nonatomic,readonly) UIResponder * nextResponder;
- (void)_define:(NSString *)text;
-(id)targetForAction:(SEL)arg1 withSender:(id)arg2 ;
-(id)_moveToStartOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfLine:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfParagraph:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToStartOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
-(id)_moveToEndOfWord:(BOOL)arg1 withHistory:(id)arg2 ;
- (void)clearSelection;
-(id)_rangeOfParagraphEnclosingPosition:(id)arg1 ;
-(id)_rangeOfLineEnclosingPosition:(id)arg1 ;
-(id)_rangeOfSentenceEnclosingPosition:(id)arg1 ;
- (void)_setSelectionToPosition:(UITextPosition *)arg1;
-(void)_setSelectedTextRange:(id)arg1 withAffinityDownstream:(BOOL)arg2 ;
-(id)_setSelectionRangeWithHistory:(id)arg1 ;
-(void)_updateSelectionWithTextRange:(id)arg1 withAffinityDownstream:(BOOL)arg2 ;
-(id)textRangeFromPosition:(id)arg1 toPosition:(id)arg2 ;
-(void)moveByOffset:(long long)arg1 ;
- (void)beginSelectionInDirection:(long long)arg1 atPoint:(CGPoint)arg2 completionHandler:(id)arg2;
-(CGPoint)lastInteractionLocation;
-(void)selectWordBackward;
-(void)_becomeFirstResponderWithSelectionMovingForward:(BOOL)arg1 completionHandler:(/*^block*/id)arg2 ;
-(BOOL)becomeFirstResponder;
-(BOOL)becomeFirstResponderForWebView;
-(UITextInteractionAssistant *)interactionAssistant;
-(id)webView;
@end

//Safari
@protocol UnifiedFieldDelegate <UITextFieldDelegate>
@required
-(void)unifiedFieldShouldPasteAndNavigate:(id)arg1;
-(void)unifiedField:(id)arg1 didEndEditingWithParsecTopHit:(id)arg2;
-(void)unifiedField:(id)arg1 didEndEditingWithAddress:(id)arg2;
-(void)unifiedField:(id)arg1 didEndEditingWithSearch:(id)arg2;
-(char)unifiedField:(id)arg1 shouldWaitForTopHitForText:(id)arg2;
-(id)unifiedField:(id)arg1 topHitForText:(id)arg2;
-(void)unifiedFieldReflectedItemDidChange:(id)arg1;
-(void)unifiedField:(id)arg1 registerKeyCommandsUsingBlock:(/*^block*/id)arg2;
-(char)unifiedField:(id)arg1 canPerformAction:(SEL)arg2 withSender:(id)arg3;

@end

@interface UnifiedField : UITextField
@property (assign,nonatomic) id<UnifiedFieldDelegate> delegate;
@end

@interface TLCHelper : NSObject
+(void)fetchTranslation:(NSString *)text vc:(UIViewController *)vc;
@end

@interface TZManager : NSObject
+(instancetype)sharedManager;
- (void)translateTextWithShortmojiShortcut:(NSString *)text  showInAlert:(BOOL)show;
- (void)translateText:(NSString *)text;
@end

@interface UIKeyboardInputMode : UITextInputMode
-(NSString *)identifier;
-(NSString *)normalizedIdentifier;
@end

@interface UIKeyboardInputModeController : NSObject
@property (retain) UIKeyboardInputMode * currentInputMode;
@property (retain) NSArray * keyboardInputModes;
+(id)sharedInputModeController;
-(id)activeInputModes;
-(void)setCurrentInputMode:(UIKeyboardInputMode *)arg1;

@end

@interface UIDictationController : NSObject
-(void)switchToDictationInputMode;
-(void)switchToDictationInputModeWithTouch:(id)arg1 ;
-(void)cancelDictation;
-(void)switchToDictationInputModeWithTouch:(id)arg1 withKeyboardInputMode:(id)arg2 ;
-(void)setDictationInputMode:(id)arg1 ;
-(void)stopDictation:(BOOL)arg1;
@end

@interface UISystemDefaultTextInputAssistantItem : UITextInputAssistantItem
@property (assign,getter=_isSystemItem,nonatomic) BOOL systemItem;
@property (nonatomic,retain) NSArray * defaultSystemLeadingBarButtonGroups;
@property (nonatomic,retain) NSArray * defaultSystemTrailingBarButtonGroups;
@end
