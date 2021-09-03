#import "XPPCustomizationController.h"
#import "../common.h"

@implementation XPPCustomizationController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Customization" target:self];
        
        NSArray *dynamicCell = @[@"pyslider", @"timerslider",@"shortcutstintpicker",@"toasttintpicker",@"toastbackgroundtintpicker", @"granularityslider", @"displaytypeselection", @"gesturetypeselection", @"gesturebuttonselection",@"shortcutstintselection", @"toasttintselection", @"toastbackgroundtintselection", @"shortcutsbackgroundtintpicker", @"shortcutsbackgroundtintselection"];
        self.dynamicSpecifiers = (!self.dynamicSpecifiers) ? [[NSMutableDictionary alloc] init] : self.dynamicSpecifiers;
        for(PSSpecifier *specifier in _specifiers) {
            if([dynamicCell containsObject:[specifier propertyForKey:@"id"]]) {
                [self.dynamicSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
            }
        }
    }
    
    
    return _specifiers;
}

-(void)viewDidLoad  {
    [super viewDidLoad];
    
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    if(![preferences[@"colorBOOL"] boolValue]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] setProperty:@NO forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] animated:NO];
    }
}

-(id)readPreferenceValue:(PSSpecifier*)specifier{
    
    id value = [super readPreferenceValue:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"colorBOOL"]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] setProperty:value forKey:@"enabled"];
        //[self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] animated:NO];
        //[self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] animated:NO];
        //[self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] animated:NO];
    }
    return value;
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier{
    [super setPreferenceValue:value specifier:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if([key isEqualToString:@"colorBOOL"]){
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintpicker"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"shortcutstintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toasttintselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"toastbackgroundtintselection"] animated:NO];
    }
}

@end
