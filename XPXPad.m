#import "common.h"
#import "XPShared.h"
#import "XPXPad.h"
#import "XPLoremIpsum.h"
#import "XPHelper.h"
#import "XPUIShortTapGestureRecognizer.h"

#import <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <NSTask.h>

@implementation XPXPad
//%property (nonatomic, strong) NSArray *XPadShortcutsGroup;
//%property (nonatomic, strong) NSMutableArray *XPadShortcuts;
//%property (nonatomic, strong) NSArray *XPadShortcutsDetails;
//%property (nonatomic, assign) BOOL refreshView;
//%property (nonatomic, assign) BOOL shouldAddCopyLogButton;

-(void)updateAutoCorrectionButton{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSameProcess = NO;
            self.asyncUpdated = YES;
            [self updateAutoCorrection:nil];
        });
    });
    self.autoCorrectionButton.image = [XPHelper imageForName:self.autoCorrectionEnabled?@"checkmark.circle.fill":@"checkmark.circle" withSystemColor:NO completion:nil];
}

-(void)updateAutoCapitalizationButton{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.autoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSameProcess = NO;
            self.asyncUpdated = YES;
            [self updateAutoCapitalization:nil];
        });
    });
    self.autoCapitalizationButton.image = [XPHelper imageForName:self.autoCapitalizationEnabled?@"shift.fill":@"shift" withSystemColor:NO completion:nil];
}

-(void)updateLoupeButton{
    if (!self.shortcutsGenerator.loupeDylibExist){
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.loupeEnabled = loupeSwitchState();
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isSameProcess = NO;
            self.asyncUpdated = YES;
            [self updateLoupe:nil];
        });
    });
    self.loupeButton.image = [XPHelper imageForName:self.loupeEnabled?@"magnifyingglass.circle.fill":@"magnifyingglass.circle" withSystemColor:NO completion:nil];
}

-(void)updateKeyboardTypeButton{
    dispatch_async(dispatch_get_main_queue(), ^{
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        BOOL keyboardTypeChangable = [delegate respondsToSelector:@selector(keyboardType)];
        self.keyboardInputTypeButton.image = [XPHelper imageForName:keyboardTypeChangable?@"number.circle.fill":@"number.circle" withSystemColor:NO completion:nil];
    });
}

- (instancetype)init{
    if (self = [super init]){
        self.shortcutsGenerator = [XPShortcutsGenerator sharedInstance];
        
        if (!prefs){
            prefs = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPath];
        }
        
        //self.shouldAddCopyLogButton = YES;
        //NSError *error = nil;
        
        if (prefs[kCachekey]){
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:prefs[kCachekey] error:nil];
            unarchiver.requiresSecureCoding = NO;
            self.XPadShortcuts = [unarchiver decodeObjectForKey:@"XPadShortcuts"];
            self.XPadShortcutsBundle = [unarchiver decodeObjectForKey:@"XPadShortcutsBundle"];
            self.XPadShortcutsFloat = [unarchiver decodeObjectForKey:@"XPadShortcutsFloat"];
            self.XPadShortcutsBundleFloat = [unarchiver decodeObjectForKey:@"XPadShortcutsBundleFloat"];
            self.XPadShortcutsDetails = [unarchiver decodeObjectForKey:@"XPadShortcutsDetails"];
            self.XPadShortcutsGroup = [unarchiver decodeObjectForKey:@"XPadShortcutsGroup"];
            self.XPadShortcutsBundleGroup = [unarchiver decodeObjectForKey:@"XPadShortcutsBundleGroup"];
            self.XPadShortcutsFloatGroup = [unarchiver decodeObjectForKey:@"XPadShortcutsFloatGroup"];
            self.XPadShortcutsBundleFloatGroup = [unarchiver decodeObjectForKey:@"XPadShortcutsBundleFloatGroup"];
            self.kbType = [unarchiver decodeObjectForKey:@"kbType"];
            self.kbTypeLabel = [unarchiver decodeObjectForKey:@"kbTypeLabel"];
            self.bundleButton = [unarchiver decodeObjectForKey:@"bundleButton"];
            self.bundleFloatButton = [unarchiver decodeObjectForKey:@"bundleFloatButton"];
            
            self.autoCorrectionButton = [unarchiver decodeObjectForKey:@"autoCorrectionButton"];
            self.autoCapitalizationButton = [unarchiver decodeObjectForKey:@"autoCapitalizationButton"];
            self.keyboardInputTypeButton = [unarchiver decodeObjectForKey:@"keyboardInputTypeButton"];
            if (self.shortcutsGenerator.loupeDylibExist){
                self.loupeButton = [unarchiver decodeObjectForKey:@"loupeButton"];
            }
            [unarchiver finishDecoding];
            NSArray *tagsShortcuts = [self.XPadShortcuts valueForKey:@"tag"];
            NSArray *tagsShortcutsBundle = [self.XPadShortcutsBundle valueForKey:@"tag"];
            NSArray *tagsShortcutsFloat = [self.XPadShortcutsFloat valueForKey:@"tag"];
            NSArray *tagsShortcutsBundleFloat = [self.XPadShortcutsBundleFloat valueForKey:@"tag"];
            
            [self.XPadShortcuts setValue:self forKey:@"target"];
            [self.XPadShortcutsBundle setValue:self forKey:@"target"];
            [self.XPadShortcutsFloat setValue:self forKey:@"target"];
            [self.XPadShortcutsBundleFloat setValue:self forKey:@"target"];
            
            if ([tagsShortcuts containsObject:@100] || [tagsShortcutsBundle containsObject:@100] || [tagsShortcutsFloat containsObject:@100] || [tagsShortcutsBundleFloat containsObject:@100]){
                [self updateAutoCorrectionButton];
            }
            if ([tagsShortcuts containsObject:@101] || [tagsShortcutsBundle containsObject:@101] || [tagsShortcutsFloat containsObject:@101] || [tagsShortcutsBundleFloat containsObject:@101]){
                [self updateAutoCapitalizationButton];
            }
            if ([tagsShortcuts containsObject:@102] || [tagsShortcutsBundle containsObject:@102] || [tagsShortcutsFloat containsObject:@102] || [tagsShortcutsBundleFloat containsObject:@102]){
                [self updateKeyboardTypeButton];
            }
            if (self.shortcutsGenerator.loupeDylibExist){
                if ([tagsShortcuts containsObject:@103] || [tagsShortcutsBundle containsObject:@103] || [tagsShortcutsFloat containsObject:@103] || [tagsShortcutsBundleFloat containsObject:@103]){
                    [self updateLoupeButton];
                }
            }
            //NSLog(@"XPAD: %@", error);
            //NSLog(@"XPAD Utilized cache");
        }else{
            //NSLog(@"XPAD update cache");
            
            
            
            self.XPadShortcuts = [[NSMutableArray alloc] init];
            self.XPadShortcutsBundle = [[NSMutableArray alloc] init];
            self.XPadShortcutsFloat = [[NSMutableArray alloc] init];
            self.XPadShortcutsBundleFloat = [[NSMutableArray alloc] init];
            //self.setLongPressGesture = YES;
            
            
            NSMutableArray *shortcutsImageNameDefault =  [[self.shortcutsGenerator imageNameArrayForiOS:1] mutableCopy];
            NSMutableArray *shortcutsSelectorNameDefault = [[self.shortcutsGenerator selectorNameForLongPress:NO] mutableCopy];
            NSMutableArray *shortcutsLPSelectorNameDefault = [[self.shortcutsGenerator selectorNameForLongPress:YES] mutableCopy];
            
            //NSMutableArray *shortcutsImageName = [[NSMutableArray alloc] init];
            //NSMutableArray *shortcutsSelectorName = [[NSMutableArray alloc] init];
            //NSMutableArray *shortcutsLPSelectorName = [[NSMutableArray alloc] init];
            
            if (prefs[@"shortcuts"]){
                int i = 0;
                for (NSDictionary *item in prefs[@"shortcuts"][0]){
                    //if (@available(iOS 13.0, *)){
                    NSString *selectorName = item[@"selector"];
                    
                    if ([selectorName isEqualToString:@"copyLogAction:"] && !self.shortcutsGenerator.copyLogDylibExist){
                        continue;
                    }
                    if ([selectorName isEqualToString:@"translomaticAction:"] && !self.shortcutsGenerator.translomaticDylibExist){
                        continue;
                    }
                    if ([selectorName isEqualToString:@"wasabiAction:"] && !self.shortcutsGenerator.wasabiDylibExist){
                        continue;
                    }
                    if ([selectorName isEqualToString:@"pasitheaAction:"] && !self.shortcutsGenerator.pasitheaDylibExist){
                        continue;
                    }
                    if ([selectorName isEqualToString:@"copypastaAction:"] && !self.shortcutsGenerator.copypastaDylibExist){
                        continue;
                    }
                    if ([selectorName isEqualToString:@"loupeAction:"] && !self.shortcutsGenerator.loupeDylibExist){
                        continue;
                    }
                    if ([selectorName isEqualToString:@"tranzloAction:"] && !self.shortcutsGenerator.tranzloDylibExist){
                        continue;
                    }
                    
                    UIBarButtonItem *shortcutButton = [[UIBarButtonItem alloc] initWithImage:[XPHelper imageForName:item[@"images"] withSystemColor:NO completion:nil] style:UIBarButtonItemStylePlain target:self action:NSSelectorFromString(selectorName)];
                    UIBarButtonItem *shortcutButtonFloat = [[UIBarButtonItem alloc] initWithImage:[XPHelper imageForName:item[@"images"] withSystemColor:NO completion:nil] style:UIBarButtonItemStylePlain target:self action:NSSelectorFromString(selectorName)];
                    
                    shortcutButton.tintColor = currentTintColor;
                    if ([selectorName isEqualToString:@"autoCorrectionAction:"]){
                        shortcutButton.tag = 100;
                        self.autoCorrectionButton = shortcutButton;
                        [self updateAutoCorrectionButton];
                    }else if ([selectorName isEqualToString:@"autoCapitalizationAction:"]){
                        shortcutButton.tag = 101;
                        self.autoCapitalizationButton = shortcutButton;
                        [self updateAutoCapitalizationButton];
                    }else if ([selectorName isEqualToString:@"keyboardTypeAction:"]){
                        shortcutButton.tag = 102;
                        self.keyboardInputTypeButton = shortcutButton;
                        [self updateKeyboardTypeButton];
                    }else if ([selectorName isEqualToString:@"loupeAction:"]){
                        shortcutButton.tag = 103;
                        self.loupeButton = shortcutButton;
                        [self updateLoupeButton];
                    }
                    if (i < preferencesInt(kMaxVisiblekey, maxBeforeBundle)){
                        [self.XPadShortcuts addObject:shortcutButton];
                    }else{
                        [self.XPadShortcutsBundle addObject:shortcutButton];
                    }
                    if (i < preferencesInt(kMaxVisibleFloatkey, maxBeforeBundleFloat)){
                        [self.XPadShortcutsFloat addObject:shortcutButtonFloat];
                    }else{
                        [self.XPadShortcutsBundleFloat addObject:shortcutButtonFloat];
                    }
                    i++;
                    //}
                }
            }else{
                for (int i = 0; i < maxdefaultshortcuts; i++ ){
                    //if (@available(iOS 13.0, *)){
                    NSString *selectorName = shortcutsSelectorNameDefault[i];
                    UIBarButtonItem *shortcutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:shortcutsImageNameDefault[i]] style:UIBarButtonItemStylePlain target:self action:NSSelectorFromString(selectorName)];
                    UIBarButtonItem *shortcutButtonFloat = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:shortcutsImageNameDefault[i]] style:UIBarButtonItemStylePlain target:self action:NSSelectorFromString(selectorName)];
                    
                    shortcutButton.tintColor = currentTintColor;
                    if ([selectorName isEqualToString:@"autoCorrectionAction:"]){
                        shortcutButton.tag = 100;
                        self.autoCorrectionButton = shortcutButton;
                        [self updateAutoCorrectionButton];
                    }else if ([selectorName isEqualToString:@"autoCapitalizationAction:"]){
                        shortcutButton.tag = 101;
                        self.autoCapitalizationButton = shortcutButton;
                        [self updateAutoCapitalizationButton];
                    }else if ([selectorName isEqualToString:@"keyboardTypeAction:"]){
                        shortcutButton.tag = 102;
                        self.keyboardInputTypeButton = shortcutButton;
                        [self updateKeyboardTypeButton];
                    }else if ([selectorName isEqualToString:@"loupeAction:"]){
                        shortcutButton.tag = 103;
                        self.loupeButton = shortcutButton;
                        [self updateLoupeButton];
                    }
                    if (i < preferencesInt(kMaxVisiblekey, maxBeforeBundle)){
                        [self.XPadShortcuts addObject:shortcutButton];
                    }else{
                        [self.XPadShortcutsBundle addObject:shortcutButton];
                    }
                    if (i < preferencesInt(kMaxVisibleFloatkey, maxBeforeBundleFloat)){
                        [self.XPadShortcutsFloat addObject:shortcutButtonFloat];
                    }else{
                        [self.XPadShortcutsBundleFloat addObject:shortcutButtonFloat];
                    }
                    //}
                }
            }
            self.XPadShortcutsDetails = @[shortcutsImageNameDefault,shortcutsSelectorNameDefault,shortcutsLPSelectorNameDefault];
            self.XPadShortcutsGroup = [[UIBarButtonItemGroup alloc]
                                       initWithBarButtonItems:self.XPadShortcuts representativeItem:nil];
            self.XPadShortcutsFloatGroup = [[UIBarButtonItemGroup alloc]
                                            initWithBarButtonItems:self.XPadShortcutsFloat representativeItem:nil];
            
            NSArray *kbTypeData = [self.shortcutsGenerator keyboardTypeData];
            NSArray *kbTypeLabel = [self.shortcutsGenerator keyboardTypeLabel];
            
            NSMutableArray *kbTypeActive = [[NSMutableArray alloc] init];
            NSMutableArray *kbTypeActiveLabel = [[NSMutableArray alloc] init];
            
            if (prefs[kKeyboardTypekey]){
                
                for (NSDictionary *item in prefs[kKeyboardTypekey][0]){
                    [kbTypeActive addObject:[NSNumber numberWithInt:[item[@"data"] intValue]]];
                    NSUInteger index = [kbTypeData indexOfObject:item[@"data"]];
                    [kbTypeActiveLabel addObject:kbTypeLabel[index]];
                    
                }
                
            }else{
                for (int i = 0; i < maxdefaultshortcutskbtype; i++){
                    [kbTypeActive addObject:kbTypeData[i]];
                    [kbTypeActiveLabel addObject:kbTypeLabel[i]];
                }
            }
            self.kbType = kbTypeActive;
            self.kbTypeLabel = kbTypeActiveLabel;
            
            if ([self.XPadShortcutsBundle count] > 0){
                self.bundleButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis.circle"] style:UIBarButtonItemStylePlain target:nil action:nil];
                self.XPadShortcutsBundleGroup = [[UIBarButtonItemGroup alloc]
                                                 initWithBarButtonItems:self.XPadShortcutsBundle representativeItem:self.bundleButton];
            }
            
            if ([self.XPadShortcutsBundleFloat count] > 0){
                self.bundleFloatButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"ellipsis.circle"] style:UIBarButtonItemStylePlain target:nil action:nil];
                self.XPadShortcutsBundleFloatGroup = [[UIBarButtonItemGroup alloc]
                                                      initWithBarButtonItems:self.XPadShortcutsBundleFloat representativeItem:self.bundleFloatButton];
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                XPPrefsManager *prefsManager = [XPPrefsManager sharedInstance];
                //[prefsManager setValue:@NO forKey:kUpdateCachekey fromSandbox:!isSpringBoard];
                
                
                NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
                [archiver encodeObject:self.XPadShortcuts forKey:@"XPadShortcuts"];
                [archiver encodeObject:self.XPadShortcutsBundle forKey:@"XPadShortcutsBundle"];
                [archiver encodeObject:self.XPadShortcutsFloat forKey:@"XPadShortcutsFloat"];
                [archiver encodeObject:self.XPadShortcutsBundleFloat forKey:@"XPadShortcutsBundleFloat"];
                [archiver encodeObject:self.XPadShortcutsDetails forKey:@"XPadShortcutsDetails"];
                [archiver encodeObject:self.XPadShortcutsGroup forKey:@"XPadShortcutsGroup"];
                [archiver encodeObject:self.XPadShortcutsBundleGroup forKey:@"XPadShortcutsBundleGroup"];
                [archiver encodeObject:self.XPadShortcutsFloatGroup forKey:@"XPadShortcutsFloatGroup"];
                [archiver encodeObject:self.XPadShortcutsBundleFloatGroup forKey:@"XPadShortcutsBundleFloatGroup"];
                [archiver encodeObject:self.kbType forKey:@"kbType"];
                [archiver encodeObject:self.kbTypeLabel forKey:@"kbTypeLabel"];
                [archiver encodeObject:self.bundleButton forKey:@"bundleButton"];
                [archiver encodeObject:self.bundleFloatButton forKey:@"bundleFloatButton"];
                
                [archiver encodeObject:self.autoCorrectionButton forKey:@"autoCorrectionButton"];
                [archiver encodeObject:self.autoCapitalizationButton forKey:@"autoCapitalizationButton"];
                [archiver encodeObject:self.keyboardInputTypeButton forKey:@"keyboardInputTypeButton"];
                [archiver encodeObject:self.loupeButton forKey:@"loupeButton"];
                
                
                [archiver encodeObject:@(self.shortcutsGenerator.copyLogDylibExist) forKey:@"copyLogDylibExist"];
                [archiver encodeObject:@(self.shortcutsGenerator.translomaticDylibExist) forKey:@"translomaticDylibExist"];
                [archiver encodeObject:@(self.shortcutsGenerator.wasabiDylibExist) forKey:@"wasabiDylibExist"];
                [archiver encodeObject:@(self.shortcutsGenerator.pasitheaDylibExist) forKey:@"pasitheaDylibExist"];
                [archiver encodeObject:@(self.shortcutsGenerator.copypastaDylibExist) forKey:@"copypastaDylibExist"];
                [archiver encodeObject:@(self.shortcutsGenerator.loupeDylibExist) forKey:@"loupeDylibExist"];
                [archiver encodeObject:@(self.shortcutsGenerator.tranzloDylibExist) forKey:@"tranzloDylibExist"];
                
                [archiver finishEncoding];
                //NSLog(@"XPAD: %@", error);
                
                /*
                 NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:prefs[kCachekey] error:&error];
                 unarchiver.requiresSecureCoding = NO;
                 self.XPadShortcuts = [unarchiver decodeObjectForKey:@"XPadShortcuts"];
                 self.XPadShortcutsBundle = [unarchiver decodeObjectForKey:@"XPadShortcutsBundle"];
                 self.XPadShortcutsDetails = [unarchiver decodeObjectForKey:@"XPadShortcutsDetails"];
                 self.XPadShortcutsGroup = [unarchiver decodeObjectForKey:@"XPadShortcutsGroup"];
                 self.kbType = [unarchiver decodeObjectForKey:@"kbType"];
                 self.kbTypeLabel = [unarchiver decodeObjectForKey:@"kbTypeLabel"];
                 self.autoCorrectionButton = [unarchiver decodeObjectForKey:@"autoCorrectionButton"];
                 self.autoCapitalizationButton = [unarchiver decodeObjectForKey:@"autoCapitalizationButton"];
                 self.keyboardInputTypeButton = [unarchiver decodeObjectForKey:@"keyboardInputTypeButton"];
                 NSMutableArray *activeDynamicShortcutsE = [unarchiver decodeObjectForKey:@"activeDynamicShortcuts"];
                 
                 [unarchiver finishDecoding];
                 for (NSString *s in activeDynamicShortcutsE){
                 NSLog(@"XPAD E %@", s);
                 }
                 NSLog(@"XPAD: %@", error);
                 */
                [prefsManager setValue:archiver.encodedData forKey:kCachekey fromSandbox:!isSpringBoard];
                prefs = [[prefsManager readPrefsFromSandbox:!isSpringBoard] mutableCopy];
                
                
                //NSLog(@"XPAD: Cache updated");
            });
            
        }
        
        
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
            self.autoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
            if (self.shortcutsGenerator.loupeDylibExist){
                self.loupeEnabled = loupeSwitchState();
            }
        });
        
        //self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
        //self.isAutoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
        
        
        self.commandTitle = @"";
        self.insertTextActionType = 0;
        self.isWordSender = NO;
        self.moveCursorWithSelect = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutoCorrection:) name:@"updateAutoCorrection" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutoCapitalization:) name:@"updateAutoCapitalization" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoupe:) name:@"updateLoupe" object:nil];
        
        //NSData *data = [NSKeyedArchiver
        //archivedDataWithRootObject:self requiringSecureCoding:NO error:&error];
        //NSLog(@"XPAD: %@", error);
        //NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&error];
        //unarchiver.requiresSecureCoding = NO;
        //NSLog(@"XPAD: %@", error);
        //NSArray *un = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[XPXPad class], nil] fromData:data error:nil];
        //NSLog(@"XPAD: %@", [unarchiver decodeObjectForKey:@"XPadShortcuts"]);
        
        //NSMutableDictionary *cache = [NSMutableDictionary dictionary];
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateAutoCorrection" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateAutoCapitalization" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateLoupe" object:nil];
}

-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate{
    BOOL hasRightText = [delegate.tokenizer isPosition:delegate.selectedTextRange.start withinTextUnit:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    UITextStorageDirection direction = hasRightText ? UITextStorageDirectionForward : UITextStorageDirectionBackward;
    UITextRange *range = [delegate.tokenizer rangeEnclosingPosition:delegate.selectedTextRange.start
                                                    withGranularity:UITextGranularityWord
                                                        inDirection:direction];
    if (!range) {
        UITextPosition *p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
        range = [delegate.tokenizer rangeEnclosingPosition:p withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
    }
    return range;
}

-(UITextRange *)selectedWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction{
    UITextRange *range = [delegate.tokenizer rangeEnclosingPosition:delegate.selectedTextRange.start
                                                    withGranularity:UITextGranularityWord
                                                        inDirection:direction];
    if (!range) {
        if (direction == UITextStorageDirectionBackward) {
            UITextPosition *p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
            if (!p)
                p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityLine inDirection:UITextLayoutDirectionUp];
            range = [delegate.tokenizer rangeEnclosingPosition:p withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionBackward];
        } else {
            UITextPosition *p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.start toBoundary:UITextGranularityWord inDirection:UITextStorageDirectionForward];
            if (!p)
                p = [delegate.tokenizer positionFromPosition:delegate.selectedTextRange.end toBoundary:UITextGranularityLine inDirection:UITextLayoutDirectionDown];
            range = [delegate.tokenizer rangeEnclosingPosition:p withGranularity:UITextGranularityWord inDirection:UITextStorageDirectionForward];
        }
    }
    return range;
}

-(void)moveCursorVerticalWithDelegate:(id<UITextInput>)delegate direction:(UITextLayoutDirection)direction{
    UITextPosition *position = [delegate positionFromPosition:delegate.selectedTextRange.start inDirection:direction offset:1];
    if (!position) return;
    UITextRange *range = [delegate textRangeFromPosition:position toPosition:position];
    delegate.selectedTextRange = range;
    //RevealSelection(delegate);
}

-(UITextRange *)autoDirectionWordSelectedTextRangeWithDelegate:(id<UITextInput> )delegate{
    BOOL hasRightText = [delegate.tokenizer isPosition:delegate.selectedTextRange.start withinTextUnit:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    UITextStorageDirection direction = hasRightText ? UITextStorageDirectionForward : UITextStorageDirectionBackward;
    return [self selectedWordTextRangeWithDelegate:delegate direction:direction];
}

-(UIWindow*)keyWindow{
    NSPredicate *isKeyWindow = [NSPredicate predicateWithFormat:@"isKeyWindow == YES"];
    return [[[UIApplication sharedApplication] windows] filteredArrayUsingPredicate:isKeyWindow].firstObject;
}

-(UITextRange *)singleWordTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextStorageDirection)direction{
    UITextRange *range = [self selectedWordTextRangeWithDelegate:delegate direction:direction];
    if (direction == UITextStorageDirectionForward)
        return [delegate textRangeFromPosition:range.end toPosition:range.end];
    else
        return [delegate textRangeFromPosition:range.start toPosition:range.start];
}

-(UITextRange *)lineExtremityTextRangeWithDelegate:(id<UITextInput>)delegate direction:(UITextLayoutDirection)direction{
    id<UITextInputTokenizer> tokenizer = delegate.tokenizer;
    UITextPosition *lineEdgePosition = [tokenizer positionFromPosition:delegate.selectedTextRange.end toBoundary:UITextGranularityLine inDirection:direction];
    // for until iOS 6 component.
    if ([lineEdgePosition isMemberOfClass:objc_getClass("UITextPositionImpl")])
        return [delegate textRangeFromPosition:lineEdgePosition toPosition:lineEdgePosition];
    // for iOS 7 buggy _UITextKitTextPosition workaround.
    for (int i=1; i<1000; i++) {
        lineEdgePosition = [delegate positionFromPosition:delegate.selectedTextRange.start inDirection:direction offset:i];
        NSComparisonResult result = [delegate comparePosition:lineEdgePosition
                                                   toPosition:(direction == UITextLayoutDirectionLeft) ? delegate.beginningOfDocument : delegate.endOfDocument];
        if (!lineEdgePosition || result == NSOrderedSame)
            return [delegate textRangeFromPosition:lineEdgePosition toPosition:lineEdgePosition];
        UITextRange *range = [delegate textRangeFromPosition:delegate.selectedTextRange.start toPosition:lineEdgePosition];
        NSString *text = [delegate textInRange:range];
        if ([text hasPrefix:@"\n"] || [text hasSuffix:@"\n"]) {
            lineEdgePosition = [delegate positionFromPosition:delegate.selectedTextRange.start inDirection:direction offset:i-1];
            return [delegate textRangeFromPosition:lineEdgePosition toPosition:lineEdgePosition];
        }
    }
    return nil;
}

-(void)moveCursorSingleWordWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextStorageDirection)direction{
    if (delegate) {
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            if (direction == UITextStorageDirectionForward){
                direction = UITextStorageDirectionBackward;
            }else{
                direction = UITextStorageDirectionForward;
            }
        }
        UITextRange *textRange = [self singleWordTextRangeWithDelegate:delegate direction:direction];
        if (!textRange) return;
        [delegate setSelectedTextRange:textRange];
    }
}

-(void)moveCursorToLineExtremityWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate direction:(UITextLayoutDirection)direction{
    if (delegate) {
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            if (direction == UITextLayoutDirectionLeft){
                direction = UITextLayoutDirectionRight;
            }else{
                direction = UITextLayoutDirectionLeft;
            }
        }
        UITextRange *textRange = [self lineExtremityTextRangeWithDelegate:delegate direction:direction];
        if (!textRange) return;
        [delegate setSelectedTextRange:textRange];
    }
}


-(BOOL)isRTLForDelegate:(UIResponder *)delegate {
    UIKeyboardExtensionInputMode *inputMode = (UIKeyboardExtensionInputMode *)(delegate.textInputMode);
    return [inputMode isDefaultRightToLeft];
    
}

- (int)currentCursorPosition:(id <UITextInput, UITextInputTokenizer>)delegate{
    UITextRange *selectedRange = delegate.selectedTextRange;
    UITextPosition *textPosition = selectedRange.start;
    return [delegate offsetFromPosition:delegate.beginningOfDocument toPosition:textPosition];
}

-(void)moveCursorWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset{
    if (delegate) {
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        UITextPosition *textPosition;
        if (isRTL){
            textPosition = [delegate positionFromPosition:delegate.beginningOfDocument offset:([self currentCursorPosition:delegate]-offset)];
        }else{
            textPosition = [delegate positionFromPosition:delegate.beginningOfDocument offset:([self currentCursorPosition:delegate]+offset)];
        }
        [delegate setSelectedTextRange:[delegate textRangeFromPosition:textPosition toPosition:textPosition]];
    }
}

-(NSUInteger)getShortcutIndexWithActionNamed:(NSString *)actionName{
    NSArray *arrayWithEventID = [prefs[@"shortcuts"][0] valueForKey:@"selector"];
    NSUInteger index = [arrayWithEventID indexOfObject:actionName];
    return index;
}

-(NSDictionary *)locationForMode:(int)mode assistantView:(TUISystemInputAssistantView *)assistantView actionName:(NSString *)actionName{
    
    //0-auto
    //1-left
    //2-center
    //3-right
    //4-manual
    if ([self.parentActionName length] > 0){
        actionName = self.parentActionName;
    }
    float autoPositionX = 0;
    float autoPositionY = 0;
    
    //depreciated in ios 13
    //UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    //crashed in microsoft apps
    //UIViewController *controller = [UIWindow keyWindow].rootViewController;
    
    
    UIViewController *controller = [self keyWindow].rootViewController;
    
    CGRect frame = [assistantView.leftButtonBar convertRect:assistantView.leftButtonBar.frame fromView:controller.view];
    //HBLogDebug(@"VIEW: %@",NSStringFromCGRect(frame));
    
    
    UIDeviceOrientation orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
    float kScreenW = [[UIScreen mainScreen] bounds].size.width;
    float kScreenH = [[UIScreen mainScreen] bounds].size.height;
    float framePositionX = fabs(frame.origin.x);
    float framePositionY = fabs(frame.origin.y);
    
    float offsetXForBundle = 0;
    float offsetYForBundle = 0;
    
    NSArray <UIBarButtonItemGroup *>*groups = assistantView.leftButtonBar.buttonGroups;
    
    BOOL representativeView = YES;
    if ([groups count] > 1){
        representativeView = groups[1].displayingRepresentativeItem;
    }
    
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeRight: {
            if (([self getShortcutIndexWithActionNamed:actionName] >= preferencesLongLong(kMaxVisiblekey, maxBeforeBundle)) && representativeView){
                offsetXForBundle = 60;
                offsetYForBundle = 60;
            }
            if (!assistantView.centerViewHidden){
                if (mode == 0){
                    autoPositionX = (framePositionX - (assistantView.leftButtonBar.frame.size.width/2) + toastWidth/2)/kScreenW;
                }else if (mode == 1){
                    autoPositionX = 0.9;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.1;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = (framePositionY - toastHeight - offsetYForBundle)/kScreenH;
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
            }else{
                if (mode == 0){
                    autoPositionX = ((framePositionX - (assistantView.leftButtonBar.frame.size.width/4) + toastWidth/2)/kScreenW);
                }else if (mode == 1){
                    autoPositionX = 0.9;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.1;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = (framePositionY - toastHeight - offsetYForBundle)/kScreenH;
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
            }
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            if (([self getShortcutIndexWithActionNamed:actionName] >= preferencesLongLong(kMaxVisiblekey, maxBeforeBundle)) && representativeView){
                offsetXForBundle = 250;
                offsetYForBundle = 250;
            }
            if (!assistantView.centerViewHidden){
                if (mode == 0){
                    autoPositionX = (framePositionX + (assistantView.leftButtonBar.frame.size.width/2) + toastWidth/2)/kScreenW;
                }else if (mode == 1){
                    autoPositionX = 0.1;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.9;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = kScreenH/((2*kScreenH) - (framePositionY- 2*(assistantView.leftButtonBar.frame.size.height) - toastHeight/2) + offsetYForBundle);
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
                
                
            }else{
                if (mode == 0){
                    autoPositionX = (framePositionX + (assistantView.leftButtonBar.frame.size.width/4) + toastWidth/2)/kScreenW;
                }else if (mode == 1){
                    autoPositionX = 0.1;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.9;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = kScreenH/((2*kScreenH) - (framePositionY- 2*(assistantView.leftButtonBar.frame.size.height) - toastHeight/2) + offsetYForBundle);
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
            }
            
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            if (([self getShortcutIndexWithActionNamed:actionName] >= preferencesLongLong(kMaxVisiblekey, maxBeforeBundle)) && representativeView){
                offsetXForBundle = 20;
                offsetYForBundle = 20;
            }
            if (!assistantView.centerViewHidden){
                if (mode == 0){
                    autoPositionX = ((kScreenH-framePositionX + (assistantView.leftButtonBar.frame.size.width*1.5) + toastWidth/2)/kScreenH);
                }else if (mode == 1){
                    autoPositionX = 0.9;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.1;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = (framePositionY + (assistantView.leftButtonBar.frame.size.height) - toastHeight + offsetYForBundle)/kScreenW;
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
                
            }else{
                
                if (mode == 0){
                    autoPositionX = ((kScreenH-framePositionX + (assistantView.leftButtonBar.frame.size.width/4) + toastWidth/2)/kScreenH);
                }else if (mode == 1){
                    autoPositionX = 0.9;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.1;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = (framePositionY + (assistantView.leftButtonBar.frame.size.height) - toastHeight + offsetYForBundle)/kScreenW;
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
            }
            break;
        }
        case UIDeviceOrientationPortrait:
        default: {
            if (([self getShortcutIndexWithActionNamed:actionName] >= preferencesLongLong(kMaxVisiblekey, maxBeforeBundle)) && representativeView){
                offsetXForBundle = 30;
                offsetYForBundle = 30;
            }
            if (!assistantView.centerViewHidden){
                if (mode == 0){
                    autoPositionX = (framePositionX + (assistantView.leftButtonBar.frame.size.width/2) + toastWidth/2)/kScreenW;
                }else if (mode == 1){
                    autoPositionX = 0.1;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.9;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = (framePositionY - (assistantView.leftButtonBar.frame.size.height) - toastHeight/2 - offsetYForBundle)/kScreenH;
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
            }else{
                if (mode == 0){
                    autoPositionX = (framePositionX + (assistantView.leftButtonBar.frame.size.width/4) + toastWidth/2)/kScreenW;
                }else if (mode == 1){
                    autoPositionX = 0.1;
                }else if (mode == 2){
                    autoPositionX = 0.5;
                }else if (mode == 3){
                    autoPositionX = 0.9;
                }else{
                    autoPositionX = preferencesFloat(kToastPx, toastPositionX);
                }
                
                if (mode < 4){
                    autoPositionY = (framePositionY - (assistantView.leftButtonBar.frame.size.height) - toastHeight/2 - offsetYForBundle)/kScreenH;
                }else{
                    autoPositionY = preferencesFloat(kToastPy, toastPositionY);
                }
            }
            break;
        }
    }
    //HBLogDebug(@"W: %f, H: %f, X: %f, Y: %f", kScreenW, kScreenH, autoPositionX, autoPositionY);
    
    return @{@"X":[NSNumber numberWithFloat:autoPositionX], @"Y":[NSNumber numberWithFloat:autoPositionY]};
}


-(void)shakeButton:(UIBarButtonItem *)sender{
    UIView *senderView = [sender valueForKey:@"view"];
    if (senderView){
        if (preferencesBool(kShakeShortcutkey,YES)){
            self.refreshView = NO;
            CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
            [shake setDuration:0.05];
            [shake setRepeatCount:2];
            [shake setAutoreverses:YES];
            [shake setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake(senderView.center.x - 5,senderView.center.y)]];
            [shake setToValue:[NSValue valueWithCGPoint:
                               CGPointMake(senderView.center.x + 5, senderView.center.y)]];
            [senderView.layer removeAllAnimations];
            [senderView.layer addAnimation:shake forKey:@"position"];
            double delayInSeconds = 1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.refreshView = YES;
            });
        }
    }
}


-(void)shakeView:(UIView *)sender{
    if (preferencesBool(kShakeShortcutkey,YES)){
        self.refreshView = NO;
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
        [shake setDuration:0.05];
        [shake setRepeatCount:2];
        [shake setAutoreverses:YES];
        [shake setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake(sender.center.x - 5,sender.center.y)]];
        [shake setToValue:[NSValue valueWithCGPoint:
                           CGPointMake(sender.center.x + 5, sender.center.y)]];
        [sender.layer removeAllAnimations];
        [sender.layer addAnimation:shake forKey:@"position"];
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.refreshView = YES;
        });
    }
}


-(NSString *)convertColorToString:(UIColor *)colorname{
    if(colorname==[UIColor whiteColor] ){
        colorname= [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
    else if(colorname==[UIColor blackColor]){
        colorname= [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    CGColorRef colorRef = colorname.CGColor;
    NSString *colorString = [CIColor colorWithCGColor:colorRef].stringRepresentation;
    return colorString;
}


-(NSString *)getImageNameForActionName:(NSString *)actionname{
    
    if ([actionname isEqualToString:@"autoCorrectionAction:"]){
        return  !self.autoCorrectionEnabled?@"checkmark.circle.fill":@"checkmark.circle";
    }else if ([actionname isEqualToString:@"autoCapitalizationAction:"]){
        return  !self.autoCapitalizationEnabled?@"shift.fill":@"shift";
    }else if ([actionname isEqualToString:@"loupeAction:"]){
        return  !self.loupeEnabled?@"magnifyingglass.circle.fill":@"magnifyingglass.circle";
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", actionname];
    NSUInteger idx = [self.XPadShortcutsDetails[1]  indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
        return [predicate evaluateWithObject:obj];
    }];
    
    return self.XPadShortcutsDetails[0][idx];
    
}


-(void)sendShowToastRequestWithMessage:(NSString *)message imagePath:(NSString *)imagepath imageTint:(UIColor *)imagetint width:(int)width height:(int)height positionX:(float)positionX positionY:(float)positionY duration:(double)duration alpha:(float)alpha radius:(float)radius textColor:(UIColor *)textColor backgroundColor:(UIColor *)backgroundColor displayType:(int)displayType{
    
    //HBLogDebug(@"%@",NSStringFromClass([[UIApplication sharedApplication] class]));
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              message, @"message",
                              imagepath, @"imagepath",
                              [NSNumber numberWithInt:width], @"width",
                              [NSNumber numberWithInt:height], @"height",
                              [NSNumber numberWithFloat:positionX], @"positionX",
                              [NSNumber numberWithFloat:positionY], @"positionY",
                              [NSNumber numberWithDouble:duration], @"duration",
                              [NSNumber numberWithDouble:alpha], @"alpha",
                              [NSNumber numberWithDouble:radius], @"radius",
                              [self convertColorToString:textColor], @"textColor",
                              [self convertColorToString:backgroundColor], @"backgroundColor",
                              [self convertColorToString:imagetint], @"imagetint",
                              [NSNumber numberWithInt:displayType], @"displayType",
                              nil];
    
    if (!isSpringBoard){
        if (!self.toastCenter) self.toastCenter = [self IPCCenterNamed:kIPCCenterToast];
        [self.toastCenter sendMessageAndReceiveReplyName:@"showToastRequest" userInfo:userInfo];
    }else{
        [[XPToastWindowController sharedInstance] showToastRequest:@"showToastRequest" withUserInfo:userInfo];
        //SpringBoard *sb = (SpringBoard *)[UIApplication sharedApplication];
        //[sb showToastRequest:@"showToastRequest" withUserInfo:userInfo];
    }
    
    
    
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


-(void)triggerImpactAndAnimationWithButton:(UIBarButtonItem *)sender selectorName:(NSString *)selname toastWidthOffset:(int)woffset toastHeightOffset:(int)hoffset{
    
    if ( preferencesBool(kToastkey,YES) ){
        
        int th = toastHeight;
        int tw = toastWidth;
        if (preferencesInt(kDisplayTypekey, 0) == 1){
            th = 40;
            //tw = 130;
        }
        
        //NSString *actionName = selname;
        
        NSString *actionName = [XPHelper localizedStringOfToastForActionNamed:selname bundle:tweakBundle];
        
        //HBLogDebug(@"^^^^^^^^^actionName: %@", actionName);
        if ([selname isEqualToString:@"keyboardTypeAction:"]){
            NSUInteger index = [self.kbType indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]>12?0:[delegate keyboardType]]];
            if (index != NSNotFound){
                NSUInteger idx = index + 1;
                if (index < [self.kbType count] - 1 ){
                    if ([delegate keyboardType] < 0){
                        idx = idx + 1;
                    }
                    actionName = self.kbTypeLabel[idx];
                    
                }else{
                    actionName = self.kbTypeLabel[0];
                }
            }else{
                actionName = LOCALIZED(@"TOAST_KEYBOARD_TYPE_DEFAULT");
            }
            //if (preferencesInt(kDisplayTypekey, 0) == 1){
            //tw = tw + 15;
            //}
        }else if ([selname isEqualToString:@"keyboardTypeActionLP:"]){
            NSUInteger index = [self.kbType indexOfObject:[NSNumber numberWithInt:self.trueKBType]];
            if (index != NSNotFound){
                actionName = self.kbTypeLabel[index];
            }else{
                actionName = LOCALIZED(@"TOAST_KEYBOARD_TYPE_DEFAULT");
            }
            //if (preferencesInt(kDisplayTypekey, 0) == 1){
            //tw = tw + 15;
            //}
            selname = @"keyboardTypeAction:";
        }else if ([selname containsString:@"runCommandAction"]){
            actionName = self.commandTitle;
            //if (preferencesInt(kDisplayTypekey, 0) == 1){
            //tw = tw + 15;
            //}
            selname = @"runCommandAction:";
        }else if ([selname isEqualToString:@"autoCorrectionAction:"]){
            actionName = !self.autoCorrectionEnabled?LOCALIZED(@"TOAST_ON"):LOCALIZED(@"TOAST_OFF");
        }else if ([selname isEqualToString:@"autoCapitalizationAction:"]){
            actionName = !self.autoCapitalizationEnabled?LOCALIZED(@"TOAST_ON"):LOCALIZED(@"TOAST_OFF");
        }else if ([selname isEqualToString:@"loupeAction:"]){
            actionName = !self.loupeEnabled?LOCALIZED(@"TOAST_ON"):LOCALIZED(@"TOAST_OFF");
        }
        /*
         else if ([selname isEqualToString:@"insertTextAction:"]){
         actionName = @"Insert";
         }else if ([selname isEqualToString:@"deleteForwardAction:"]){
         actionName = @"Delete";
         }else{
         actionName = [selname stringByReplacingOccurrencesOfString:@"Action:" withString:@""];
         
         if ([selname isEqualToString:@"translomaticAction:"]){
         if (preferencesInt(kDisplayTypekey, 0) == 1){
         tw = tw + 10;
         }
         }
         
         if ([selname isEqualToString:@"moveCursorPreviousWordAction:"] || [selname isEqualToString:@"selectSentenceAction:"]){
         if (preferencesInt(kDisplayTypekey, 0) == 1){
         tw = tw + 30;
         }
         }
         
         if ([selname isEqualToString:@"moveCursorStartOfParagraphAction:"] || [selname isEqualToString:@"moveCursorEndOfParagraphAction:"] || [selname isEqualToString:@"moveCursorStartOfSentenceAction:"] || [selname isEqualToString:@"moveCursorEndOfSentenceAction:"] || [selname isEqualToString:@"selectParagraphAction:"]){
         if (preferencesInt(kDisplayTypekey, 0) == 1){
         tw = tw + 60;
         }
         }
         
         actionName = [actionName stringByReplacingOccurrencesOfString:@"Keyboard" withString:@""];
         actionName = [actionName stringByReplacingOccurrencesOfString:@"moveCursor" withString:@""];
         actionName = [actionName stringByReplacingOccurrencesOfString:@"autoCorrection" withString:!self.autoCorrectionEnabled?@"On":@"Off"];
         actionName = [actionName stringByReplacingOccurrencesOfString:@"autoCapitalization" withString:!self.autoCapitalizationEnabled?@"On":@"Off"];
         NSRegularExpression *regexp = [NSRegularExpression
         regularExpressionWithPattern:@"([a-z])([A-Z])"
         options:0
         error:NULL];
         actionName = [regexp
         stringByReplacingMatchesInString:actionName
         options:0
         range:NSMakeRange(0, actionName.length)
         withTemplate:@"$1 $2"];
         actionName = [actionName capitalizedString];
         }
         */
        
        if (preferencesInt(kDisplayTypekey, 0) == 1){
            tw = (int)([self widthOfString:actionName withFont:[UIFont systemFontOfSize:18]] + 0.5f) + 45;
            //tw = 10*[actionName length] - 20;
        }
        
        NSDictionary *locationForModeData = [self locationForMode:prefs[kModekey]?[prefs[kModekey] intValue]:0 assistantView:self.systemInputAssistantView actionName:selname];
        
        if (![objc_getClass("UIKeyboardImpl") isFloating]){
            [self sendShowToastRequestWithMessage:actionName imagePath:[self getImageNameForActionName:selname] imageTint:toastTintColor width:tw+woffset height:th+hoffset positionX:[locationForModeData[@"X"] floatValue] positionY:[locationForModeData[@"Y"] floatValue] duration:preferencesFloat(kToastDurationkey, toastDuration) alpha:toastAlpha radius:toastRadius textColor:toastTextColor backgroundColor:toastBackgroundTintColor displayType:preferencesInt(kDisplayTypekey, 0)];
        }
    }
    [self shakeButton:sender];
}


-(void)selectAllAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    if ([delegate respondsToSelector:@selector(selectAll:)]) {
        [delegate selectAll:nil];
    }else if ([delegate respondsToSelector:@selector(selectAll)]) {
        [delegate selectAll];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    
    
}

-(void)selectLineAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    [delegate _moveToStartOfLine:NO withHistory:nil];
    [delegate _moveToEndOfLine:YES withHistory:nil];
}

-(void)selectParagraphAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    [delegate _moveToStartOfParagraph:NO withHistory:nil];
    [delegate _moveToEndOfParagraph:YES withHistory:nil];;
}

-(void)selectSentenceAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
    UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    
    if (isWKContentView){
        
    }else{
        UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
        [tempDelegate setSelectedTextRange:textRange];
    }
}

-(void)copyAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    if ([delegate respondsToSelector:@selector(copy:)]) {
        [delegate copy:nil]; //UIResponderStandardEditActions.h
    }else{
        if ([delegate respondsToSelector:@selector(selectedTextRange)]) {
            UITextRange *range = [delegate selectedTextRange];
            NSString *textRange = [delegate textInRange:range];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            
            [pasteboard setString:textRange];
            
            [kbImpl clearTransientState];
            [kbImpl clearAnimations];
            [kbImpl setCaretBlinks:YES];
        }
    }
    
}

-(BOOL)isValidURL:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    BOOL isUrl = NO;
    if (url && url.scheme && url.host) isUrl = YES;
    return isUrl;
}


-(void)pasteAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    BOOL isUnifiedField = [delegate isKindOfClass:objc_getClass("UnifiedField")];
    int pasteAndGoType = preferencesInt(kPasteAndGoEnabledkey, 2);
    if (pasteAndGoType > 0 && isSafari && isUnifiedField){
        if (pasteAndGoType == 1 && [self isValidURL:[[UIPasteboard generalPasteboard] string]]){
            if ([((UnifiedField *)delegate).delegate respondsToSelector:@selector(unifiedFieldShouldPasteAndNavigate:)]){
                [((UnifiedField *)delegate).delegate unifiedFieldShouldPasteAndNavigate:nil];
                return;
            }
        }else if (pasteAndGoType == 2){
            if ([((UnifiedField *)delegate).delegate respondsToSelector:@selector(unifiedFieldShouldPasteAndNavigate:)]){
                [((UnifiedField *)delegate).delegate unifiedFieldShouldPasteAndNavigate:nil];
                return;
            }
        }
    }
    
    if ([delegate respondsToSelector:@selector(paste:)]) {
        [delegate paste:nil]; //UIResponderStandardEditActions.h
    }else{
        if ([delegate respondsToSelector:@selector(selectedTextRange)]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            
            NSString *copiedtext = [pasteboard string];
            
            if (copiedtext) {
                [kbImpl insertText:copiedtext];
            }
            
            [kbImpl clearTransientState];
            [kbImpl clearAnimations];
            [kbImpl setCaretBlinks:YES];
            
        }
    }
    
}


-(void)cutAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:20 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    if ([delegate respondsToSelector:@selector(cut:)]) {
        [delegate cut:nil]; //UIResponderStandardEditActions.h
    }else if ([delegate respondsToSelector:@selector(selectedTextRange)]) {
        UITextRange *range = [delegate selectedTextRange];
        NSString *textRange = [delegate textInRange:range];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        [pasteboard setString:textRange];
        
        [kbImpl deleteFromInput];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    
}


-(void)undoAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    if ([[delegate undoManager] canUndo]) {
        [[delegate undoManager] undo];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
}


-(void)redoAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    if ([[delegate undoManager] canRedo]) {
        [[delegate undoManager] redo];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    
}


-(void)selectAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    if ([delegate respondsToSelector:@selector(select:)]) {
        [delegate select:nil]; //UIResponderStandardEditActions.h
    }else{
        if (![kbImpl isUsingDictationLayout]){
            NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
            if (!selectedString.length) {
                UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
                
                if (!textRange)
                    return;
                UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
                if (![((UITextField *)tempDelegate).text isEqualToString:@"\uFFFC"]){
                    tempDelegate.selectedTextRange = textRange;
                }
                [kbImpl clearTransientState];
                [kbImpl clearAnimations];
                [kbImpl setCaretBlinks:YES];
            }
        }
    }
}


-(void)beginningAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"moveToBeginningOfDocument"];
    }else{
        tempDelegate.selectedTextRange = [tempDelegate textRangeFromPosition:tempDelegate.beginningOfDocument toPosition:tempDelegate.beginningOfDocument];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    
}


-(void)endingAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"moveToEndOfDocument"];
    }else{
        tempDelegate.selectedTextRange = [tempDelegate textRangeFromPosition:tempDelegate.endOfDocument toPosition:tempDelegate.endOfDocument];
    }
    
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    
}


-(void)capitalizeAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:20 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
        
        if (!textRange)
            return;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        tempDelegate.selectedTextRange = textRange;
        
        NSString *capitalizedStrings = [[delegate textInRange:textRange] capitalizedString];
        [kbImpl insertText:capitalizedStrings];
        
    }else{
        NSString *capitalizedStrings = [selectedString capitalizedString];
        [kbImpl insertText:capitalizedStrings];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    
}


-(void)lowercaseAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:20 toastHeightOffset:-5];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
        
        if (!textRange)
            return;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        tempDelegate.selectedTextRange = textRange;
        
        NSString *lowercaseStrings = [[delegate textInRange:textRange] lowercaseString];
        [kbImpl insertText:lowercaseStrings];
    }else{
        NSString *lowercaseStrings = [selectedString lowercaseString];
        [kbImpl insertText:lowercaseStrings];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    
}


-(void)uppercaseAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate];
        
        if (!textRange) return;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        tempDelegate.selectedTextRange = textRange;
        
        NSString *uppercaseStrings = [[delegate textInRange:textRange] uppercaseString];
        [kbImpl insertText:uppercaseStrings];
    }else{
        NSString *uppercaseStrings = [selectedString uppercaseString];
        [kbImpl insertText:uppercaseStrings];
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
    
}


-(void)deleteAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:10 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    BOOL smartDelete = preferencesBool(kEnabledSmartDeletekey, NO);
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate direction:UITextStorageDirectionBackward];
        
        if (!textRange) return;
        
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        
        tempDelegate.selectedTextRange = textRange;
        //[kbImpl deleteFromInput];
        [kbImpl deleteFromInput];
        if (smartDelete) [kbImpl insertText:@" "];
        //[tempDelegate  _moveRight:NO withHistory:nil];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
        
    }else{
        [kbImpl deleteBackward];
        if (smartDelete) [kbImpl insertText:@" "];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    
}

-(void)deleteForwardAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:10 toastHeightOffset:0];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    BOOL smartDelete = preferencesBool(kEnabledSmartDeleteForwardkey, NO);
    if (!selectedString.length) {
        UITextRange *textRange = [self selectedWordTextRangeWithDelegate:delegate direction:UITextStorageDirectionForward];
        
        if (!textRange) return;
        
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
        
        tempDelegate.selectedTextRange = textRange;
        //[kbImpl deleteFromInput];
        [kbImpl deleteFromInput];
        if (smartDelete) [kbImpl insertText:@" "];
        //[tempDelegate  _moveRight:NO withHistory:nil];
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
        
    }else{
        [kbImpl deleteForwardAndNotify:YES];
        if (smartDelete) [kbImpl insertText:@" "];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    }
    
}

-(void)deleteAllAction:(UIBarButtonItem*)sender{
    
    [self selectAllAction:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self triggerImpactAndAnimationWithButton:sender selectorName:@"deleteAction:" toastWidthOffset:10 toastHeightOffset:0];
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        [kbImpl deleteFromInput];
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
    });
    
}


-(void)boldAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"toggleBold"];
    }else{
        [tempDelegate toggleBoldface:nil];
    }
}


-(void)italicAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"toggleItalic"];
    }else{
        [tempDelegate toggleItalics:nil];
    }
    
}


-(void)underlineAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)tempDelegate executeEditCommandWithCallback:@"toggleUnderline"];
    }else{
        [tempDelegate toggleUnderline:nil];
    }
}


-(void)dismissKeyboardAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:10 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    [kbImpl dismissKeyboard];
}

-(void)moveCursorLeftAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveRight"];
        }else{
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveLeft"];
        }
    }else{
        [self moveCursorWithDelegate:delegate offset:-1];
    }
}

-(void)moveCursorRightAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        BOOL isRTL  = [self isRTLForDelegate:delegate];
        if (isRTL){
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveLeft"];
        }else{
            [(WKContentView *)delegate executeEditCommandWithCallback:@"moveRight"];
        }
    }else{
        [self moveCursorWithDelegate:delegate offset:1];
    }
}

-(void)moveCursorPreviousWordAction:(UIBarButtonItem*)sender{
    if (sender || self.isWordSender){
        [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    }
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToEndOfWord:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToStartOfWord:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToStartOfWord:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToEndOfWord:NO withHistory:nil];
            //}else{
            [delegate _moveToStartOfWord:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorSingleWordWithDelegate:delegate direction:UITextStorageDirectionBackward];
        }
    }
    self.moveCursorWithSelect = NO;
    self.isWordSender = NO;
}

-(void)moveCursorNextWordAction:(UIBarButtonItem*)sender{
    if (sender || self.isWordSender){
        [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    }
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToStartOfWord:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToEndOfWord:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToEndOfWord:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfWord:NO withHistory:nil];
            //}else{
            [delegate _moveToEndOfWord:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorSingleWordWithDelegate:delegate direction:UITextStorageDirectionForward];
        }
    }
    self.moveCursorWithSelect = NO;
    self.isWordSender = NO;
}

-(void)moveCursorStartOfLineAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    self.moveCursorWithSelect = NO;
    [self moveCursorPreviousWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
    if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).start){
        [delegate _moveToStartOfLine:NO withHistory:nil];
        
        //[self moveCursorPreviousWordAction:nil];
        
    }
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToEndOfLine:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToStartOfLine:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToStartOfLine:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToEndOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToStartOfLine:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorToLineExtremityWithDelegate:delegate direction:UITextLayoutDirectionLeft];
        }
    }
    self.moveCursorWithSelect = NO;
}

-(void)moveCursorEndOfLineAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
    self.moveCursorWithSelect = NO;
    
    [self moveCursorNextWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
    if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).end){
        [self moveCursorNextWordAction:nil];
        
        [delegate _moveToEndOfLine:NO withHistory:nil];
        
    }
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToStartOfLine:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToEndOfLine:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToEndOfLine:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToEndOfLine:self.moveCursorWithSelect withHistory:nil];
            //}
        }else{
            [self moveCursorToLineExtremityWithDelegate:delegate direction:UITextLayoutDirectionRight];
        }
    }
    self.moveCursorWithSelect = NO;
}

-(void)moveCursorStartOfParagraphAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    if (startPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start){
        self.moveCursorWithSelect = NO;
        [self moveCursorPreviousWordAction:nil];
    }
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToEndOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToStartOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToStartOfParagraph:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToStartOfParagraph:self.moveCursorWithSelect withHistory:nil];
            //}
        }
    }
    self.moveCursorWithSelect = NO;
}

-(void)moveCursorEndOfParagraphAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *endPositionTemp = tempDelegate.selectedTextRange.end;
    if (endPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).end){
        self.moveCursorWithSelect = NO;
        [self moveCursorNextWordAction:nil];
    }
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    BOOL isRTL  = [self isRTLForDelegate:delegate];
    
    if (isWKContentView){
        if (isRTL){
            [(WKContentView *)delegate _moveToStartOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }else{
            [(WKContentView *)delegate _moveToEndOfParagraph:self.moveCursorWithSelect withHistory:nil];
        }
    }else{
        if ([delegate respondsToSelector:@selector(_moveToEndOfParagraph:withHistory:)]){
            //if (isRTL){
            //[delegate _moveToStartOfLine:NO withHistory:nil];
            //}else{
            [delegate _moveToEndOfParagraph:self.moveCursorWithSelect withHistory:nil];
            //}
        }
    }
    self.moveCursorWithSelect = NO;
}

-(void)moveCursorStartOfSentenceAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
    self.moveCursorWithSelect = NO;
    [self moveCursorPreviousWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
    if (((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start){
        //[delegate _moveToStartOfLine:NO withHistory:nil];
        
        [self moveCursorPreviousWordAction:nil];
        
    }
    
    [delegate _setSelectionToPosition:((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).start];
}

-(void)moveCursorEndOfSentenceAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
    self.moveCursorWithSelect = NO;
    
    [self moveCursorNextWordAction:nil];
    UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
    if (((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end){
        [self moveCursorNextWordAction:nil];
        
        //[delegate _moveToEndOfLine:NO withHistory:nil];
        
    }
    [delegate _setSelectionToPosition:((UITextRange * )[delegate _rangeOfSentenceEnclosingPosition:startPositionMovedTemp]).end];
    
}


-(void)moveCursorUpAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)delegate executeEditCommandWithCallback:@"moveUp"];
    }else{
        [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionUp];
    }
}

-(void)moveCursorDownAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    BOOL isWKContentView = [delegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        [(WKContentView *)delegate executeEditCommandWithCallback:@"moveDown"];
    }else{
        [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionDown];
    }
}

-(void)moveCursorContinuoslyWithDelegate:(id <UITextInput, UITextInputTokenizer>)delegate offset:(int)offset{
    [self moveCursorWithDelegate:delegate offset:offset];
}


-(CPDistributedMessagingCenter *)IPCCenterNamed:(NSString *)centerName{
    CPDistributedMessagingCenter *c = [CPDistributedMessagingCenter centerNamed:centerName];
    rocketbootstrap_distributedmessagingcenter_apply(c);
    return c;
}

-(BOOL)isAutoCorrectionEnabled{
    BOOL enabled = NO;
    if (!isSpringBoard){
        if (!self.xpadCenter) self.xpadCenter = [self IPCCenterNamed:kIPCCenterXPad];
        NSDictionary *result = [self.xpadCenter sendMessageAndReceiveReplyName:@"getAutoCorrectionValue" userInfo:nil];
        enabled = [result[@"value"] boolValue];
    }else{
        [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
        enabled = [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] boolForKey:7];
    }
    return enabled;
}

-(void)setAutoCorrection:(BOOL)enabled{
    if (!isSpringBoard){
        if (!self.xpadCenter) self.xpadCenter = [self IPCCenterNamed:kIPCCenterXPad];
        [self.xpadCenter sendMessageAndReceiveReplyName:@"setAutoCorrectionValue" userInfo:@{@"value":[NSNumber numberWithBool:enabled]}];
    }else{
        [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] setValue:[NSNumber numberWithBool:enabled] forKey:7];
        [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("AppleKeyboardsSettingsChangedNotification"), NULL, NULL, YES);
    }
}

-(void)updateAutoCorrection:(NSNotification*)notification{
    if (!self.isSameProcess){
        if (!self.asyncUpdated) self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
        UIImage *image = [UIImage systemImageNamed:self.autoCorrectionEnabled?@"checkmark.circle.fill":@"checkmark.circle"];
        self.autoCorrectionButton.image = image;
    }
    self.asyncUpdated = NO;
    self.isSameProcess = NO;
}

-(void)autoCorrectionAction:(UIBarButtonItem*)sender{
    self.autoCorrectionEnabled = [self isAutoCorrectionEnabled];
    [self setAutoCorrection:!self.autoCorrectionEnabled];
    self.isSameProcess = YES;
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    
    
    //sender.highlighted = !autoCorrectionEnabled;
    //sender.selected = !autoCorrectionEnabled;
    UIImage *image = [UIImage systemImageNamed:(!self.autoCorrectionEnabled)?@"checkmark.circle.fill":@"checkmark.circle"];
    sender.image = image;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kAutoCorrectionChangedIdentifier, NULL, NULL, YES);
}

-(BOOL)isAutoCapitalizationEnabled{
    BOOL enabled = NO;
    if (!isSpringBoard){
        if (!self.xpadCenter) self.xpadCenter = [self IPCCenterNamed:kIPCCenterXPad];
        NSDictionary *result = [self.xpadCenter sendMessageAndReceiveReplyName:@"getAutoCapitalizationValue" userInfo:nil];
        enabled = [result[@"value"] boolValue];
    }else{
        [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
        enabled = [[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] boolForKey:8];
    }
    return enabled;
}

-(void)setAutoCapitalization:(BOOL)enabled{
    if (!isSpringBoard){
        if (!self.xpadCenter) self.xpadCenter = [self IPCCenterNamed:kIPCCenterXPad];
        [self.xpadCenter sendMessageAndReceiveReplyName:@"setAutoCapitalizationValue" userInfo:@{@"value":[NSNumber numberWithBool:enabled]}];
    }else{
        if (!kbController){
            
            dlopen("/System/Library/PreferenceBundles/KeyboardSettings.bundle/KeyboardSettings", RTLD_LAZY);
            PSRootController *rootController = [[PSRootController alloc] initWithTitle:@"Preferences" identifier:@"com.apple.Preferences"];
            kbController = [[NSClassFromString(@"KeyboardController") alloc] init];
            if ([kbController respondsToSelector:@selector(setRootController:)]){
                [kbController setRootController:rootController];
            }
            if ([kbController respondsToSelector:@selector(setParentController:)]){
                [kbController setParentController:rootController];
            }
            //if ([kbController respondsToSelector:@selector(specifiersWithSpecifier:)])
            //[kbController specifiersWithSpecifier:nil];
        }
        NSArray *specifiers = [kbController loadAllKeyboardPreferences];
        PSSpecifier *autoCapsSpecifier;
        for (PSSpecifier *sp in specifiers){
            if ([sp.identifier isEqualToString:@"KeyboardAutocapitalization"]){
                autoCapsSpecifier = sp;
                break;
            }
        }
        if (autoCapsSpecifier){
            [kbController setKeyboardPreferenceValue:[NSNumber numberWithBool:enabled] forSpecifier:autoCapsSpecifier];
        }
        
        //[[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] setValue:[NSNumber numberWithBool:enabled] forKey:8];
        //[[objc_getClass("UIKeyboardPreferencesController") sharedPreferencesController] synchronizePreferences];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("AppleKeyboardsSettingsChangedNotification"), NULL, NULL, YES);
    }
}

-(void)updateAutoCapitalization:(NSNotification*)notification{
    if (!self.isSameProcess){
        if (!self.asyncUpdated) self.autoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
        UIImage *image;
        image = [UIImage systemImageNamed:self.autoCapitalizationEnabled?@"shift.fill":@"shift"];
        self.autoCapitalizationButton.image = image;
    }
    self.asyncUpdated = NO;
    self.isSameProcess = NO;
}

-(void)autoCapitalizationAction:(UIBarButtonItem*)sender{
    self.autoCapitalizationEnabled = [self isAutoCapitalizationEnabled];
    [self setAutoCapitalization:!self.autoCapitalizationEnabled];
    self.isSameProcess = YES;
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    
    
    //sender.highlighted = !autoCorrectionEnabled;
    //sender.selected = !autoCorrectionEnabled;
    UIImage *image;
    image = [UIImage systemImageNamed:(!self.autoCapitalizationEnabled)?@"shift.fill":@"shift"];
    sender.image = image;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kAutoCapitalizationChangedIdentifier, NULL, NULL, YES);
}

-(void)keyboardTypeAction:(UIBarButtonItem*)sender{
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    if ([delegate respondsToSelector:@selector(keyboardType)]){
        HBLogDebug(@"keyboardTypeAction: %ld", [delegate keyboardType]);
        [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        
        NSUInteger index = [self.kbType indexOfObject:[NSNumber numberWithInt:[delegate keyboardType]>12?0:[delegate keyboardType]]];
        HBLogDebug(@"kbtype current index: %ld, count: %lu", index, [self.kbType count]);
        if (index < [self.kbType count] - 1 ){
            int kbTypeInt = [self.kbType[index+1] intValue];
            HBLogDebug(@"XXXXXX===== kbTypeInt: %d, keyboardType: %@", kbTypeInt, [NSNumber numberWithInt:[delegate keyboardType]]);
            if ([delegate keyboardType] < 0 || kbTypeInt == -1 ){
                kbTypeInt = [self.kbType[index+2] intValue];
            }
            if (kbTypeInt >= 0){
                [delegate setKeyboardType:kbTypeInt];
            }else{
                [delegate setKeyboardType:self.trueKBType];
            }
        }else{
            HBLogDebug(@"ELSEEEEEE");
            int kbTypeInt = [self.kbType[0] intValue];
            int i = 1;
            while (kbTypeInt == (int)[delegate keyboardType]){
                kbTypeInt = [self.kbType[i] intValue];
                i = i + 1;
            }
            [delegate setKeyboardType:kbTypeInt];
        }
        [delegate reloadInputViews];
    }
}

-(void)updateKeyboardType:(NSNotification*)notification{
    HBLogDebug(@"updateKeyboardType");
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIImage *image;
    image = [UIImage systemImageNamed:[delegate respondsToSelector:@selector(keyboardType)]?@"number.circle.fill":@"number.circle"];
    self.keyboardInputTypeButton.image = image;
}

-(void)loupeAction:(UIBarButtonItem*)sender{
    if (!self.shortcutsGenerator.loupeDylibExist){
        return;
    }
    if (!dlsym(RTLD_DEFAULT, "flipLoupeEnableSwitch") || !dlsym(RTLD_DEFAULT, "flipLoupeEnableSwitch")){
        return;
    }
    self.loupeEnabled = loupeSwitchState();
    flipLoupeEnableSwitch(!self.loupeEnabled);
    self.isSameProcess = YES;
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    
    //sender.highlighted = !autoCorrectionEnabled;
    //sender.selected = !autoCorrectionEnabled;
    UIImage *image;
    image = [UIImage systemImageNamed:(!self.loupeEnabled?@"magnifyingglass.circle.fill":@"magnifyingglass.circle")];
    sender.image = image;
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kLoupeChangedIdentifier, NULL, NULL, YES);
}

-(void)updateLoupe:(NSNotification*)notification{
    if (!self.shortcutsGenerator.loupeDylibExist){
        return;
    }
    if (!self.isSameProcess){
        self.loupeEnabled = loupeSwitchState();
        UIImage *image = [UIImage systemImageNamed:self.loupeEnabled?@"magnifyingglass.circle.fill":@"magnifyingglass.circle"];
        self.loupeButton.image = image;
    }
    self.asyncUpdated = NO;
    self.isSameProcess = NO;
}

-(void)defineAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        NSString *selectedString = [(WKContentView *)tempDelegate selectedText];
        [(WKContentView *)tempDelegate select:nil];
        if ([selectedString length] == 0) return;
        if ([tempDelegate respondsToSelector:@selector(_define:)]){
            //[(WKContentView *)tempDelegate selectWordBackward];
            [(WKContentView *)tempDelegate _define:selectedString];
        }
    }else{
        NSString *selectedString = [tempDelegate textInRange:[tempDelegate selectedTextRange]];
        
        if (!selectedString.length) {
            UITextRange *textRange = [self autoDirectionWordSelectedTextRangeWithDelegate:tempDelegate];
            if (!textRange) return;
            tempDelegate.selectedTextRange = textRange;
            selectedString = [tempDelegate textInRange:textRange];
        }
        if ([tempDelegate respondsToSelector:@selector(_define:)]){
            [tempDelegate _define:selectedString];
        }
    }
}

-(NSDictionary *)getItemWithID:(NSString *)snippetID forKey:(NSString *)keyName identifierKey:(NSString *)identifier{
    NSArray *arrayWithEventID = [prefs[keyName] valueForKey:identifier];
    NSUInteger index = [arrayWithEventID indexOfObject:snippetID];
    NSDictionary *snippet = index != NSNotFound ? prefs[keyName][index] : nil;
    return snippet;
}

-(void)runCommand:(NSString *)cmd{
    if ([cmd length] != 0){
        if (!isSpringBoard){
            if (!self.xpadCenter) self.xpadCenter = [self IPCCenterNamed:kIPCCenterXPad];
            [self.xpadCenter sendMessageAndReceiveReplyName:@"runCommand" userInfo:@{@"value":cmd}];
        }else{
            NSMutableArray *taskArgs = [[NSMutableArray alloc] init];
            taskArgs = [NSMutableArray arrayWithObjects:@"-c", cmd, nil];
            //taskArgs = [NSMutableArray arrayWithObjects:@"-c", @"stb -m $(date +'%T')", nil];
            NSTask * task = [[NSTask alloc] init];
            [task setLaunchPath:@"/bin/bash"];
            //[task setCurrentDirectoryPath:@"/"];
            [task setArguments:taskArgs];
            [task launch];
        }
    }
}

-(void)runCommandAction:(UIBarButtonItem*)sender{
    NSDictionary *snippet = [self getItemWithID:NSStringFromSelector(_cmd) forKey:@"snippets" identifierKey:@"entryID"];
    self.commandTitle = snippet[@"title"] ? : @"Command";
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    if (snippet[@"command"]){
        [self runCommand:snippet[@"command"]];
    }
}

-(void)insertTextAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    
    if ([delegate respondsToSelector:@selector(insertText:)]) {
        NSDictionary *snippet = [self getItemWithID:NSStringFromSelector(_cmd) forKey:@"inserts" identifierKey:@"entryID"];
        
        
        int insertType;
        if (self.insertTextActionType == 0){
            insertType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        }else{
            insertType = snippet[@"typeLP"] ? [snippet[@"typeLP"] intValue] : 0;
        }
        //NSLocale* currentLocale = [NSLocale currentLocale];
        NSDate *now = [NSDate date];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSString *insertStrings = @"";
        
        switch (insertType) {
            case 0:
                if (self.insertTextActionType == 0){
                    insertStrings = snippet[@"text"];
                }else{
                    insertStrings = snippet[@"textLP"];
                }
                if ([insertStrings length] == 0){
                    insertStrings = [XPLoremIpsum getQuote];
                }
                [kbImpl insertText:insertStrings];
                break;
            case 1: //“11/23/37” or “3:30 PM”
                [df setDateStyle:NSDateFormatterShortStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                //[kbImpl insertText:[[NSDate date] descriptionWithLocale:currentLocale]];
                break;
            case 2: //“Nov 23, 1937” or “3:30:32 PM”
                [df setDateStyle:NSDateFormatterMediumStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            case 3: //“11/23/37” or “3:30 PM”
                [df setTimeStyle:NSDateFormatterShortStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            case 4: //“Nov 23, 1937” or “3:30:32 PM”
                [df setTimeStyle:NSDateFormatterMediumStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            case 5: //“Nov 23, 1937” or “3:30:32 PM”
                [df setDateStyle:NSDateFormatterMediumStyle];
                [df setTimeStyle:NSDateFormatterMediumStyle];
                [kbImpl insertText:[df stringFromDate:now]];
                break;
            default:
                break;
        }
        
        [kbImpl clearTransientState];
        [kbImpl clearAnimations];
        [kbImpl setCaretBlinks:YES];
        self.insertTextActionType = 0;
        
    }
}

-(void)copyLogAction:(UIBarButtonItem*)sender{
    if (!self.shortcutsGenerator.copyLogDylibExist){
        return;
    }
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kCopyLogOpenVewIdentifier, NULL, NULL, YES);
}

-(void)translomaticAction:(UIBarButtonItem *)sender{
    if (!self.shortcutsGenerator.translomaticDylibExist){
        return;
    }
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
    delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    NSString *selectedString = @"";
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        selectedString = [(WKContentView *)tempDelegate selectedText];
        [(WKContentView *)tempDelegate select:nil];
        if ([selectedString length] == 0) return;
    }else{
        selectedString = [tempDelegate textInRange:[tempDelegate selectedTextRange]];
        
        if (!selectedString.length) {
            UITextRange *textRange = [self autoDirectionWordSelectedTextRangeWithDelegate:tempDelegate];
            if (!textRange) return;
            tempDelegate.selectedTextRange = textRange;
            selectedString = [tempDelegate textInRange:textRange];
        }
        if ([selectedString length] == 0) return;
        
    }
    
    [(objc_getClass("TLCHelper")) fetchTranslation:selectedString vc:[self keyWindow].rootViewController];
}

-(void)wasabiAction:(UIBarButtonItem *)sender{
    if (!self.shortcutsGenerator.wasabiDylibExist){
        return;
    }
    UIKeyboardInputModeController *inputModeController = [objc_getClass("UIKeyboardInputModeController") sharedInputModeController];
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF.identifier contains[cd] %@",
                                    @"wasabi"];
    [inputModeController setCurrentInputMode:[[inputModeController.keyboardInputModes filteredArrayUsingPredicate:resultPredicate] firstObject]];
}

-(void)pasitheaAction:(UIBarButtonItem*)sender{
    if (!self.shortcutsGenerator.pasitheaDylibExist){
        return;
    }
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kPasitheaOpenVewIdentifier, NULL, NULL, YES);
}

-(void)copypastaAction:(UIBarButtonItem*)sender{
    if (!self.shortcutsGenerator.pasitheaDylibExist){
        return;
    }
    if (!dlsym(RTLD_DEFAULT, "showCopypastaWithNotification")){
        return;
    }
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    showCopypastaWithNotification();
}

-(void)tranzloAction:(UIBarButtonItem *)sender{
    if (!self.shortcutsGenerator.tranzloDylibExist){
        return;
    }
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
    NSString *selectedString = @"";
    BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
    if (isWKContentView){
        selectedString = [(WKContentView *)tempDelegate selectedText];
        [(WKContentView *)tempDelegate select:nil];
        if ([selectedString length] == 0) return;
    }else{
        selectedString = [tempDelegate textInRange:[tempDelegate selectedTextRange]];
        
        if (!selectedString.length) {
            UITextRange *textRange = [self autoDirectionWordSelectedTextRangeWithDelegate:tempDelegate];
            if (!textRange) return;
            tempDelegate.selectedTextRange = textRange;
            selectedString = [tempDelegate textInRange:textRange];
        }
        if ([selectedString length] == 0) return;
        
    }
    
    TZManager *tzManager = [(objc_getClass("TZManager")) sharedManager];
    if ([tzManager respondsToSelector:@selector(translateTextWithShortmojiShortcut:showInAlert:)]){
        [[(objc_getClass("TZManager")) sharedManager] translateTextWithShortmojiShortcut:selectedString showInAlert:YES];
    }else if ([tzManager respondsToSelector:@selector(translateText:)]){
        [[(objc_getClass("TZManager")) sharedManager] translateText:selectedString];
    }
}

-(void)globeAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    UIKeyboardInputModeController *kbController = [objc_getClass("UIKeyboardInputModeController") sharedInputModeController];
    UIKeyboardInputMode *currentInputMode = [kbController currentInputMode];
    NSMutableArray* activeInputs = [kbController activeInputModes];
    NSUInteger indexOfCurrentInputMode = [activeInputs indexOfObject:currentInputMode];
    if (preferencesBool(kEnabledSkipEmojikey, YES)){
        NSPredicate *emojiInputArray = [NSPredicate predicateWithFormat:@"SELF.normalizedIdentifier contains[cd] %@", @"emoji"];
        UIKeyboardInputMode *emojiInputmode = [[activeInputs filteredArrayUsingPredicate:emojiInputArray] firstObject];
        if (emojiInputmode) [activeInputs removeObject:emojiInputmode];
    }
    NSUInteger nextInputModeIndex = indexOfCurrentInputMode + 1;
    nextInputModeIndex = nextInputModeIndex >= [activeInputs count] ? 0 : nextInputModeIndex;
    [kbController setCurrentInputMode:activeInputs[nextInputModeIndex]];
}

-(void)dictationAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
    [[objc_getClass("UIDictationController") sharedInstance] switchToDictationInputModeWithTouch:nil];
}

-(BOOL)boolWithProbability:(double)probability{
    return rand() <  probability * ((double)RAND_MAX + 1.0);
}

-(NSString *)capitalize:(NSString *)theString probability:(double)probability{
    NSInteger theStrLen = theString.length;
    if (theStrLen == 0) return theString;
    NSMutableString *capStr = [NSMutableString stringWithCapacity:theStrLen];
    for (NSInteger i = 0; i < theStrLen; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *character = [theString substringWithRange:range];
        character = [self boolWithProbability:probability] ? [character uppercaseString] : [character lowercaseString];
        [capStr appendString:character];
    }
    return [NSString stringWithString:capStr];
}

-(NSString *)capitalizeAlternatively:(NSString *)theString{
    NSInteger theStrLen = theString.length;
    if (theStrLen == 0) return theString;
    BOOL firstSeed = [self boolWithProbability:0.5];
    NSMutableString *capStr = [NSMutableString stringWithCapacity:theStrLen];
    for (NSInteger i = 0; i < theStrLen; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *character = [theString substringWithRange:range];
        character = firstSeed ? [character uppercaseString] : [character lowercaseString];
        firstSeed = !firstSeed;
        [capStr appendString:character];
    }
    return [NSString stringWithString:capStr];
}

-(BOOL)isVowel:(NSString *)theString{
    NSAssert([theString length] == 1, @"Invalid character length");
    return ([@"aeiou" rangeOfString:[theString lowercaseString]].location != NSNotFound);
}

-(NSString *)capitalize:(NSString *)theString phonemes:(DXPhonemesType)type{
    NSInteger theStrLen = theString.length;
    if (theStrLen == 0) return theString;
    NSMutableString *capStr = [NSMutableString stringWithCapacity:theStrLen];
    for (NSInteger i = 0; i < theStrLen; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *character = [theString substringWithRange:range];
        switch (type){
            case DXPhonemesTypeConsonent:{
                character = ![self isVowel:character] ? [character uppercaseString] : [character lowercaseString];
                break;
            }
            default:{
                character = [self isVowel:character] ? [character uppercaseString] : [character lowercaseString];
                break;
            }
        }
        [capStr appendString:character];
    }
    return [NSString stringWithString:capStr];
}

-(void)spongebobAction:(UIBarButtonItem*)sender{
    [self triggerImpactAndAnimationWithButton:sender selectorName:NSStringFromSelector(_cmd) toastWidthOffset:10 toastHeightOffset:0];
    NSString *selectedString = [delegate textInRange:[delegate selectedTextRange]];
    if (!selectedString.length) {
        
        UITextRange *textRange;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
        
        UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
        UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
        UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
        
        BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
        
        if (isWKContentView){
            
        }else{
            textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
            [tempDelegate setSelectedTextRange:textRange];
        }
        
        if (!textRange) return;
        selectedString = [delegate textInRange:[delegate selectedTextRange]];
    }
    switch (spongebobEntropy){
        case DXStudlyCapsTypeAlternate:
            [kbImpl insertText:[self capitalizeAlternatively:selectedString]];
            break;
        case DXStudlyCapsTypeVowel:
            [kbImpl insertText:[self capitalize:selectedString phonemes:DXPhonemesTypeVowel]];
            break;
        case DXStudlyCapsTypeConsonent:
            [kbImpl insertText:[self capitalize:selectedString phonemes:DXPhonemesTypeConsonent]];
            break;
        default:
            [kbImpl insertText:[self capitalize:selectedString probability:0.5]];
            break;
            
    }
    [kbImpl clearTransientState];
    [kbImpl clearAnimations];
    [kbImpl setCaretBlinks:YES];
}

#pragma mark longpress actions
-(void)selectAllActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)selectLineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAllAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)selectParagraphActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAllAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)selectSentenceActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAllAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)copyActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAllAction:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self copyAction:nil];
        });
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)pasteActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAllAction:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pasteAction:nil];
        });
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)cutActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self deleteAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)undoActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self beginningAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)redoActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self endingAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
    
}


-(void)selectActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAllAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)beginningActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self undoAction:nil];
        self.parentActionName = @"";
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)endingActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self redoAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)capitalizeActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self uppercaseAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)lowercaseActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self uppercaseAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)uppercaseActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self lowercaseAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)deleteActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self deleteAllAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)deleteForwardActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self deleteAllAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)boldActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAction:nil];
        [self boldAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)italicActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAction:nil];
        [self italicAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)underlineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAction:nil];
        [self underlineAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}


-(void)dismissKeyboardActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];
     [self selectAction:nil];
     
     [self underlineAction:nil];
     self.parentActionName = @"";
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)retestGestureStatusForMovingCursor:(NSTimer *)timer{
    UILongPressGestureRecognizer *recognizer = [[timer userInfo] objectForKey:@"recognizer"];
    if (recognizer.state == UIGestureRecognizerStatePossible || recognizer.state == UIGestureRecognizerStateEnded){
        
        if (!self.retestDispatchBlock){
            HBLogDebug(@"cursorTimerRetest: %ld, dispatch: %@", recognizer.state, self.retestDispatchBlock);
            self.retestDispatchBlock = dispatch_block_create(0, ^{
                if (recognizer.state == UIGestureRecognizerStatePossible || recognizer.state == UIGestureRecognizerStateEnded){
                    [self.cursorTimer invalidate];
                    self.cursorTimer = nil;
                    self.cursorTimerSpeed = 0.0;
                    self.cursorMovingFactor = 0;
                    self.t = 0.0;
                    [self.cursorTimerRetest invalidate];
                    self.cursorTimerRetest = nil;
                }
                self.retestDispatchBlock = nil;
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.retestDispatchBlock);
        }
    }
    
}

-(void)moveCursorTimer{
    //if (labs(self.cursorMovingFactor) < 300){
    //self.cursorMovingFactor = 2* self.cursorMovingFactor;
    //}
    //if (self.cursorTimerSpeed > 0){
    self.t = self.t + 0.01;
    self.cursorTimerSpeed = 0.2*exp(-5.0*self.t);
    //self.cursorTimerSpeed = self.cursorTimerSpeed - 0.01;
    //}
    NSString *actionName;
    switch (self.cursorMovingFactor) {
        case -1:
            actionName = @"moveCursorLeftAction:";
            break;
        case 1:
            actionName = @"moveCursorRightAction:";
            break;
        case 2:
            actionName = @"moveCursorUpAction:";
            break;
        case 3:
            actionName = @"moveCursorDownAction:";
            break;
        default:
            break;
    }
    HBLogDebug(@"%f", (float)(self.cursorTimerSpeed));
    [self triggerImpactAndAnimationWithButton:nil selectorName:actionName toastWidthOffset:0 toastHeightOffset:0];
    if (self.cursorMovingFactor < 2){
        [self moveCursorContinuoslyWithDelegate:delegate offset:self.cursorMovingFactor];
    }else{
        if (self.cursorMovingFactor == 2){
            [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionUp];
        }else if (self.cursorMovingFactor == 3){
            [self moveCursorVerticalWithDelegate:delegate direction:UITextLayoutDirectionDown];
        }
    }
    //self.cursorTimer = nil;
    self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
}

-(void)moveCursorLeftActionLP:(UILongPressGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self moveCursorLeftAction:nil];
        self.cursorMovingFactor = -1;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t = 0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorRightActionLP:(UILongPressGestureRecognizer*)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self moveCursorRightAction:nil];
        self.cursorMovingFactor = 1;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t =0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorPreviousWordActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorPreviousWordAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.moveCursorWithSelect = YES;
            self.isWordSender = YES;
            [self moveCursorPreviousWordAction:nil];
        }else{
            self.isWordSender = YES;
            [self moveCursorPreviousWordAction:nil];
            [self selectAction:nil];
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorNextWordActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorNextWordAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.moveCursorWithSelect = YES;
            self.isWordSender = YES;
            [self moveCursorNextWordAction:nil];
        }else{
            self.isWordSender = YES;
            [self moveCursorNextWordAction:nil];
            [self selectAction:nil];
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorStartOfLineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorStartOfLineAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.moveCursorWithSelect = YES;
            [self moveCursorStartOfLineAction:nil];
        }else{
            kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorStartOfLineAction:" toastWidthOffset:0 toastHeightOffset:0];
            /*
             UITextPosition *startPosition = tempDelegate.selectedTextRange.start;
             [self moveCursorStartOfLineAction:nil];
             UITextPosition *endPosition = tempDelegate.selectedTextRange.start;
             UITextRange *textRange = [delegate textRangeFromPosition:startPosition toPosition:endPosition];
             [delegate setSelectedTextRange:textRange];
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
            self.moveCursorWithSelect = NO;
            [self moveCursorPreviousWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
            if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).start){
                [self moveCursorPreviousWordAction:nil];
                
                //[delegate _moveToStartOfLine:NO withHistory:nil];
                
                
            }
            [delegate _moveToEndOfLine:NO withHistory:nil];
            [delegate _moveToStartOfLine:YES withHistory:nil];
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorEndOfLineActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorEndOfLineAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.moveCursorWithSelect = YES;
            [self moveCursorEndOfLineAction:nil];
        }else{
            kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorEndOfLineAction:" toastWidthOffset:0 toastHeightOffset:0];
            /*
             UITextPosition *startPosition = tempDelegate.selectedTextRange.start;
             [self moveCursorEndOfLineAction:nil];
             UITextPosition *endPosition = tempDelegate.selectedTextRange.start;
             UITextRange *textRange = [delegate textRangeFromPosition:startPosition toPosition:endPosition];
             [delegate setSelectedTextRange:textRange];
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
            self.moveCursorWithSelect = NO;
            [self moveCursorNextWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
            if (((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfLineEnclosingPosition:startPositionTemp]).end){
                [self moveCursorNextWordAction:nil];
                
                [delegate _moveToEndOfLine:NO withHistory:nil];
                
            }
            [delegate _moveToStartOfLine:NO withHistory:nil];
            [delegate _moveToEndOfLine:YES withHistory:nil];
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorStartOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorStartOfParagraphAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.moveCursorWithSelect = YES;
            [self moveCursorStartOfParagraphAction:nil];
        }else{
            kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorStartOfParagraphAction:" toastWidthOffset:0 toastHeightOffset:0];
            /*
             self.hapticType = 0;
             UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
             if (startPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start){
             self.moveCursorWithSelect = NO;
             self.triggerImpact = YES;
             [self moveCursorPreviousWordAction:nil];
             startPositionTemp = tempDelegate.selectedTextRange.start;
             }
             UITextPosition *paragraphStartPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start;
             UITextPosition *paragraphEndPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).end;
             UITextRange *textRange = [delegate textRangeFromPosition:paragraphStartPosition toPosition:paragraphEndPosition];
             BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
             if (isWKContentView){
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
            self.moveCursorWithSelect = NO;
            [self moveCursorPreviousWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.start;
            if (((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionMovedTemp]).start == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).start){
                [delegate _moveToStartOfParagraph:NO withHistory:nil];
                
                //[self moveCursorPreviousWordAction:nil];
                
            }
            [delegate _moveToEndOfParagraph:NO withHistory:nil];
            [delegate _moveToStartOfParagraph:YES withHistory:nil];
            /*
             }else{
             [delegate setSelectedTextRange:textRange];
             }
             */
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorEndOfParagraphActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorEndOfParagraphAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        if (selectionType > 0){
            self.moveCursorWithSelect = YES;
            [self moveCursorEndOfParagraphAction:nil];
        }else{
            kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput> *)delegate;
            [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorEndOfParagraphAction:" toastWidthOffset:0 toastHeightOffset:0];
            
            /*
             UITextPosition *endPositionTemp = tempDelegate.selectedTextRange.end;
             if (endPositionTemp == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).end){
             self.moveCursorWithSelect = NO;
             self.triggerImpact = YES;
             [self moveCursorNextWordAction:nil];
             endPositionTemp = tempDelegate.selectedTextRange.end;
             }
             UITextPosition *paragraphStartPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).start;
             UITextPosition *paragraphEndPosition = ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:endPositionTemp]).end;
             UITextRange *textRange = [delegate textRangeFromPosition:paragraphStartPosition toPosition:paragraphEndPosition];
             [delegate setSelectedTextRange:textRange];
             */
            UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.end;
            self.moveCursorWithSelect = NO;
            [self moveCursorNextWordAction:nil];
            UITextPosition *startPositionMovedTemp = tempDelegate.selectedTextRange.end;
            if (((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionMovedTemp]).end == ((UITextRange * )[delegate _rangeOfParagraphEnclosingPosition:startPositionTemp]).end){
                [self moveCursorNextWordAction:nil];
                
                [delegate _moveToEndOfParagraph:NO withHistory:nil];
                
            }
            [delegate _moveToStartOfParagraph:NO withHistory:nil];
            [delegate _moveToEndOfParagraph:YES withHistory:nil];
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorStartOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorStartOfSentenceAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
        
        BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
        
        UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
        //HBLogDebug(@"startPositionTemp: %@", startPositionTemp);
        UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
        //HBLogDebug(@"startPositionSentence: %@", startPositionSentence);
        UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
        //HBLogDebug(@"endPositionSentence: %@", endPositionSentence);
        
        if (selectionType > 0){
            
            if (isWKContentView){
                [self selectAllAction:nil];
                return;
                /*
                 NSString *js = [NSString stringWithFormat:@"document.activeElement.selectionStart = %ld", [tempDelegate offsetFromPosition:tempDelegate.beginningOfDocument toPosition:startPositionSentence]];
                 //HBLogDebug(@"-----------js: %@", js);
                 //NSString *js = @"var textarea = document.getElementsByTagName('textarea')[0]; textarea.focus(); textarea.selectionStart = 0";
                 
                 WKWebView *webView = [tempDelegate webView];
                 
                 [webView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
                 //HBLogDebug(@"XXXXX-result: %@", result);
                 //HBLogDebug(@"XXXXX-error: %@", error);
                 
                 
                 }];
                 */
            }else{
                
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionTemp toPosition:startPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }else{
            if (isWKContentView){
                [self selectAllAction:nil];
                return;
            }else{
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorStartOfSentenceAction:" toastWidthOffset:0 toastHeightOffset:0];
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorEndOfSentenceActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"moveCursorEndOfSentenceAction:" forKey:@"cursormoevandselect" identifierKey:@"entryID"];
        int selectionType = snippet[@"type"] ? [snippet[@"type"] intValue] : 0;
        
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        UIResponder <UITextInput> *tempDelegate = (UIResponder <UITextInput, UITextInputTokenizer> *)delegate;
        
        BOOL isWKContentView = [tempDelegate isKindOfClass:objc_getClass("WKContentView")];
        
        UITextPosition *startPositionTemp = tempDelegate.selectedTextRange.start;
        //HBLogDebug(@"startPositionTemp: %@", startPositionTemp);
        UITextPosition *startPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).start;
        //HBLogDebug(@"startPositionSentence: %@", startPositionSentence);
        UITextPosition *endPositionSentence = ((UITextRange * )[tempDelegate _rangeOfSentenceEnclosingPosition:startPositionTemp]).end;
        //HBLogDebug(@"endPositionSentence: %@", endPositionSentence);
        
        if (selectionType > 0){
            
            if (isWKContentView){
                [self selectAllAction:nil];
                return;
                /*
                 NSString *js = [NSString stringWithFormat:@"document.activeElement.selectionStart = %ld", [tempDelegate offsetFromPosition:tempDelegate.beginningOfDocument toPosition:startPositionSentence]];
                 //HBLogDebug(@"-----------js: %@", js);
                 //NSString *js = @"var textarea = document.getElementsByTagName('textarea')[0]; textarea.focus(); textarea.selectionStart = 0";
                 
                 WKWebView *webView = [tempDelegate webView];
                 
                 [webView evaluateJavaScript:js completionHandler:^(id result, NSError *error) {
                 //HBLogDebug(@"XXXXX-result: %@", result);
                 //HBLogDebug(@"XXXXX-error: %@", error);
                 
                 
                 }];
                 */
            }else{
                
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionTemp toPosition:endPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }else{
            if (isWKContentView){
                [self selectAllAction:nil];
                return;
            }else{
                UITextRange *textRange = [tempDelegate textRangeFromPosition:startPositionSentence toPosition:endPositionSentence];
                [tempDelegate setSelectedTextRange:textRange];
            }
        }
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"moveCursorEndOfSentenceAction:" toastWidthOffset:0 toastHeightOffset:0];
        [self triggerImpactAndAnimationWithButton:nil selectorName:@"selectAction:" toastWidthOffset:0 toastHeightOffset:0];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorUpActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self moveCursorUpAction:nil];
        self.cursorMovingFactor = 2;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t = 0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)moveCursorDownActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self moveCursorDownAction:nil];
        self.cursorMovingFactor = 3;
        self.cursorTimerSpeed = 0.2;
        self.t =0.0;
        self.cursorTimer = [NSTimer scheduledTimerWithTimeInterval:self.cursorTimerSpeed target:self selector:@selector(moveCursorTimer) userInfo:nil repeats:NO];
        self.cursorTimerRetest = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(retestGestureStatusForMovingCursor:) userInfo:@{@"recognizer":recognizer} repeats:YES];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.cursorTimerSpeed = 0.0;
        self.cursorMovingFactor = 0;
        self.t = 0.0;
        [self.cursorTimer invalidate];
        self.cursorTimer = nil;
        self.retestDispatchBlock = nil;
        [self shakeView:recognizer.view];
    }
}

-(void)autoCorrectionActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     self.parentActionName = @"";
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)autoCapitalizationActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     self.parentActionName = @"";
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)keyboardTypeActionLP:(UILongPressGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        if ([delegate respondsToSelector:@selector(keyboardType)]){
            [self triggerImpactAndAnimationWithButton:nil selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
            kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
            delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
            [delegate setKeyboardType:self.trueKBType];
            [delegate reloadInputViews];
        }
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        kbImpl = [objc_getClass("UIKeyboardImpl") activeInstance];
        delegate = kbImpl.privateInputDelegate ?: kbImpl.inputDelegate;
        if ([delegate respondsToSelector:@selector(keyboardType)]){
            [self shakeView:recognizer.view];
        }
    }
    
}

-(void)defineActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     self.parentActionName = @"";
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)runCommandActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        NSDictionary *snippet = [self getItemWithID:@"runCommandAction:"  forKey:@"snippets" identifierKey:@"entryID"];
        self.commandTitle = snippet[@"titleLP"] ? : @"Command";
        [self triggerImpactAndAnimationWithButton:nil selectorName:NSStringFromSelector(_cmd) toastWidthOffset:0 toastHeightOffset:0];
        [self runCommand:snippet[@"commandLP"]];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)insertTextActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        self.insertTextActionType = 1;
        [self insertTextAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)openLog{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];
     [self selectAction:nil];
     
     [self underlineAction:nil];
     self.parentActionName = @"";
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)translomaticActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectParagraphAction:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self translomaticAction:nil];
        });
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)wasabiActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     self.parentActionName = @"";
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)pasitheaActionLP:(UILongPressGestureRecognizer *)recognizer{
    /*
     if (recognizer.state == UIGestureRecognizerStateBegan) {
     self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];     self.hapticType = 0;
     [self selectAction:nil];
     self.hapticType = 2;
     [self underlineAction:nil];
     self.parentActionName = @"";
     }else if (recognizer.state == UIGestureRecognizerStateEnded){
     [self shakeView:recognizer.view];
     }
     */
}

-(void)tranzloActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self selectParagraphAction:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tranzloAction:nil];
        });
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)globeActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self dictationAction:nil];
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
}

-(void)spongebobActionLP:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.parentActionName = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"LP:" withString:@":"];        [self selectAllAction:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self spongebobAction:nil];
        });
        self.parentActionName = @"";
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
    
}

- (void)activateDTActions:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        self.isWordSender = YES;
        [self activateLPActions:recognizer];
        [self shakeView:recognizer.view];
        self.isWordSender = NO;
    }
}

-(void)activateLPActions:(UIGestureRecognizer *)recognizer{
    BOOL isDoubleTap = [recognizer isKindOfClass:objc_getClass("UITapGestureRecognizer")];
    
    // HBLogDebug(@"recognizer: %@", (UIBarButtonItem*)(recognizer.view));
    if (recognizer.state == UIGestureRecognizerStateBegan || (isDoubleTap)) {
        NSString *gestureIdentifier = recognizer.name;
        
        if ([gestureIdentifier containsString:@"XPXPad-"]){
            NSString *action = [gestureIdentifier stringByReplacingOccurrencesOfString:@"XPXPad-" withString:@""];
            action = [action stringByReplacingOccurrencesOfString:@"LP-" withString:@""];
            action = [action stringByReplacingOccurrencesOfString:@"ST-" withString:@""];
            action = [action stringByReplacingOccurrencesOfString:@"DT-" withString:@""];
            
            int gestureType = 0;
            if (isDoubleTap) gestureType = 1;
            
            NSString *selectorName1 = preferencesSelectorForIdentifier(action, 1, gestureType, @"");
            NSString *selectorName2 = preferencesSelectorForIdentifier(action, 2, gestureType, @"");
            
            
            SEL action1 = NSSelectorFromString(selectorName1);
            SEL action2 = NSSelectorFromString(selectorName2);
            
            if ( ([selectorName1 length] > 0) && ([selectorName2 length] > 0) ){
                //https://github.com/th-in-gs/THObserversAndBinders/blob/master/THObserversAndBinders/THObserver.m
                ((void(*)(id, SEL, id))objc_msgSend)(self, action1, nil);
                //[self performSelector:action1];
                //[self performSelector:action2];
                //((void(*)(id, SEL, id))objc_msgSend)(self, action2, nil);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secondActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    ((void(*)(id, SEL, id))objc_msgSend)(self, action2, nil);
                });
                
            }else if ([selectorName1 length] > 0){
                ((void(*)(id, SEL, id))objc_msgSend)(self, action1, nil);
            }else if ([selectorName2 length] > 0){
                ((void(*)(id, SEL, id))objc_msgSend)(self, action2, nil);
            }else{
                NSString *originalSelectorName;
                if (isDoubleTap){
                    originalSelectorName = [action stringByReplacingOccurrencesOfString:@"Action:" withString:@"ActionDT:"];
                }else{
                    originalSelectorName = [action stringByReplacingOccurrencesOfString:@"Action:" withString:@"ActionLP:"];
                }
                
                SEL originalAction = NSSelectorFromString(originalSelectorName);
                
                if ([self respondsToSelector:originalAction]){
                    ((void(*)(id, SEL, id))objc_msgSend)(self, originalAction, recognizer);
                }
            }
        }
        
    }else if (recognizer.state == UIGestureRecognizerStateEnded){
        [self shakeView:recognizer.view];
    }
    
    
    
}
@end
