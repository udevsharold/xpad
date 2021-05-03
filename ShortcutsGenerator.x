#include "common.h"
#include "ShortcutsGenerator.h"

@implementation ShortcutsGenerator

+(void)load{
    @autoreleasepool {
        NSArray *args = [[NSClassFromString(@"NSProcessInfo") processInfo] arguments];
        
        if (args.count != 0) {
            NSString *executablePath = args[0];
            
            if (executablePath) {
                NSString *processName = [executablePath lastPathComponent];
                
                BOOL isSpringBoard = [processName isEqualToString:@"SpringBoard"];
                BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;
                
                if (isSpringBoard || isApplication) {
                    [ShortcutsGenerator sharedInstance];
                    
                }
            }
        }
    }
}

+(instancetype)sharedInstance{
    static dispatch_once_t predicate;
    static ShortcutsGenerator *generator;
    dispatch_once(&predicate, ^{ generator = [[self alloc] init]; });
    return generator;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        self.copyLogDylibExist = [self dylibExist:copyLogDylib manager:fileManager];
        self.translomaticDylibExist = [self dylibExist:translomaticDylib manager:fileManager];
        self.wasabiDylibExist = [self dylibExist:wasabiDylib manager:fileManager];
        self.pasitheaDylibExist = [self dylibExist:pasitheaDylib manager:fileManager];
        self.copypastaDylibExist = [self dylibExist:copypastaDylib manager:fileManager];
        self.loupeDylibExist = [self dylibExist:loupeDylib manager:fileManager];
    }
    return self;
}

-(NSArray *)imageNameArrayForiOS:(NSInteger)iosVersion{
    // 0 = iOS 12
    // 1 = iOS 13+
    NSArray *array;
    if (iosVersion == 0){
        array = @[@"UIButtonBarListIcon",@"UIButtonBarKeyboardCopy",@"UIButtonBarKeyboardPaste",@"UIButtonBarKeyboardCut",@"UIButtonBarKeyboardUndo",@"UIButtonBarKeyboardRedo", @"UIButtonBarKeyboardItalic", @"UIButtonBarArrowLeft", @"UIButtonBarArrowRight", @"shift_portrait_skinny", @"UIButtonBarArrowDown", @"shift_lock_portrait_skinny", @"delete_portrait", @"UIButtonBarKeyboardBold", @"UIButtonBarKeyboardItalic", @"UIButtonBarKeyboardUnderline", @"bold_dismiss_landscape", @"Black_BreadcrumbArrowLeft", @"Black_BreadcrumbArrowRight", @"UIAccessoryButtonCheckmark", @"shift_on_portrait", @"reachable_full", @"KeyGlyph-upArrow-large", @"KeyGlyph-downArrow-large", @"UITabBarSearchTemplate", @"KeyGlyph-command-large", @"messages_writeboard", @"UICalloutBarPreviousArrow", @"UICalloutBarNextArrow", @"KeyGlyph-rtlTab-larg", @"KeyGlyph-tab-large", @"KeyGlyph-return-large", @"KeyGlyph-rtlReturn-large", @"UIMovieScrubberEditingGlassLeft", @"UIMovieScrubberEditingGlassRight", @"UIRemoveControlMinusStroke", @"UITableGrabber", @"UIButtonBarListIcon", @"globe_dockitem-portrait", @"dictation_dockitem-portrait", @"delete_portrait", @"bold_emoji_activity"];
    }else{
        array = @[@"doc.text",@"doc.on.doc",@"doc.on.clipboard",@"scissors",@"arrow.uturn.left.circle",@"arrow.uturn.right.circle", @"text.cursor", @"chevron.left.circle", @"chevron.right.circle", @"textformat.alt", @"textformat.abc", @"capslock", @"delete.left", @"bold", @"italic", @"underline", @"keyboard.chevron.compact.down", @"arrowtriangle.left.circle.fill", @"arrowtriangle.right.circle.fill", @"checkmark.circle.fill", @"shift.fill", @"number.circle.fill", @"arrowtriangle.up.circle.fill", @"arrowtriangle.down.circle.fill", @"doc.text.magnifyingglass", @"command", @"text.bubble", @"arrow.left.circle.fill", @"arrow.right.circle.fill", @"arrow.left.to.line", @"arrow.right.to.line", @"text.insert", @"text.append", @"decrease.quotelevel", @"increase.quotelevel", @"line.horizontal.3", @"paragraph", @"list.bullet", @"globe", @"mic", @"delete.right", @"circle.grid.3x3"];
    }
    array = [self thirdPartyImageNameArray:array foriOS:iosVersion];
    return array;
}

-(NSArray *)selectorNameForLongPress:(BOOL)longPress{
    NSArray *array = @[@"selectAllAction:",@"copyAction:",@"pasteAction:",@"cutAction:",@"undoAction:",@"redoAction:", @"selectAction:", @"beginningAction:", @"endingAction:", @"capitalizeAction:", @"lowercaseAction:", @"uppercaseAction:", @"deleteAction:", @"boldAction:", @"italicAction:", @"underlineAction:", @"dismissKeyboardAction:", @"moveCursorLeftAction:", @"moveCursorRightAction:", @"autoCorrectionAction:", @"autoCapitalizationAction:", @"keyboardTypeAction:", @"moveCursorUpAction:", @"moveCursorDownAction:", @"defineAction:", @"runCommandAction:", @"insertTextAction:", @"moveCursorPreviousWordAction:", @"moveCursorNextWordAction:", @"moveCursorStartOfLineAction:", @"moveCursorEndOfLineAction:", @"moveCursorStartOfParagraphAction:", @"moveCursorEndOfParagraphAction:", @"moveCursorStartOfSentenceAction:", @"moveCursorEndOfSentenceAction:", @"selectLineAction:", @"selectParagraphAction:", @"selectSentenceAction:", @"globeAction:", @"dictationAction:", @"deleteForwardAction:", @"spongebobAction:"];
    
    if (longPress){
        NSMutableArray *longPressArray = [[NSMutableArray alloc] init];
        for (NSString *selName in array){
            [longPressArray addObject:[selName stringByReplacingOccurrencesOfString:@":" withString:@"LP:"]];
        }
        array = longPressArray;
    }
    array = [self thirdPartySelectorNameArray:array longPress:longPress];
    return array;
}

-(NSArray *)labelName{
    NSArray *array = @[@"Select All", @"Copy", @"Paste", @"Cut", @"Undo", @"Redo", @"Select", @"Beginning of Document", @"Ending of Document", @"Capitalize Last Word", @"lowercase", @"UPPERCASE", @"Delete", @"Bold", @"Italic", @"Underline", @"Dismiss Keyboard", @"Cursor Left", @"Cursor Right", @"Auto-Correction", @"Auto-Capitalization", @"Keyboard Input", @"Cursor Up", @"Cursor Down", @"Define Word", @"Shell Command", @"Insert Text", @"Previous Word", @"Next Word", @"Line Start", @"Line End", @"Start of Paragraph", @"End of Paragraph", @"Start of Sentence", @"End of Sentence", @"Select Line", @"Select Paragraph", @"Select Sentence", @"Globe", @"Dictation", @"Delete Forward", @"sPonGeBob teXt"];
    array = [self thirdPartyLabelNameArray:array];
    return array;
}

-(BOOL)dylibExist:(NSString *)dylibPath manager:(NSFileManager *)fileManager{
    return [fileManager fileExistsAtPath:dylibPath];
}

-(NSArray *)thirdPartyImageNameArray:(NSArray *)array foriOS:(NSInteger)iosVersion{
    NSMutableArray *thirdPartArray = [array mutableCopy];
    if (self.copyLogDylibExist){
        [thirdPartArray addObject:@"CUSTOM_/Library/Application Support/CopyLog/Ressources.bundle/keyboardlogo.png"];
    }
    if (self.translomaticDylibExist){
        [thirdPartArray addObject:@"CUSTOM_/Library/MobileSubstrate/DynamicLibraries/com.foxfort.translomatic.bundle/trans_24.png"];
    }
    if (self.wasabiDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"UIButtonBarCompose"];
        }else{
            [thirdPartArray addObject:@"rectangle.and.paperclip"];
        }
    }
    if (self.pasitheaDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"UIButtonBarCompose"];
        }else{
            [thirdPartArray addObject:@"rectangle.and.paperclip"];
        }
    }
    if (self.copypastaDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"UIButtonBarCompose"];
        }else{
            [thirdPartArray addObject:@"rectangle.and.paperclip"];
        }
    }
    if (self.loupeDylibExist){
        if (iosVersion == 0){
            [thirdPartArray addObject:@"kb-loupe-hi"];
        }else{
            [thirdPartArray addObject:@"magnifyingglass.circle.fill"];
        }
    }
    return thirdPartArray;
}

-(NSArray *)thirdPartySelectorNameArray:(NSArray *)array longPress:(BOOL)longPress{
    NSMutableArray *thirdPartArray = [array mutableCopy];
    if (self.copyLogDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"copyLogActionLP:"];
        }else{
            [thirdPartArray addObject:@"copyLogAction:"];
        }
    }
    if (self.translomaticDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"translomaticActionLP:"];
        }else{
            [thirdPartArray addObject:@"translomaticAction:"];
        }
    }
    if (self.wasabiDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"wasabiActionLP:"];
        }else{
            [thirdPartArray addObject:@"wasabiAction:"];
        }
    }
    if (self.pasitheaDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"pasitheaActionLP:"];
        }else{
            [thirdPartArray addObject:@"pasitheaAction:"];
        }
    }
    if (self.copypastaDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"copypastaActionLP:"];
        }else{
            [thirdPartArray addObject:@"copypastaAction:"];
        }
    }
    if (self.loupeDylibExist){
        if (longPress){
            [thirdPartArray addObject:@"loupeActionLP:"];
        }else{
            [thirdPartArray addObject:@"loupeAction:"];
        }
    }
    return thirdPartArray;
}

-(NSArray *)thirdPartyLabelNameArray:(NSArray *)array{
    NSMutableArray *thirdPartArray = [array mutableCopy];
    if (self.copyLogDylibExist){
        [thirdPartArray addObject:@"CopyLog"];
    }
    if (self.translomaticDylibExist){
        [thirdPartArray addObject:@"Translomatic"];
    }
    if (self.wasabiDylibExist){
        [thirdPartArray addObject:@"Wasabi"];
    }
    if (self.pasitheaDylibExist){
        [thirdPartArray addObject:@"Pasithea"];
    }
    if (self.copypastaDylibExist){
        [thirdPartArray addObject:@"Copypasta"];
    }
    if (self.loupeDylibExist){
        [thirdPartArray addObject:@"Loupe"];
    }
    return thirdPartArray;
}

-(NSArray *)keyboardTypeLabel{
    NSArray *array = @[@"Original", @"Default", @"Decimal Pad", @"Number Pad", @"URL", @"eMail", @"ASCII", @"Num & Punct.", @"Phone Pad", @"Name & Phone", @"Twitter", @"Web Search", @"Number Pad", @"Alphabet"];
    return array;
}

-(NSArray *)keyboardTypeData{
    NSArray *array = @[@-1, @0, @8, @4, @3, @7, @1, @2, @5, @6, @9, @10, @11, @12];
    return array;
}
@end


