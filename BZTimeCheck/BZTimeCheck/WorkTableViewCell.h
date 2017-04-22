//
//  WorkTableViewCell.h
//  BZTimeCheck
//
//  Created by 강문성 on 2017. 4. 16..
//  Copyright © 2017년 강문성. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WorkTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;
@property (weak, nonatomic) IBOutlet UILabel *lblWork;
@property (weak, nonatomic) IBOutlet UILabel *lblDay;

@end
