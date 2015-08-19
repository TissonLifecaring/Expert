//
//  SessionListViewController.m
//  SugarNursing
//
//  Created by Ian on 15/7/20.
//  Copyright (c) 2015年 Tisson. All rights reserved.
//

#import "SessionListViewController.h"
#import <WXOpenIMSDKFMWK/YWFMWK.h>
#import "SPKitExample.h"
#import "SPUtil.h"

@interface SessionListViewController ()
<
UITableViewDataSource,
UITableViewDelegate
>


@property (nonatomic, strong) NSArray *arrayPersons;

@end

@implementation SessionListViewController

- (void)awakeFromNib
{
    
    /// 加载联系人
    NSMutableArray *marr = [NSMutableArray arrayWithCapacity:20];
    for (int i = 1; i <= 10; i++) {
        [marr addObject:[[YWPerson alloc] initWithPersonId:[NSString stringWithFormat:@"uid%d", i]]];
    }
    
    [self setArrayPersons:marr];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationItem setTitle:@"联系人"];
    
    [self configureNavigationItem];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.myTableView deselectRowAtIndexPath:self.myTableView.indexPathForSelectedRow animated:YES];
}



- (void)configureNavigationItem
{
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButtonEvent:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}



- (void)cancelButtonEvent:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayPersons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PersonCell"];
    
    YWPerson *person = self.arrayPersons[indexPath.row];
    NSString *name = nil;
    UIImage *avatar = nil;
    [[SPUtil sharedInstance] getPersonDisplayName:&name avatar:&avatar ofPerson:person completeBlock:^{
        
    }];
    
    [cell.textLabel setText:name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YWPerson *person = self.arrayPersons[indexPath.row];
    [[SPKitExample sharedInstance] exampleOpenConversationViewControllerWithPerson:person fromNavigationController:self.navigationController];
}




@end
