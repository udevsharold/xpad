#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import "../common.h"

@interface XPPManageShortcutsController : PSViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *currentOrder;
@property (nonatomic, strong) NSMutableArray *extrasOptions;
@property (nonatomic, strong) NSArray *fullOrder;
@property (nonatomic, strong) NSArray *firstOrder;
@property(nonatomic, retain) UIBarButtonItem *resetBtn;
@end
