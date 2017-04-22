//
//  ViewController.m
//  BZTimeCheck
//
//  Created by 강문성 on 2017. 4. 8..
//  Copyright © 2017년 강문성. All rights reserved.
//

#import "ViewController.h"
#import "JDFlipNumberView.h"
#import "JDDateCountdownFlipView.h"
#import <UserNotifications/UserNotifications.h>
#import "CommonConst.h"
@interface ViewController ()

@end

@implementation ViewController
JDDateCountdownFlipView *flipView;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"## bran1" );
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTime:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    // add info labels


    // Do any additional setup after loading the view, typically from a nib.
}
/**
 앱이 켜질 때 / 시작 될 때 / 버튼 클릭 시  출근시간과 퇴근시간의 유형성 검사를 진행 후 UI 및 데이터 저장
 */
-(void)updateTime:(NSNotification *)noti{
    /**
     시작날짜와 현재날짜가 하루차이나면  초기화
    
    */
    NSDate *tempStartDate = [[NSUserDefaults standardUserDefaults]objectForKey:TEMP_START_TIME];
    NSDate *startDate = [[NSUserDefaults standardUserDefaults]objectForKey:START_TIME];
    Boolean duplCheck = [self getDuplicationDayCheck:tempStartDate other:startDate];
    if( !duplCheck && tempStartDate != nil ){
        NSLog(@"regi ");
        [self registLocalNotification:[ViewController getRestTime:tempStartDate]];
        [[NSUserDefaults standardUserDefaults] setObject:tempStartDate forKey:START_TIME];
        NSDate *myNewDate= [ViewController getRestTime:tempStartDate];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:END_TIME];
    }else{
        NSLog(@"중복!!");
    }
    
    /**
     UI 적용
     */
    NSDate *setStartDate = [[NSUserDefaults standardUserDefaults]objectForKey:START_TIME];
    NSDate *end = [[NSUserDefaults standardUserDefaults]objectForKey:END_TIME];
    if( setStartDate!= nil){
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:timeFormat];
        NSString *str = [dateFormatter stringFromDate:setStartDate];
        [self.lblStart setText:str];
        [self setFlipRestTime:setStartDate];
        
    }
    
    if( end != nil ){
        NSLog(@"end start!!");
        [self setEndTime:end];
    }else{
        [self.lblEnd setText:@""];
        [self.lblWork setText:@""];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startClick:(id)sender {
    NSDate *startDate = [NSDate date];
    //임시로 시작 날짜를 저장
    [[NSUserDefaults standardUserDefaults] setObject:startDate forKey:TEMP_START_TIME];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //임시로 저장한 시작 날짜가 맞는지 체크 후 UI 반영
    [self updateTime:nil];
}


- (IBAction)endClick:(id)sender {
    NSDate *endDate = [NSDate date];
    [self setEndTime:endDate];
}

/**
 퇴근하면 Flip 타이머 정지 및 현재 Date 저장
 */
-(void)setEndTime:(NSDate *)endDate{
    NSDate *startDate = [[NSUserDefaults standardUserDefaults]objectForKey:START_TIME];
    if(startDate == nil){
        NSLog(@"startDate  is nil ");
        
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:endDate forKey:END_TIME];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:timeFormat];
    //일한시간 측정
    NSDateComponents *workTime = [ViewController getCompareDate:startDate endDate:endDate];
    NSString *strWorkTime = [NSString stringWithFormat:@"%02ld:%02ld", [workTime hour] , [workTime minute] ];
    NSString *str = [dateFormatter stringFromDate:endDate];
    [self.lblWork setText:strWorkTime];
    [self.lblEnd setText:str];
    /**
     출근시간 / 퇴근시간 리스트에 저장!!! 중요 
     */
    [self saveWorkTimeList];
    //시작시간과 임시 시작 시간을 모두 초기화
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:TEMP_START_TIME];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:START_TIME];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //시계정지
    if( flipView != nil){
        [flipView stop];
    }
    
    /**
     퇴근 노티 알림 삭제
     */
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center removeAllPendingNotificationRequests];
}
/**
 시작날짜부터 끝나는 날까지의 시간차이 계산
 */
+(NSDateComponents *)getCompareDate:(NSDate *)startDate endDate:(NSDate *)endDate{
    NSDateComponents *components;
    components = [[NSCalendar currentCalendar] components: NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate: startDate toDate: endDate options: 0];
    return components;
}
/**
 출근 시간으로 부터 9시간 후 남은 시간
 */
+(NSDate *)getRestTime:(NSDate *)startDate{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:timeFormat];
    NSDateComponents *components= [[NSDateComponents alloc] init];
    //[components setSecond:9];
    [components setHour:WORK_TIME];
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:startDate];
    NSDate *myNewDate=[calendar dateByAddingComponents:components toDate:startDate options:0];
    NSString *estr = [dateFormatter stringFromDate:myNewDate];
    
    return myNewDate;
}
-(void)setFlipRestTime:(NSDate *)startDate{
    flipView = [[JDDateCountdownFlipView alloc] initWithDayDigitCount:0 imageBundleName:@"JDFlipNumberView"];
    [self.timeView addSubview: flipView];
    
    // countdown to silvester
    NSDateFormatter *flipdateFormatter = [[NSDateFormatter alloc] init];
    [flipdateFormatter setDateFormat: @"dd.MM.yy HH:mm"];
    //flipView.targetDate = [flipdateFormatter dateFromString:[NSString stringWithFormat: @"01.01.%ld 00:00", (long)currentComps.year+1]];
    flipView.targetDate = [ViewController getRestTime:startDate];
    //flipView.frame = CGRectInset(self.timeView.bounds, 100, 100);
    //flipView.frame = CGRectMake(10,100,100,100);
    flipView.frame = [self.timeView frame];
    
}

-(void)test2{
    UILocalNotification *localNofication = [[UILocalNotification alloc] init];
    
    if (localNofication == nil) return;
    
    NSDate *pushDate = [[NSDate date] dateByAddingTimeInterval:10];
    
    localNofication.fireDate = pushDate;
    localNofication.timeZone = [NSTimeZone defaultTimeZone];
    localNofication.alertBody = @"퇴근하셔야죠";
    localNofication.alertAction = @"View";
    localNofication.soundName = UILocalNotificationDefaultSoundName;
    localNofication.applicationIconBadgeNumber = 1;
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject: @"퇴근하세요" forKey:@"message"];
    localNofication.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNofication];
}
-(void)test{
    NSLog(@" test");
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Don't forget";
    content.body = @"Buy some milk";
    content.sound = [UNNotificationSound defaultSound];
    content.categoryIdentifier = @"GENERAL";
    // Configure the trigger for a 7am wakeup.
    NSDate *pushDate = [[NSDate date] dateByAddingTimeInterval:10];
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.hour = 0;
    date.minute = 0;
    date.second = 10;
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
                                              triggerWithDateMatchingComponents:date repeats:NO];
    
    // Create the request object.
    UNNotificationRequest* request = [UNNotificationRequest
                                      requestWithIdentifier:@"MorningAlarm" content:content trigger:trigger];
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *erro){
        NSLog(@"send");
    }];
    
    UNTimeIntervalNotificationTrigger *trigger2 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
                                                                                                    repeats:NO];
    UNNotificationRequest* request2 = [UNNotificationRequest
                                      requestWithIdentifier:@"MorningAlarm" content:content trigger:trigger2];
    [center addNotificationRequest:request2 withCompletionHandler:^(NSError *erro){
        if( erro != nil){
            NSLog(@"send " );
        }
    }];
    
}
/**
 로컬 노티 등록
 */
-(void)registLocalNotification:(NSDate *)now{
    //now = [NSDate date];
    
    // NSLog(@"NSDate--before:%@",now);
    
    //now = [now dateByAddingTimeInterval:10];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:timeFormat];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSString *str = [dateFormatter stringFromDate:now];
    NSLog(@"NSDate:%@",str);
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [calendar setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSTimeZoneCalendarUnit fromDate:now];
    
    NSDate *todaySehri = [calendar dateFromComponents:components]; //unused
    
    
    
    UNMutableNotificationContent *objNotificationContent = [[UNMutableNotificationContent alloc] init];
    objNotificationContent.title = [NSString localizedUserNotificationStringForKey:@"퇴근!" arguments:nil];
    objNotificationContent.body = [NSString localizedUserNotificationStringForKey:@"퇴근하셔야합니다!"
                                                                        arguments:nil];
    objNotificationContent.sound = [UNNotificationSound defaultSound];
    
    /// 4. update application icon badge number
    //objNotificationContent.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
    objNotificationContent.badge = [NSNumber numberWithInt:1];
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"ten"
                                                                          content:objNotificationContent trigger:trigger];
    /// 3. schedule localNotification
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Local Notification succeeded");
        }
        else {
            NSLog(@"Local Notification failed");
        }
    }];
    
    
}
/**
 현재 날짜와 오늘 날짜가 같은지 체크
 */
-(Boolean)getDuplicationDayCheck:(NSDate *)date other:(NSDate *)other{
    if(date == nil || other == nil){
        return false;
    }
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:other];
    NSDateComponents *startComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSInteger nowDay = [nowComponents day];
    NSInteger startDay = [startComponents day];
    //같은날에 중복 시작을 할 수 없게 설정
    Boolean duplCheck = nowDay == startDay ? YES : NO;
    return duplCheck;
}
/**
 출/퇴근 시간을 월/일 별로 저장
 */
-(void)saveWorkTimeList{
    NSDate *startDate = [[NSUserDefaults standardUserDefaults]objectForKey:START_TIME];
    NSDate *end = [[NSUserDefaults standardUserDefaults]objectForKey:END_TIME];
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:startDate];
    NSString *year = [NSString stringWithFormat:@"%ld" , [nowComponents year] ];
    NSString *month = [NSString stringWithFormat:@"%ld" ,[nowComponents month]];
    NSString *day = [NSString stringWithFormat:@"%ld" ,[nowComponents day]];
    
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
    NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
    [data setValue:startDate forKey:START_TIME];
    [data setValue:end forKey:END_TIME];
    [dicMonth setValue:data forKey:day];
    
    [dicYear setValue:dicMonth forKey:month];
    [dicAll setValue:dicYear forKey:year];
    
    [[NSUserDefaults standardUserDefaults]setObject:dicAll forKey:WORK_LIST];
}
@end
