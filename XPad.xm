#import "common.h"
#import "XPXPad.h"
#import "XPHelper.h"
#import "XPShared.h"
#import "XPUIShortTapGestureRecognizer.h"
#import "XPToastWindowController.h"
#import <SparkColourPicker/SparkColourPickerUtils.h>

id delegate;
UIKeyboardImpl *kbImpl;
UIColor *currentTintColor;
UIColor *toastTintColor;
UIColor *toastBackgroundTintColor;
NSMutableDictionary *prefs;
BOOL isCopyLogInstalled = NO;
BOOL isSpringBoard = YES;
BOOL isApplication = NO;
BOOL isSafari = NO;
KeyboardController *kbController;
BOOL shouldUpdateTrueKBType = NO;
UISystemInputAssistantViewController *systemAssistantController;
BOOL doubleTapEnabled  = NO;
NSBundle *tweakBundle;
BOOL firstInit = YES;
DXStudlyCapsType spongebobEntropy;

%group XPAD_GROUP
static XPXPad *xpad;

%hook UIAssistantBarButtonItemProvider
+(UISystemDefaultTextInputAssistantItem *)systemDefaultAssistantItem{
    UISystemDefaultTextInputAssistantItem *defaultAssistantItem = %orig;
    if ([xpad.XPadShortcutsBundleFloat count] > 0 && xpad.XPadShortcutsFloatGroup && xpad.XPadShortcutsBundleFloatGroup){
        defaultAssistantItem.leadingBarButtonGroups = @[xpad.XPadShortcutsFloatGroup, xpad.XPadShortcutsBundleFloatGroup];
    }else if (xpad.XPadShortcutsFloatGroup){
        defaultAssistantItem.leadingBarButtonGroups = @[xpad.XPadShortcutsFloatGroup];
    }
    
    if (xpad.keyboardInputTypeButton){
        kbImpl = [%c(UIKeyboardImpl) activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        xpad.keyboardInputTypeButton.image = [XPHelper imageForName:[delegate respondsToSelector:@selector(keyboardType)]?@"number.circle.fill":@"number.circle" withSystemColor:NO completion:nil];
    }
    return defaultAssistantItem;
}
%end

%hook UISystemInputAssistantViewController
-(BOOL)_shouldShowExpandableButtonBarItemsForResponder:(id)arg1{
    return [%c(UIKeyboardImpl) isFloating] ?: %orig;
}

-(id)init{
    self = %orig;
    xpad = [[XPXPad alloc] init];
    xpad.systemInputAssistantView = self.systemInputAssistantView;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        kbImpl = [%c(UIKeyboardImpl) activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        if ([delegate respondsToSelector:@selector(keyboardType)]){
            if (shouldUpdateTrueKBType){
                xpad.trueKBType = [[NSNumber numberWithInt:[delegate keyboardType]] intValue];
                shouldUpdateTrueKBType = NO;
            }
            NSUInteger index = [xpad.kbType indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]]];
            HBLogDebug(@"indexXXXXX: %lu", index);
            if (index == NSNotFound){
                HBLogDebug(@"INDEXOF: %@", [NSNumber numberWithInt:[delegate keyboardType]]);
                //XPShortcutsGenerator *shortcutsGenerator = [ShortcutsGenerator sharedInstance];
                
                NSArray *kbTypeData = [xpad.shortcutsGenerator keyboardTypeData];
                NSArray *kbTypeLabel = [xpad.shortcutsGenerator keyboardTypeLabel];
                
                NSUInteger indexInArray = [kbTypeData indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]]];
                if (index == NSNotFound){
                    if ([delegate keyboardType] > 12){
                        xpad.trueKBType = 0;
                        shouldUpdateTrueKBType = NO;
                    }else{
                        [xpad.kbType insertObject:[NSNumber numberWithInt:[delegate keyboardType]] atIndex:0];
                        if (indexInArray != NSNotFound){
                            [xpad.kbTypeLabel insertObject:kbTypeLabel[indexInArray] atIndex:0];
                        }else{
                            [xpad.kbTypeLabel insertObject:@"Generic" atIndex:0];
                        }
                    }
                }else{
                    [xpad.kbType insertObject:kbTypeData[indexInArray] atIndex:0];
                    [xpad.kbTypeLabel insertObject:kbTypeLabel[indexInArray] atIndex:0];
                }
                
            }else{
                xpad.trueKBType = 0;
                shouldUpdateTrueKBType = NO;
            }
        }else{
            UIImage *image;
            image = [UIImage systemImageNamed:[delegate respondsToSelector:@selector(keyboardType)]?@"number.circle.fill":@"number.circle"];
            xpad.keyboardInputTypeButton.image = image;
        }
    });
    return systemAssistantController = self;
}

%new
-(void)installGesturesForButtonGroupIndex:(NSInteger)groupindex groups:(NSArray <UIBarButtonItemGroup *> *)groups popOver:(BOOL)popOver{
    int checkedCount = 0;
    int expectedCount = 1;
    if ([groups count]-1 < groupindex) return;
    
    if (doubleTapEnabled) expectedCount += 1;
        
        for (UIBarButtonItem *btn in groups[groupindex].items){
            UIView *btnView = (UIView *)[btn valueForKey:@"view"];
            BOOL isLPAdded = NO;
            BOOL isDTAdded = NO;
            //BOOL isSTAdded = NO;
            
            //if (@available(iOS 13.0, *)){
            
            for (UIGestureRecognizer *recognizer in btnView.gestureRecognizers) {
                if ([recognizer.name containsString:@"XPXPad-LP-"]){
                    isLPAdded = YES;
                    checkedCount += 1;
                    if (checkedCount >= expectedCount) break;
                }
                /*
                 if ([recognizer.name containsString:@"XPXPad-ST-"]){
                 isSTAdded = YES;
                 checkedCount += 1;
                 if (checkedCount >= expectedCount) break;
                 }
                 */
                if ([recognizer.name containsString:@"XPXPad-DT-"]){
                    isDTAdded = YES;
                    checkedCount += 1;
                    if (checkedCount >= expectedCount) break;
                }
            }
            
            if (!isLPAdded){
                HBLogDebug(@"Added gesture");
                UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:xpad action:@selector(activateLPActions:)];
                longPress.minimumPressDuration = 0.5;
                NSString *gestureIdentifier = [NSString stringWithFormat:@"XPXPad-LP-%@",NSStringFromSelector([btn action])];
                longPress.name = gestureIdentifier;
                [btnView addGestureRecognizer:longPress];
            }
            
            //XPUIShortTapGestureRecognizer *singleTap;
            XPUIShortTapGestureRecognizer *doubleTap;
            
            if (doubleTapEnabled && !isDTAdded && !popOver){
                HBLogDebug(@"Added gesture");
                doubleTap = [[XPUIShortTapGestureRecognizer alloc] initWithTarget:xpad action:@selector(activateDTActions:)];
                doubleTap.numberOfTapsRequired = 2;
                NSString *gestureIdentifier = [NSString stringWithFormat:@"XPXPad-DT-%@",NSStringFromSelector([btn action])];
                doubleTap.name = gestureIdentifier;
                [btnView addGestureRecognizer:doubleTap];
            }
            /*
             if (doubleTapEnabled && !isSTAdded){
             HBLogDebug(@"Added gesture");
             singleTap = [[XPUIShortTapGestureRecognizer alloc] initWithTarget:xpad action:btn.action];
             singleTap.numberOfTapsRequired = 1;
             NSString *gestureIdentifier = [NSString stringWithFormat:@"XPXPad-ST-%@",NSStringFromSelector([btn action])];
             singleTap.name = gestureIdentifier;
             [singleTap requireGestureRecognizerToFail:doubleTap];
             [btnView addGestureRecognizer:singleTap];
             
             }
             */
            
        }
}

-(void)prepareForPopoverPresentation:(id)arg1{
    //[xpad runCommand:@"stb"];
    %orig;
    [self installGesturesForButtonGroupIndex:1 groups:self.systemInputAssistantView.leftButtonBar.buttonGroups popOver:YES];
}

-(void)setCenterViewController:(id)arg1{
    %orig;
    if (!self.systemInputAssistantView.centerViewHidden){
        if (!xpad.centerViewChangedDispatchBlock){
            xpad.centerViewChangedDispatchBlock = dispatch_block_create(static_cast<dispatch_block_flags_t>(0), ^{
                if (self){
                    [self installGesturesForButtonGroupIndex:1 groups:self.systemInputAssistantView.leftButtonBar.buttonGroups popOver:NO];
                }
                xpad.centerViewChangedDispatchBlock = nil;
            });
            
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), xpad.centerViewChangedDispatchBlock);
    }
    
}


-(TUISystemInputAssistantView *)systemInputAssistantView{
    TUISystemInputAssistantView *assistantView = %orig;
    //HBLogDebug(@"GROUP: %@", assistantView.leftButtonBar.buttonGroups);
    /*
     if (xpad.shouldAddCopyLogButton && isCopyLogInstalled && [assistantView.leftButtonBar.buttonGroups count] >0){
     UIBarButtonItem *copyLogButton = [((UIBarButtonItemGroup *)(assistantView.leftButtonBar.buttonGroups)[0]).items lastObject];
     if (copyLogButton && [NSStringFromSelector([copyLogButton action]) isEqualToString:@"openLog"]){
     //HBLogDebug(@"CopyLOG : %@", copyLogButton);
     if (preferencesBool(kCollapseCopyLogkey, NO) && [xpad.XPadShortcutsBundle count] > 0){
     //[xpad.XPadShortcutsBundle addObject:copyLogButton];
     [xpad.XPadShortcutsBundle insertObject:copyLogButton atIndex:0];
     xpad.XPadShortcutsBundleGroup = [[UIBarButtonItemGroup alloc]
     initWithBarButtonItems:xpad.XPadShortcutsBundle representativeItem:xpad.bundleButton];
     }else{
     [xpad.XPadShortcuts addObject:copyLogButton];
     xpad.XPadShortcutsGroup = [[UIBarButtonItemGroup alloc]
     initWithBarButtonItems:xpad.XPadShortcuts representativeItem:nil];
     }
     xpad.shouldAddCopyLogButton = NO;
     
     }
     }
     */
    if ([xpad.XPadShortcutsBundle count] > 0){
        assistantView.leftButtonBar.buttonGroups = @[xpad.XPadShortcutsGroup, xpad.XPadShortcutsBundleGroup];
    }else{
        assistantView.leftButtonBar.buttonGroups = @[xpad.XPadShortcutsGroup];
    }
    
    if (preferencesBool(kColorEnabledkey,NO)){
        if (preferencesBool(kShortcutsTintEnabled,YES)) assistantView.leftButtonBar.tintColor = currentTintColor;
    }
    
    [self installGesturesForButtonGroupIndex:0 groups:assistantView.leftButtonBar.buttonGroups popOver:NO];
    [self installGesturesForButtonGroupIndex:1 groups:assistantView.leftButtonBar.buttonGroups popOver:NO];
	__weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (xpad.XPadShortcutsFloatGroup){
            [weakSelf installGesturesForButtonGroupIndex:0 groups:@[xpad.XPadShortcutsFloatGroup] popOver:NO];
        }
        if (xpad.XPadShortcutsBundleFloatGroup){
            [weakSelf installGesturesForButtonGroupIndex:0 groups:@[xpad.XPadShortcutsBundleFloatGroup] popOver:NO];
        }
    });
    if (xpad.keyboardInputTypeButton){
        kbImpl = [%c(UIKeyboardImpl) activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        xpad.keyboardInputTypeButton.image = [XPHelper imageForName:[delegate respondsToSelector:@selector(keyboardType)]?@"number.circle.fill":@"number.circle" withSystemColor:NO completion:nil];
    }
    return assistantView;
}



%end


%end

static void updateAutoCorrection() {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAutoCorrection" object:nil];
}

static void updateAutoCapitalization() {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAutoCapitalization" object:nil];
}

static void updateLoupe() {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLoupe" object:nil];
}

static void reloadPrefs() {
    
    toastTintColor = toastImageTintColor;
    toastBackgroundTintColor = toastBackgroundColor;
    
    prefs = [[[XPPrefsManager sharedInstance] readPrefsFromSandbox:!isSpringBoard] mutableCopy];
    HBLogDebug(@"prefs: %@", prefs);
    
    if (preferencesBool(kColorEnabledkey,NO)){
        
        if (preferencesBool(kShortcutsTintEnabled,YES)) currentTintColor = [SparkColourPickerUtils colourWithString:prefs[@"shortcutstint"]  withFallback:@"#ff0000"];
        if (preferencesBool(kToastTintEnabled,YES)) toastTintColor = [SparkColourPickerUtils colourWithString:prefs[@"toasttint"]  withFallback:@"#ff0000"];
        if (preferencesBool(kToastBackgroundTintEnabled,YES)) toastBackgroundTintColor = [SparkColourPickerUtils colourWithString:prefs[@"toastbackgroundtint"]  withFallback:@"#000000"];
    }
    
    doubleTapEnabled = preferencesBool(kEnabledDoubleTapkey, NO);
    spongebobEntropy = preferencesInt(kSpongebobEntropyKey, DXStudlyCapsTypeRandom);
    
    if (isSpringBoard && !firstInit){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[[XPPrefsManager sharedInstance] setValue:@YES forKey:kUpdateCachekey fromSandbox:!isSpringBoard];
            [[XPPrefsManager sharedInstance] removeKey:kCachekey fromSandbox:!isSpringBoard];
        });
    }
    
    if (firstInit){
        if (isSpringBoard){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                XPShortcutsGenerator *shortcutsGenerator = [XPShortcutsGenerator sharedInstance];
                
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:prefs[kCachekey] error:nil];
                unarchiver.requiresSecureCoding = NO;
                int cacheDylibSum = [[unarchiver decodeObjectForKey:@"copyLogDylibExist"] intValue] + [[unarchiver decodeObjectForKey:@"translomaticDylibExist"] intValue] + [[unarchiver decodeObjectForKey:@"wasabiDylibExist"] intValue] + [[unarchiver decodeObjectForKey:@"pasitheaDylibExist"] intValue] + [[unarchiver decodeObjectForKey:@"copypastaDylibExist"] intValue] + [[unarchiver decodeObjectForKey:@"loupeDylibExist"] intValue] + [[unarchiver decodeObjectForKey:@"tranzloDylibExist"] intValue];
                int actualDylibSum = [@(shortcutsGenerator.copyLogDylibExist) intValue] + [@(shortcutsGenerator.translomaticDylibExist) intValue] + [@(shortcutsGenerator.wasabiDylibExist) intValue] + [@(shortcutsGenerator.pasitheaDylibExist) intValue] + [@(shortcutsGenerator.copypastaDylibExist) intValue] + [@(shortcutsGenerator.loupeDylibExist) intValue] + [@(shortcutsGenerator.tranzloDylibExist) intValue];
                BOOL upgradedFromUnsupportedCache = !([unarchiver containsValueForKey:@"XPadShortcutsFloat"] && [unarchiver containsValueForKey:@"XPadShortcutsBundleFloat"] && [unarchiver containsValueForKey:@"bundleButton"] && [unarchiver containsValueForKey:@"bundleFloatButton"]);
                [unarchiver finishDecoding];
                
                //NSLog(@"XPAD cache: %d ** actual: %d", cacheDylibSum, actualDylibSum);
                if ((prefs[kCachekey] && (cacheDylibSum != actualDylibSum)) || (prefs[kCachekey] && upgradedFromUnsupportedCache)){
                    [[XPPrefsManager sharedInstance] removeKey:kCachekey fromSandbox:!isSpringBoard];
                    //NSLog(@"XPAD cache deleted");
                }
            });
        }
        firstInit = NO;
    }
}

static void sbDidLaunch(){
    [XPToastWindowController sharedInstance];
}

%ctor {
    
    @autoreleasepool {
        
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            
            if (executablePath){
                NSString *processName = [executablePath lastPathComponent];
                
                isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
				isApplication = isApplication ?: ([executablePath rangeOfString:@".appex/"].location != NSNotFound ?: isApplication);
                //isApplication = [processName isEqualToString:@"MarkupPhotoExtension"] ?: isApplication;
                isSafari = [processName isEqualToString:@"MobileSafari"];
				HBLogDebug(@"isSpringBoard: %d ** isApplication: %d ** isSafari: %d", isSpringBoard, isApplication, isSafari);

                //HBLogDebug(@"processName: %@", processName);
                if (isSpringBoard || isApplication){
                    tweakBundle = [NSBundle bundleWithPath:bundlePath];
                    [tweakBundle load];
                    firstInit = YES;
                    reloadPrefs();
                    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/CopyLog.dylib"]){
                        isCopyLogInstalled = YES;
                    }
                    if (preferencesBool(kEnabledkey,YES)){
                        %init(XPAD_GROUP);
                    }
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)reloadPrefs, (CFStringRef)kPrefsChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateAutoCorrection, (CFStringRef)kAutoCorrectionChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateAutoCapitalization, (CFStringRef)kAutoCapitalizationChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)updateLoupe, (CFStringRef)kLoupeChangedIdentifier, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                }
                if (isSpringBoard){
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)sbDidLaunch, (CFStringRef)@"SBSpringBoardDidLaunchNotification", NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                }
                
            }
        }
    }
}
