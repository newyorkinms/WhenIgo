//
//  WorkListTableViewController.h
//  BZTimeCheck
//
//  Created by 강문성 on 2017. 4. 16..
//  Copyright © 2017년 강문성. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkListTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblYear;
@property (weak, nonatomic) IBOutlet UILabel *lblMonth;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
