#import "ToastWindowController.h"
#import <RocketBootstrap/rocketbootstrap.h>
#include "ShortcutsGenerator.h"

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


@interface UITextInputAssistantItem  (XPad)
@property (nonatomic,copy) NSArray * leadingBarButtonGroups;
@end

@interface UIBarButtonItemGroup (XPad)
@property (getter=_items,nonatomic,readonly) NSArray * items;
@end

@interface TUIAssistantButtonBarView : UIView
@property (nonatomic,retain) NSArray  *buttonGroups;
@end

@interface TUISystemInputAssistantView : UIView
@property (nonatomic,retain) TUIAssistantButtonBarView * leftButtonBar;
@property (nonatomic,readonly) id  predictionView;
@property (nonatomic,retain) UIView * centerView;
@property (assign,nonatomic) BOOL centerViewHidden;
@property (nonatomic,retain) UITextInputAssistantItem * systemInputAssistantItem;
@end

@interface XPad : NSObject
@property (nonatomic,strong) TUISystemInputAssistantView *xpadAssistantView;
@property (nonatomic, strong) UIBarButtonItemGroup *XPadShortcutsGroup;
@property (nonatomic, strong) UIBarButtonItemGroup *XPadShortcutsBundleGroup;
@property (nonatomic, strong) UIBarButtonItem *bundleButton;
@property (nonatomic, strong) NSMutableArray *XPadShortcuts;
@property (nonatomic, strong) NSMutableArray *XPadShortcutsBundle;
@property (strong, nonatomic) NSMutableArray *kbType;
@property (strong, nonatomic) NSMutableArray *kbTypeLabel;
@property (nonatomic, assign) NSInteger trueKBType;
@property (nonatomic, strong) NSArray *XPadShortcutsDetails;
@property (nonatomic, assign) BOOL setLongPressGesture;
//@property (nonatomic, assign) BOOL shouldAddCopyLogButton;
@property (nonatomic, assign) BOOL refreshView;
@property (nonatomic, assign) TUISystemInputAssistantView * systemInputAssistantView;
@property (nonatomic, assign) NSTimer *cursorTimer;
@property (nonatomic, assign) NSTimer *cursorTimerRetest;
@property (nonatomic, assign) NSInteger cursorMovingFactor;
@property (nonatomic, assign) float cursorTimerSpeed;
@property (nonatomic, assign) float t;
@property (nonatomic, assign) BOOL isSameProcess;
@property (strong, nonatomic) UIBarButtonItem *autoCorrectionButton;
@property (strong, nonatomic) UIBarButtonItem *autoCapitalizationButton;
@property (strong, nonatomic) UIBarButtonItem *keyboardInputTypeButton;
@property (nonatomic, assign) BOOL autoCorrectionEnabled;
@property (nonatomic, assign) BOOL autoCapitalizationEnabled;
@property (nonatomic, strong) dispatch_block_t retestDispatchBlock;
@property (strong, nonatomic) CPDistributedMessagingCenter *xpadCenter;
@property (strong, nonatomic) CPDistributedMessagingCenter *toastCenter;
@property (strong, nonatomic) NSString *commandTitle;
@property (nonatomic, assign) NSInteger insertTextActionType;
@property (nonatomic, assign) BOOL moveCursorWithSelect;
@property (nonatomic, assign) BOOL isWordSender;
@property (nonatomic, strong) dispatch_block_t centerViewChangedDispatchBlock;
@property (nonatomic, assign) BOOL asyncUpdated;
@property (nonatomic, strong) NSString *parentActionName;
@property (strong, nonatomic) ShortcutsGenerator *shortcutsGenerator;

-(void)shakeButton:(UIBarButtonItem *)sender;
-(void)shakeView:(UIView *)sender;
-(IBAction)selectAllAction:(UIBarButtonItem*)sender;
-(IBAction)copyAction:(UIBarButtonItem*)sender;
-(IBAction)pasteAction:(UIBarButtonItem*)sender;
-(IBAction)cutAction:(UIBarButtonItem*)sender;
-(IBAction)undoAction:(UIBarButtonItem*)sender;
-(IBAction)redoAction:(UIBarButtonItem*)sender;
-(IBAction)selectAction:(UIBarButtonItem*)sender;
-(IBAction)beginningAction:(UIBarButtonItem*)sender;
-(IBAction)endingAction:(UIBarButtonItem*)sender;
-(IBAction)capitalizeAction:(UIBarButtonItem*)sender;
-(IBAction)lowercaseAction:(UIBarButtonItem*)sender;
-(IBAction)uppercaseAction:(UIBarButtonItem*)sender;
-(IBAction)deleteAction:(UIBarButtonItem*)sender;
-(IBAction)deleteAllAction:(UIBarButtonItem*)sender;
-(IBAction)boldAction:(UIBarButtonItem*)sender;
-(IBAction)italicAction:(UIBarButtonItem*)sender;
-(IBAction)underlineAction:(UIBarButtonItem*)sender;
-(IBAction)dismissKeyboardAction:(UIBarButtonItem*)sender;
-(void)moveCursorLeftAction:(UIBarButtonItem*)sender;
-(void)moveCursorRightAction:(UIBarButtonItem*)sender;
-(void)moveCursorUpAction:(UIBarButtonItem*)sender;
-(void)moveCursorDownAction:(UIBarButtonItem*)sender;
-(void)keyboardTypeAction:(UIBarButtonItem*)sender;
-(void)defineAction:(UIBarButtonItem*)sender;
-(void)runCommandAction:(UIBarButtonItem*)sender;
-(void)insertTextAction:(UIBarButtonItem*)sender;
-(void)selectLineAction:(UIBarButtonItem*)sender;
-(void)selectParagraphAction:(UIBarButtonItem*)sender;
-(void)selectSentenceAction:(UIBarButtonItem*)sender;
-(void)moveCursorPreviousWordAction:(UIBarButtonItem*)sender;
-(void)moveCursorNextWordAction:(UIBarButtonItem*)sender;
-(void)moveCursorStartOfLineAction:(UIBarButtonItem*)sender;
-(void)moveCursorEndOfLineAction:(UIBarButtonItem*)sender;
-(void)moveCursorStartOfParagraphAction:(UIBarButtonItem*)sender;
-(void)moveCursorEndOfParagraphAction:(UIBarButtonItem*)sender;
-(void)moveCursorStartOfSentenceAction:(UIBarButtonItem*)sender;
-(void)moveCursorEndOfSentenceAction:(UIBarButtonItem*)sender;
-(void)copyLogAction:(UIBarButtonItem*)sender;
-(void)translomaticAction:(UIBarButtonItem *)sender;
-(void)wasabiAction:(UIBarButtonItem *)sender;
-(void)pasitheaAction:(UIBarButtonItem*)sender;
-(void)globeAction:(UIBarButtonItem*)sender;
-(void)dictationAction:(UIBarButtonItem*)sender;
-(void)deleteForwardAction:(UIBarButtonItem*)sender;

-(void)selectAllActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)copyActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)pasteActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)cutActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)undoActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)redoActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)selectActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)beginningActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)endingActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)capitalizeActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)lowercaseActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)uppercaseActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)deleteActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)boldActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)italicActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)underlineActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)dismissKeyboardActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorLeftActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorRightActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorUpActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorDownActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)keyboardTypeActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)defineActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)runCommandActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)insertTextActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)selectLineActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)selectParagraphActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)selectSentenceActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)moveCursorPreviousWordActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorNextWordActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorStartOfLineActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorEndOfLineActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorStartOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorEndOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorStartOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)moveCursorEndOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer;
-(UIWindow*)keyWindow;
-(void)translomaticActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)wasabiActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)pasitheaActionLP:(UILongPressGestureRecognizer *)recognizer;
-(void)activateLPActions:(UIGestureRecognizer *)recognizer;
-(void)globeActionLP:(UILongPressGestureRecognizer*)recognizer;
-(void)deleteForwardActionLP:(UILongPressGestureRecognizer *)recognizer;

-(void)moveCursorContinuoslyWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset;
-(void)openLog;
-(NSString *)convertColorToString:(UIColor *)colorname;
-(NSString *)getImageNameForActionName:(NSString *)actionname;
-(void)sendShowToastRequestWithMessage:(NSString *)message imagePath:(NSString *)imagepath imageTint:(UIColor *)imagetint width:(int)width height:(int)height positionX:(float)positionX positionY:(float)positionY duration:(double)duration alpha:(float)alpha radius:(float)radius textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor displayType:(int)displayType;
-(void)triggerImpactAndAnimationWithButton:(UIBarButtonItem *)sender selectorName:(NSString *)selname toastWidthOffset:(int)woffset toastHeightOffset:(int)hoffset;
-(NSDictionary *)locationForMode:(int)mode assistantView:(TUISystemInputAssistantView *)assistantView actionName:(NSString *)actionName;
-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate;
-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction;
-(UITextRange *)autoDirectionWordSelectedTextRangeWithDelegate:(id<UITextInput> )delegate;

-(UITextRange *)singleWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction;
-(UITextRange *)lineExtremityTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextLayoutDirection)direction;
-(void)moveCursorSingleWordWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextStorageDirection)direction;
-(void)moveCursorToLineExtremityWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextLayoutDirection)direction;

-(UIWindow*)keyWindow;
- (int)currentCursorPosition:(id <UITextInput, UITextInputTokenizer>)delegate;
-(void)moveCursorWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset;
-(BOOL)isRTLForDelegate:(id <UITextInput, UITextInputTokenizer>)delegate;
-(CPDistributedMessagingCenter *)IPCCenterNamed:(NSString *)centerName;
-(BOOL)isAutoCorrectionEnabled;
-(void)setAutoCorrection:(BOOL)enabled;
-(void)updateAutoCorrection:(NSNotification*)notification;
-(BOOL)isAutoCapitalizationEnabled;
-(void)setAutoCapitalization:(BOOL)enabled;
-(void)updateAutoCapitalization:(NSNotification*)notification;
-(NSDictionary *)getItemWithID:(NSString *)snippetID forKey:(NSString *)keyName identifierKey:(NSString *)identifier;
-(void)runCommand:(NSString *)cmd;
-(NSUInteger)getShortcutIndexWithActionNamed:(NSString *)actionName;
-(BOOL)isValidURL:(NSString *)urlString;
@end

@interface UISystemInputAssistantViewController : NSObject
@property (nonatomic,readonly) UITextInputAssistantItem *inputAssistantItem;
@property (assign,nonatomic) UITextInputAssistantItem * observedInputAssistantItem;
@property (nonatomic,readonly) TUISystemInputAssistantView * systemInputAssistantView;
-(id)_defaultTintColor;
@property (nonatomic, retain) XPad *xpad;
-(void)installGesturesForButtonGroupIndex:(NSInteger)groupindex assistantView:(TUISystemInputAssistantView *)assistantView popOver:(BOOL)popOver;

@end

@interface UIInputResponderController : NSObject
@property (nonatomic,readonly) UISystemInputAssistantViewController * systemInputAssistantViewController;
+(void)initialize;
@end

@interface UIKeyboardImpl : UIView
+ (UIKeyboardImpl*)activeInstance;
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

@interface UIBarButtonItem(XPad)
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
