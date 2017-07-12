//
//  FRSAssignmentTypeViewController.m
//  Adjust
//
//  Created by Omar Elfanek on 7/11/17.
//

#import "FRSAssignmentTypeViewController.h"
#import "FRSDispatchConstants.h"

@interface FRSAssignmentTypeViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation FRSAssignmentTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUI];
}

- (void)configureUI {
    [self configureNavigationBar];
    
    self.view.backgroundColor = [UIColor frescoBackgroundColorDark];
    
    [self configureTableView];
}

- (void)configureNavigationBar {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    label.text = @"TYPE";
    label.font = [UIFont notaBoldWithSize:17];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    [self configureBackButtonAnimated:YES];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem setTitleView:label];
}

- (void)configureTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    
//    [tableView registerNib:[UINib nibWithNibName:@"FRSUnratedAssignmentTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"unrated-cell"];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    
    switch (indexPath.row) {
            
        case TYPE_ACCIDENT:
            cell.textLabel.text = @"Accidents";
            break;
        case TYPE_BROLL:
            cell.textLabel.text = @"B-Roll Footage";
            break;
        case TYPE_BANK:
            cell.textLabel.text = @"Bank Robbery";
            break;
        case TYPE_BOMB:
            cell.textLabel.text = @"Bomb Threat";
            break;
        case TYPE_BUILDING_COLLAPSE:
            cell.textLabel.text = @"Building Collapse";
            break;
        case TYPE_EVENT:
            cell.textLabel.text = @"Event";
            break;
        case TYPE_FIRE:
            cell.textLabel.text = @"Fire";
            break;
        case TYPE_HAZ_SUSPICIOUS:
            cell.textLabel.text = @"Hazmat/Suspicious Device";
            break;
        case TYPE_HIGH_SPEED_CHASE:
            cell.textLabel.text = @"High Speed Chases or Foot Pursuit";
            break;
        case TYPE_SHOOTING_STABBING:
            cell.textLabel.text = @"Shooting or Stabbing";
            break;
        case TYPE_RESCUE:
            cell.textLabel.text = @"Technical Rescue";
            break;
        case TYPE_TRAUMA:
            cell.textLabel.text = @"Trauma Alert";
            break;
        case TYPE_WEATHER:
            cell.textLabel.text = @"Weather";
            break;
            
        default:
            break;
    }
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return COUNT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
