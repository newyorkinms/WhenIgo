//
//  WorkListTableViewController.m
//  BZTimeCheck
//
//  Created by 강문성 on 2017. 4. 16..
//  Copyright © 2017년 강문성. All rights reserved.
//

#import "WorkListTableViewController.h"
#import "CommonConst.h"
#import "WorkTableViewCell.h"
#import "ViewController.h"
@interface WorkListTableViewController ()

@property (nonatomic, strong) NSMutableArray *tableViewItems;
@end

@implementation WorkListTableViewController
static NSInteger curMonth;
static NSInteger curYear;
static NSDateComponents *overWorkDate;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self _buildSource];
    NSDate *d = [[NSCalendar currentCalendar] dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    overWorkDate = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:d];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    //[self.tableView registerClass:[WorkTableViewCell class] forCellReuseIdentifier:@"WorkTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WorkView" bundle:nil] forCellReuseIdentifier:@"workCell"];
    [self.view addSubview:self.tableView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    [self createList:curYear month:curMonth];
    [self.tableView reloadData];
}


-(void)_buildSource{
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSString *year = [NSString stringWithFormat:@"%ld" , [nowComponents year] ];
    NSString *month = [NSString stringWithFormat:@"%ld" ,[nowComponents month]];
    NSString *day = [NSString stringWithFormat:@"%ld" ,[nowComponents day]];
    curMonth = [month integerValue];
    curYear = [year integerValue];
    //[self createList:[year integerValue] month:[month integerValue]];
    
}
-(void)createList:(NSInteger )mYear month:(NSInteger )mMonth{
    self.tableViewItems = [[NSMutableArray alloc]init];
    NSString *year = [NSString stringWithFormat:@"%ld" , mYear ];
    NSString *month = [NSString stringWithFormat:@"%ld" ,mMonth];
    curMonth = [month intValue];
    NSMutableDictionary *dicAll = [[[NSUserDefaults standardUserDefaults]objectForKey:WORK_LIST] mutableCopy];
    if( dicAll == nil ){
        dicAll = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *dicYear = [[dicAll objectForKey:year] mutableCopy];
    if(dicYear == nil ){
        dicYear = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary *dicMonth = [[dicYear objectForKey:month] mutableCopy];
    if(dicMonth == nil){
        dicMonth = [[NSMutableDictionary alloc]init];
    }
    NSArray *sorted = [[dicMonth allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger ob1 = [obj1  integerValue];
        NSInteger ob2 = [obj2  integerValue];
        return ob1 < ob2;
    }];
    for( NSString  *key in sorted){
        NSDictionary *dic = [dicMonth objectForKey:key];
        //NSDate *startDate = [dic objectForKey:START_TIME];
        //NSDate *endDate = [dic objectForKey:END_TIME];
        //NSString *str = [NSString stringWithFormat:@" %@ ~ %@ " , [self getFormatDate:startDate] , [self getFormatDate:endDate]];
        [self.tableViewItems addObject:dic];
        
        
    }
    NSString *strMonth = [NSString stringWithFormat:@"%@ 월",month ];
    NSString *strYear = [NSString stringWithFormat:@"%@ 년",year ];
    [self.lblMonth setText:strMonth];
    [self.lblYear setText:strYear];
}
-(NSString *)getFormatDate:(NSDate *)date{

    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd  HH:mm:ss"];
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.tableViewItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"workCell" forIndexPath:indexPath];
    NSDictionary *dic = [self.tableViewItems objectAtIndex:[indexPath row]];
    //cell.textLabel.text = str;
    NSDate *dateStart = [dic objectForKey:START_TIME];
    NSDate *dateEnd = [dic objectForKey:END_TIME];
    if(dateEnd == nil|| dateStart ==nil){
        return nil;
    }
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dateStart];
    
    NSString *strDay  = [NSString stringWithFormat:@"%ld일" , [nowComponents day] ];
    NSString *strStart = [self getFormatDate:dateStart];
    NSString *strEnd = [self getFormatDate:dateEnd];
    [cell.lblStart setText: strStart];
    [cell.lblEnd setText: strEnd];
    [cell.lblDay setText:strDay];
    
    //일한시간 측정
    NSDateComponents *workTime = [ViewController getCompareDate:dateStart endDate:dateEnd];
    NSString *strWorkTime = [NSString stringWithFormat:@"%02ld:%02ld", [workTime hour] , [workTime minute] ];
    // Configure the cell...
    [cell.lblWork setText:strWorkTime];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"##");
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)clickCloseBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)clickNextBtn:(UIButton *)sender {
    if( ![self checkMonthInvalid:curMonth+1] ) {
       
    }else{
        curMonth += 1;
    }
    
    [self createList:curYear month:curMonth];
    [self.tableView reloadData];
}
- (IBAction)clickPrevBtn:(UIButton *)sender {
    
    if( ![self checkMonthInvalid:curMonth-1] ) {
        
    }else{
        curMonth -= 1;
    }
    [self createList:curYear month:curMonth];
    [self.tableView reloadData];
}
// 년도와 월 관리
-(Boolean)checkMonthInvalid:(NSInteger)month{
    if(month < 1){
        curYear -= 1;
        curMonth = 12;
        return false;
    }else if(month > 12 ){
        curYear += 1;
        curMonth = 1;
        return false;
    }
    return true;
}

@end
