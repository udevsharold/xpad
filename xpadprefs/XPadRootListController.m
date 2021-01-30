#include "XPadRootListController.h"
#include <spawn.h>
#include "../common.h"
#include "../XPadHelper.h"


@implementation XPadRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        
        
        NSArray *dynamicCell = @[@"modeselection", @"pxslider", @"pyslider", @"timerslider",@"shortcutstintpicker",@"toasttintpicker",@"toastbackgroundtintpicker", @"shortcutstintselection", @"toasttintselection", @"toastbackgroundtintselection"];
        self.dynamicSpecifiers = (!self.dynamicSpecifiers) ? [[NSMutableDictionary alloc] init] : self.dynamicSpecifiers;
        for(PSSpecifier *specifier in _specifiers) {
            if([dynamicCell containsObject:[specifier propertyForKey:@"id"]]) {
                [self.dynamicSpecifiers setObject:specifier forKey:[specifier propertyForKey:@"id"]];
            }
        }
    }
    
    
    return _specifiers;
}
/*
 -(void)reloadSpecifiers {
 [super reloadSpecifiers];
 
 NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
 if(![preferences[@"toastBOOL"] boolValue]) {
 [self removeContiguousSpecifiers:@[self.dynamicSpecifiers[@"pyslider"]] animated:YES];
 [self removeContiguousSpecifiers:@[self.dynamicSpecifiers[@"timerslider"]] animated:YES];
 }
 }
 */
-(void)viewDidLoad  {
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0,0,self.table.bounds.size.width,170);
    CGRect Imageframe = CGRectMake(0,10,self.table.bounds.size.width,80);
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithRed: 0.64 green: 0.69 blue: 0.74 alpha: 1.00];
    //UIImage *headerImage = [UIImage systemImageNamed:@"doc.on.doc"];
    UIImage *headerImage = [[UIImage alloc]
                            initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/PreferenceBundles/XPadPrefs.bundle"] pathForResource:@"XPad512" ofType:@"png"]];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:Imageframe];
    [imageView setImage:headerImage];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:imageView];
    
    CGRect labelFrame = CGRectMake(0,imageView.frame.origin.y + 90 ,self.table.bounds.size.width,80);
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:40];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
    [headerLabel setText:@"XPad"];
    [headerLabel setFont:font];
    [headerLabel setTextColor:[UIColor blackColor]];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [headerLabel setContentMode:UIViewContentModeScaleAspectFit];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:headerLabel];
    
    
    self.table.tableHeaderView = headerView;
    
    self.respringBtn = [[UIBarButtonItem alloc] initWithTitle: @"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
    //self.addSnippetBtn.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = self.respringBtn;
    
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:kPrefsPath];
    if(![preferences[@"toastBOOL"] boolValue]) {
        [(PSSpecifier *)self.dynamicSpecifiers[@"modeselection"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"pxslider"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] setProperty:@NO forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] setProperty:@NO forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"modeselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pxslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] animated:NO];
    }else if(![preferences[@"colorBOOL"] boolValue]){
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
    if([key isEqualToString:@"toastBOOL"]) {
        [(PSSpecifier *)self.dynamicSpecifiers[@"modeselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"pxslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"modeselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pxslider"] animated:NO];
        
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] animated:NO];
    }else if([key isEqualToString:@"colorBOOL"]){
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
    if([key isEqualToString:@"toastBOOL"]) {
        [(PSSpecifier *)self.dynamicSpecifiers[@"modeselection"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"pxslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] setProperty:value forKey:@"enabled"];
        [(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] setProperty:value forKey:@"enabled"];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"modeselection"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pxslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"pyslider"] animated:NO];
        [self reloadSpecifier:(PSSpecifier *)self.dynamicSpecifiers[@"timerslider"] animated:NO];
    }else if([key isEqualToString:@"colorBOOL"]){
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

- (void)donation {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/udevs"] options:@{} completionHandler:nil];
}

- (void)twitter {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/udevs9"] options:@{} completionHandler:nil];
}

- (void)reddit {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/h4roldj"] options:@{} completionHandler:nil];
}

- (void)respring {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"XPad" message:@"Respring now to apply changes?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *respringAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSURL *relaunchURL = [NSURL URLWithString:@"prefs:root=XPad"];
        SBSRelaunchAction *restartAction = [NSClassFromString(@"SBSRelaunchAction") actionWithReason:@"RestartRenderServer" options:4 targetURL:relaunchURL];
        [[NSClassFromString(@"FBSSystemService") sharedService] sendActions:[NSSet setWithObject:restartAction] withResult:nil];
        
        /*
         pid_t pid;
         int status;
         const char *args[] = {"killall", "-9", "SpringBoard", NULL};
         posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char * const *)args, NULL);
         waitpid(pid, &status, WEXITED);
         */
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:respringAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
    
}


@end
