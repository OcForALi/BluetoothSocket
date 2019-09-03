//
//  BaseControlModel.m
//  WiFiSocket
//
//  Created by Mac on 2018/6/11.
//  Copyright © 2018年 QiXing. All rights reserved.
//

#import "BaseControlModel.h"
#import "BaseControlModel+ConstantTemperature.h"

@interface BaseControlModel ()<WKScriptMessageHandler,UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSMutableDictionary *reportDic;
@property (nonatomic, strong) NSMutableDictionary *temperAndHumiDic;
@property (nonatomic, strong) NSMutableDictionary *powerAndCostDic;

@end

@implementation BaseControlModel

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init
{
    if (self = [super init]) {
        self.temperAndHumiDic = [[NSMutableDictionary alloc] init];
        [self.temperAndHumiDic setObject:@{
                                           @"currentValue": @(0),
                                           @"hotAlarmValue": @(0),
                                           @"hotAlarmSwitch": @(false),
                                           @"codeAlarmValue": @(0),
                                           @"codeAlarmSwitch": @(false)
                                           } forKey:@"temperature"];
        self.powerAndCostDic = [[NSMutableDictionary alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didInFround) name:UIApplicationWillEnterForegroundNotification object:nil];
        //    NSDictionary *dic = @{
        //                          @"power": @{
        //                                  @"value": @(0),
        //                                  @"averageValue": @(0),
        //                                  @"maximumValue": @(0)
        //                                  },
        //                          @"voltage": @(0),
        //                          @"electricity": @(0),
        //                          @"frequency": @(0),
        //                          @"temperature": @{
        //                                  @"value": @(0),
        //                                  @"alarmValue": @(0)
        //                                  },
        //                          @"humidity": @{
        //                                  @"value": @(0),
        //                                  @"alarmValue": @(0)
        //                                  },
        //                          @"weight": @(0),
        //                          @"cost": @(0),
        //                          @"countDown": @(0)
        //                          };
        self.reportDic = [[NSMutableDictionary alloc] init];
//        [self countdownDataRequest:nil];
    }
    return self;
}

- (NSArray *)funArr
{
    return @[
             @"socketStatusRequest", //插座状态数据
             @"powerSwitchStatusRequest", //插座电源开关状态
             @"powerSwitchRequest", //插座电源开关控制
             @"commonPatternListDataRequest", //定时列表数据
             @"commonPatternNewTimingRequest", //普通模式新建定时
             @"commonPatternEditTimingRequest", //普通模式编辑定时
             @"commonPatternDeleteTimingRequest", //删除定时
             @"countdownDataRequest", //倒计时页面数据
             @"powerSwitchCountdownRequest", //设置电源开关倒计时
             @"temperatureAndHumidityDataRequest", //温湿度页面数据
             @"alarmTemperatureValueRequest", //设置告警温度值
             @"alarmHumidityValueRequest", //设置告警湿度值
             @"spendingCountdownDataRequest",//查询定量定费
             @"spendingCountdownAlarmRequest",//设置定量定费
             @"temperatureSensorStateRequest",  //温度传感器状态查询
             @"timingConstTemperatureDataRequest",  //温度-恒温模式列表数据查询
             @"timingConstTemperatureDataSet",  //温度-恒温模式设置 新建/编辑
             @"timingConstTemperatureDataDelete",   //温度-恒温模式删除
             ];
}

- (NSDictionary *)funDic
{
    return @{
             @"powerSwitchStatusRequest":@"powerSwitchStatusRequest:",//插座开关状态
             @"powerSwitchRequest":@"powerSwitchRequest:",//插座开关控制
             @"commonPatternListDataRequest":@"commonPatternListDataRequest:",//定时列表数据
             @"commonPatternNewTimingRequest":@"commonPatternNewTimingRequest:",//新建定时
             @"commonPatternEditTimingRequest":@"commonPatternEditTimingRequest:",//编辑定时
             @"commonPatternDeleteTimingRequest":@"commonPatternDeleteTimingRequest:",//删除定时
             @"countdownDataRequest":@"countdownDataRequest:",//倒计时页面数据
             @"powerSwitchCountdownRequest":@"powerSwitchCountdownRequest:",//开关倒计时
             @"temperatureAndHumidityDataRequest":@"temperatureAndHumidityDataRequest:",//查询定温湿度
             @"alarmTemperatureValueRequest":@"alarmTemperatureValueRequest:",//设置温度警告值
             @"alarmHumidityValueRequest":@"alarmHumidityValueRequest:",//设置湿度警告值
             @"spendingCountdownDataRequest":@"spendingCountdownDataRequest:",//查询定量定费
             @"spendingCountdownAlarmRequest":@"spendingCountdownAlarmRequest:",//设置定量定费
             @"temperatureSensorStateRequest":@"temperatureSensorStateRequest:",  //温度传感器状态查询
             @"timingConstTemperatureDataRequest":@"timingConstTemperatureDataRequest:",  //温度-恒温模式列表数据查询
             @"timingConstTemperatureDataSet":@"timingConstTemperatureDataSet:",  //温度-恒温模式设置 新建/编辑
             @"timingConstTemperatureDataDelete":@"timingConstTemperatureDataDelete:",   //温度-恒温模式删除
             };
}


#pragma mark 进入前台
- (void)didInFround
{
    NSString *jsCode = [[NSString alloc] initWithFormat:@"brightScreenResponse(%d)",true];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 请求插座实时状态数据
- (void)socketStatusRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    BOOL recevie = [[object objectForKey:@"receive"] boolValue];
    if (recevie) {
        NSDictionary *dic =[[NSDictionary alloc] initWithDictionary:[self.reportDic objectForKey:mac]];
        NSString *json = [ToolHandle toJsonString:dic];
        NSString *jsCode = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",mac,json];
        [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
    }
}

#pragma mark 上报插座实时状态数据
- (void)ReportingRealTimeData:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"上报温湿度功率数据........");
    NSMutableDictionary *muDic =[[NSMutableDictionary alloc] initWithDictionary:[self.reportDic objectForKey:deviceMac]];
    for (NSString *key in object.allKeys) {
        [muDic setObject:[object objectForKey:key] forKey:key];
    }
    [self.reportDic setValue:muDic forKey:deviceMac];
    NSString *json = [ToolHandle toJsonString:muDic];
    NSString *jsCode = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
    if (object[@"temperature"]) {
        NSDictionary *dic = object[@"temperature"];
        NSMutableDictionary *temperature = [NSMutableDictionary dictionaryWithDictionary:[self.temperAndHumiDic objectForKey:@"temperature"] ];
        if (dic[@"value"]) {
            [temperature setObject:@([dic[@"value"]floatValue]) forKey:@"currentValue"];
        }
        [self.temperAndHumiDic setObject:temperature forKey:@"temperature"];
        
        NSString *json = [ToolHandle toJsonString:self.temperAndHumiDic];
        NSLog(@"..................查询定温度.......................>%@",self.temperAndHumiDic);
        NSString *jsonCode = [NSString stringWithFormat:@"temperatureAndHumidityDataResponse('%@','%@')",deviceMac,json];
        [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
            
        }];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.temperAndHumiDic forKey:TemperAndHum];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
//    if (object[@"temperature"] && [object[@"temperature"] isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *temperature = object[@"temperature"];
//        NSMutableDictionary *tem = [NSMutableDictionary dictionaryWithDictionary:self.temperAndHumiDic[@"temperature"]];
//        [tem setObject:temperature[@"value"] forKey:@"currentValue"];
//        [self.temperAndHumiDic setObject:tem forKey:@"temperature"];
//        NSString *json = [ToolHandle toJsonString:self.temperAndHumiDic];
//        NSString *jsonCode = [NSString stringWithFormat:@"temperatureAndHumidityDataResponse('%@','%@')",deviceMac,json];
//        [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//            
//        }];
//    }
}


#pragma mark 插座继电器状态请求
- (void)powerSwitchStatusRequest:(NSDictionary *)object
{
    NSLog(@"powerSwitchStatusRequest..........");
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x0b;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendData:data mac:mac];;
}

#pragma mark 插座继电器控制
- (void)powerSwitchRequest:(NSDictionary *)object
{
    NSLog(@"powerSwitchRequest..........");
    BOOL state = [[object objectForKey:@"status"] boolValue];
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x01;
    int8_t mode = 0x01;
    int8_t relayswitch = (state == true)? 0x01:0x00;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:relayswitch]];
    
    [self sendData:data mac:mac];
    
    [self temperatureAndHumidityDataRequest:@{}];
}

#pragma mark 继电器控制返回
- (void)powerSwitchResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"powerSwitchResponse..........");
    if (self.deviceSwitchUpdate) {
        self.deviceSwitchUpdate([[object objectForKey:@"state"] boolValue], deviceMac);
    }
    
    NSLog(@"继电器返回%@ ---------",object);
    
    NSString *jsCode = [[NSString alloc] initWithFormat:@"powerSwitchResponse('%@',%d)",deviceMac,[[object objectForKey:@"state"] boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
//    [self temperatureAndHumidityDataRequest:@{}];
}

#pragma mark 查询定时列表数据
- (void)commonPatternListDataRequest:(NSDictionary *)object
{
    NSLog(@"commonPatternListDataRequest..........");
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x13;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:[[object objectForKey:@"mode"]intValue] == 1 ? 0x01:0x02]];
    
    [self sendData:data mac:mac];;
}

#pragma mark 定时列表数据返回
- (void)commonPatternListDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"commonPatternListDataResponse..........");
    NSData *data = [object objectForKey:@"data"];
    NSMutableData *timeData = [NSMutableData data];
    uint8_t reserve = 2;
    uint8_t timeLoc = 3+reserve+2+1;
    [timeData appendData:[data subdataWithRange:NSMakeRange(timeLoc, data.length-timeLoc-2)]];
    Byte *byte = (Byte *)[timeData bytes];
    
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *advancedArray = [NSMutableArray array];
    NSInteger model = byte[0];
    
    if (model == 1) {
        
        NSInteger length = timeData.length/6;
        
        for (NSInteger i= 0; i<length; i++) {
            NSInteger ID = byte[i*6 +1];
            BOOL swit = (BOOL)byte[i*6+2];
            NSInteger week = byte[i*6+3];
            NSInteger hour = byte[i*6+4];
            NSInteger minute = byte[i*6+5];
            BOOL state = byte[i*6+6] == 0x01?true:false;
            NSString *time = [NSString stringWithFormat:@"%ld:%ld",hour,minute];
            
            NSDictionary *dic = @{
                                  @"switch":@(swit),
                                  @"time":time,
                                  @"id":@(ID),
                                  @"state":@(state),
                                  @"week":@(week),
                                  };
            [arr addObject:dic];
        }
        
    }else if (model == 2){
        
        NSInteger length = timeData.length/11;
        
        for (NSInteger i= 0; i<length; i++) {
            NSInteger ID = byte[i*11 +1];
            NSString *time = [NSString stringWithFormat:@"%d:%d",(int)byte[i*11+2],(int)byte[i*11+3]];
            NSString *time2 = [NSString stringWithFormat:@"%d:%d",(int)byte[i*11+4],(int)byte[i*11+5]];
            BOOL firstSwitch = (BOOL)byte[i*11+6];
            NSString *onCycle = [NSString stringWithFormat:@"%d:%d",(int)byte[i*11+7],(int)byte[i*11+8]];
            NSString *offCycle = [NSString stringWithFormat:@"%d:%d",(int)byte[i*11+9],(int)byte[i*11+10]];
            BOOL state = byte[i*11+11] == 0x01?true:false;
            NSInteger week = byte[i*11+12];
            
            NSDictionary *dic = @{
                                  @"time":time,
                                  @"time2":time2,
                                  @"id":@(ID),
                                  @"state":@(state),
                                  @"firstSwitch":@(firstSwitch),
                                  @"week":@(week),
                                  @"onCycle":onCycle,
                                  @"offCycle":offCycle
                                  };
            [advancedArray addObject:dic];
        }
        
    }
    
    NSString *json = [ToolHandle toJsonString:arr];
    NSString *json1 = [ToolHandle toJsonString:advancedArray];
    NSString *jsCode = [NSString stringWithFormat:@"commonPatternListDataResponse('%@','%@','%@')",deviceMac,json,json1];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"定时" message:[NSString stringWithFormat:@"%@",data] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alertView show];
    if (json.length<10) {
        NSLog(@"\n...........time...................%ld",data.length);
    }
}

#pragma mark 普通模式新建定时
- (void)commonPatternNewTimingRequest:(NSDictionary *)object
{
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x01];
}

#pragma mark 普通模式编辑定时
- (void)commonPatternEditTimingRequest:(NSDictionary *)object
{
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x01];
    NSLog(@"commonPatternEditTimingRequest..........");
}

#pragma mark 删除定时
- (void)commonPatternDeleteTimingRequest:(NSDictionary *)object
{
    int8_t mode = [[object objectForKey:@"mode"] integerValue];
    [self timingOperation:object mode:mode confirm:0x02];
    NSLog(@"commonPatternDeleteTimingRequest..........");
}

-  (void)timingOperation:(NSDictionary *)object mode:(int8_t)mode confirm:(int8_t)confirm
{
    NSLog(@"commonPatternNewTimingRequest..........");
    
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type= 0x02;
    int8_t cmd = 0x05;
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    
    if (mode == 0x01) {
        
        NSString *time = [[object objectForKey:@"time"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *times = [time componentsSeparatedByString:@":"];
        NSInteger ids = [[object objectForKey:@"ID"] integerValue];
        
        //    int8_t mode = 0x01;//0x01普通 0x02 进阶
        int8_t ID = (int8_t)(ids==0?0xff:ids);//定时唯一标识
        //    int8_t state = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;//0x01保存 0x02删除
        int8_t switc = [[object objectForKey:@"switchtab"] boolValue] ? 0x01 : 0x00;//开启关闭
        int8_t weak= (int8_t)[[object objectForKey:@"week"] intValue];
        int8_t hour = (int8_t)[[times firstObject] intValue];
        int8_t minute = (int8_t)[[times lastObject] intValue];
        int8_t confirma  = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;
        
        [data appendData:[self getData:ID]];
        [data appendData:[self getData:confirm]];
        [data appendData:[self getData:switc]];
        [data appendData:[self getData:weak]];
        [data appendData:[self getData:hour]];
        [data appendData:[self getData:minute]];
        [data appendData:[self getData:confirma]];
        
    }
    
    if (mode == 0x02) {
        
        NSInteger ids = [[object objectForKey:@"ID"] integerValue];
        int8_t ID = (int8_t)(ids==0?0xff:ids);//定时唯一标识
        
        NSString *time = [[object objectForKey:@"time"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *timeArray = [time componentsSeparatedByString:@":"];
        
        NSString *time2 = [[object objectForKey:@"time2"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *time2Array = [time2 componentsSeparatedByString:@":"];
        
        int8_t switc = [[object objectForKey:@"switch"] boolValue] ? 0x01 : 0x00;//开启关闭
        
        NSString *onTime = [[object objectForKey:@"onTime"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *onTimeArray = [onTime componentsSeparatedByString:@":"];
        
        NSString *offTime = [[object objectForKey:@"offTime"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSArray *offTimeArray = [offTime componentsSeparatedByString:@":"];
        
        int8_t confirma  = [[object objectForKey:@"state"] boolValue] == true? 0x01:0x02;
        
        [data appendData:[self getData:ID]];
        [data appendData:[self getData:confirm]];
        [data appendData:[self getData:(int8_t)[[timeArray firstObject] integerValue]]];
        [data appendData:[self getData:(int8_t)[[timeArray lastObject] integerValue]]];
        [data appendData:[self getData:(int8_t)[[time2Array firstObject] integerValue]]];
        [data appendData:[self getData:(int8_t)[[time2Array lastObject] integerValue]]];
        [data appendData:[self getData:switc]];
        [data appendData:[self getData:(int8_t)[[onTimeArray firstObject] integerValue]]];
        [data appendData:[self getData:(int8_t)[[onTimeArray lastObject] integerValue]]];
        [data appendData:[self getData:(int8_t)[[offTimeArray firstObject] integerValue]]];
        [data appendData:[self getData:(int8_t)[[offTimeArray lastObject] integerValue]]];
        [data appendData:[self getData:confirma]];
        
    }
    
    [self sendData:data mac:mac];;
}

#pragma mark 新建/编辑/删除定时操作返回
- (void)commonPatternTimingResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"result"] boolValue];
    BOOL sWitch = [[object objectForKey:@"switch"] boolValue];
    NSInteger ID = [[object objectForKey:@"id"] integerValue];
    NSInteger model = [[object objectForKey:@"model"] integerValue];
    
    NSString *jsCode = [NSString stringWithFormat:@"commonPatternTimingResponse('%@',%d,%d,%ld,%ld)",deviceMac,state,sWitch,ID,model];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 上报定时结束
- (void)reportendoftime:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    [self powerSwitchStatusRequest:@{}];
    [self commonPatternListDataRequest:@{}];
    NSLog(@"powerSwitchResponse..........");
    NSString *jsCode = [[NSString alloc] initWithFormat:@"powerSwitchResponse('%@',%d)",deviceMac,[[object objectForKey:@"state"] boolValue]];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 倒计时页面数据
- (void)countdownDataRequest:(NSDictionary *)object
{
    NSLog(@"countdownDataRequest..........");
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x0d;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    
    [self sendData:data mac:mac];;
}

#pragma mark 倒计时页面数据返回
- (void)CountdownResult:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"countdownDataResponse..........");
    BOOL state = [object[@"state"] integerValue] == 1?true :false;
    BOOL switc = [object[@"switch"] integerValue] == 1? true :false;
    NSInteger hour = [object[@"hour"] integerValue];
    NSInteger minute = [object[@"minute"] integerValue];
    NSInteger seconds = [object[@"seconds"] integerValue];
    NSInteger realHour = [object[@"realHour"] integerValue];
    NSInteger realMinute = [object[@"realMinute"] integerValue];
    NSInteger realAllTim = realHour*60+realMinute;
    NSInteger alltime = [[NSUserDefaults standardUserDefaults] integerForKey:Countdwon];
    if (realAllTim == 0) {
        realAllTim = alltime;
        if (alltime < hour*60+minute) {
            realAllTim = hour*60+minute;
        }
    }
    if (state==false) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:Countdwon];
    }
    NSDictionary *dic = @{
                          @"hour":@(hour),
                          @"minute":@(minute),
                          @"seconds":@(seconds),
                          @"Switchgear":@(switc),//开关机
                          @"countdownSwitch":@(state),//启动结束
                          @"allTime":@(realAllTim),
                          };

    NSString *json = [ToolHandle toJsonString:dic];
    NSString *jsonCode = [NSString stringWithFormat:@"countdownDataResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {

    }];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"倒计时s返回数据" message:json delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
    
    NSMutableDictionary *muDic =[[NSMutableDictionary alloc] initWithDictionary:[self.reportDic objectForKey:deviceMac]];
    [muDic setObject:@((hour*60+minute)*60*1000) forKey:@"time"];
    [self.reportDic setValue:muDic forKey:deviceMac];
    NSString *json1 = [ToolHandle toJsonString:muDic];
    NSString *jsCode1 = [[NSString alloc] initWithFormat:@"socketStatusResponse('%@','%@')",deviceMac,json1];
    [self.web evaluateJavaScript:jsCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置电源开关倒计时
- (void)powerSwitchCountdownRequest:(NSDictionary *)object
{
    NSLog(@"powerSwitchCountdownRequest..........");
    BOOL state = [[object objectForKey:@"state"] boolValue];    //启动结束
    BOOL swit = [[object objectForKey:@"Switchgear"] boolValue]; //开机关机
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x07;
    int8_t confirm = (state == true)? 0x01:0x02;
    int8_t switchs = (swit == true)? 0x01:0x00;
    int8_t hour = (int8_t)[[object objectForKey:@"hour"] integerValue];
    int8_t minute = (int8_t)[[object objectForKey:@"minute"] integerValue];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:switchs]];
    [data appendData:[self getData:hour]];
    [data appendData:[self getData:minute]];
    
    [self sendData:data mac:mac];;
    
    if (state) {
        [[NSUserDefaults standardUserDefaults] setInteger:hour*60+minute forKey:Countdwon];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark  设置电源开关倒计时返回
- (void)powerSwitchCountdownResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"powerSwitchCountdownResponse..........");
    BOOL result = [[object objectForKey:@"result"] boolValue];
    BOOL state = [[object objectForKey:@"state"] boolValue]; //启动结束
    BOOL switc = [[object objectForKey:@"switch"] boolValue]; //开关机
    NSString *jsCode = [NSString stringWithFormat:@"powerSwitchCountdownResponse('%@',%d,%d)",deviceMac,state,result];
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
//    if (state == false) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:Countdwon];
//        NSDictionary *dic = @{
//                              @"hour":@(0),
//                              @"minute":@(0),
//                              @"Switchgear":@(switc),//开关机
//                              @"countdownSwitch":@(false),//启动结束
//                              @"allTime":@(0),
//                              };
//        NSString *json = [ToolHandle toJsonString:dic];
//        NSString *jsonCode = [NSString stringWithFormat:@"countdownDataResponse('%@','%@')",deviceMac,json];
//        [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//        }];
//    }
    
}

#pragma mark 温度传感器查询
- (void)temperatureSensorStateRequest:(NSDictionary *)object
{
    NSString *mac = [object objectForKey:@"mac"];
    int8_t type = 0x02;
    int8_t cmd = 0x39;
    int8_t mode = 0x01; //温度传感器
    
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    
    [self sendData:data mac:mac];
}

#pragma mark 温度传感器查询返回
- (void)temperatureSensorStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"status"] integerValue] == 1?true:false;
    NSString *jsonCode = [NSString stringWithFormat:@"temperatureSensorStateResponse('%@',%d)",deviceMac,state];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
//    NSString *jsonCode1 = [NSString stringWithFormat:@"temperatureSensorReportStateResponse('%@',%d)",deviceMac,state];
//    [self.web evaluateJavaScript:jsonCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//        
//    }];
//    if (!state) {
//        [self addLocalNotificationForOldVersion];
//    }
}

#pragma mark 温度传感器上报返回
- (void)temperatureSensorReportStateResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL state = [[object objectForKey:@"status"] integerValue] == 1?true:false;
    NSString *jsonCode = [NSString stringWithFormat:@"temperatureSensorReportStateResponse('%@',%d)",deviceMac,state];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
//    NSString *jsonCode1 = [NSString stringWithFormat:@"temperatureSensorStateResponse('%@',%d)",deviceMac,state];
//    [self.web evaluateJavaScript:jsonCode1 completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//
//    }];
    if (!state) {
        [self addLocalNotificationForOldVersion];
    }
}

- (void)addLocalNotificationForOldVersion {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *lan ;
    
    
    if ([defaults objectForKey:LangauageType]) {
        lan = [defaults objectForKey:LangauageType];
    }else{
        NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
        NSString * preferredLang = [allLanguages objectAtIndex:0];
        if ([preferredLang hasPrefix:@"zh"]) {
            lan = @"zh";
        }else{
            lan = @"en";
        }
    }
    
    NSString *title;
    NSString *subTitle;
    if ([lan isEqualToString:@"zh"]) {
        title = @"温度检测异常！";
        subTitle = @"请确保温度传感器已正确插入！";
    }else{
        title = @"Abnormal temperature detection";
        subTitle = @"Please make sure temperature sensor is properly plugged on";
    }

    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:subTitle arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        
        //    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alertTime repeats:NO];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"OXNotification" content:content trigger:nil];
        
        [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error) {
            NSLog(@"成功添加推送");
        }];
        
    }else{
        
        //        定义本地通知对象
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        //设置调用时间
        notification.timeZone = [NSTimeZone localTimeZone];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        notification.repeatInterval = 0;
        notification.repeatCalendar=[NSCalendar currentCalendar];
        
        //设置通知属性
        notification.alertBody = subTitle;
        notification.applicationIconBadgeNumber += 1;
        notification.alertAction = @"打开应用";
        notification.alertLaunchImage = @"Default";
        notification.soundName = UILocalNotificationDefaultSoundName;
        
        //调用通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

#pragma mark 查询定温湿度值
- (void)temperatureAndHumidityDataRequest:(NSDictionary *)object
{
    NSLog(@"temperatureAndHumidityDataRequest..........");
    
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:TemperAndHum]) {
//        NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:TemperAndHum];
//        NSString *json = [ToolHandle toJsonString:dic];
//        NSString *jsonCode = [NSString stringWithFormat:@"temperatureAndHumidityDataResponse('%@','%@')",object[@"mac"],json];
//        
//        NSLog(@"查询温度 --------- %@",json);
//        
//        [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
//            
//        }];
//    }
    
    [self queryTemperatureValueAndHumidityValue:0x01 object:object];
    [self queryTemperatureValueAndHumidityValue:0x02 object:object];
    
}

- (void)queryTemperatureValueAndHumidityValue:(int8_t)switchs object:(NSDictionary *)object
{
    NSLog(@"queryTemperatureValueAndHumidityValue..........");
    NSString *mac = [object objectForKey:@"mac"];
    
    int8_t type= 0x02;
    int8_t cmd = 0x11;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:0x01]]; //1、温度 2、湿度模式
    [data appendData:[self getData:switchs]];//1、制热 2、制冷
    
    [self sendData:data mac:mac];;
}

#pragma mark 查询定温湿度结果回调
- (void)temperatureAndHumidityDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
//    NSLog(@"temperatureAndHumidityDataResponse..........,%@",object);
    NSInteger model = [[object objectForKey:@"mode"] integerValue]; //1、温度 2、湿度模式
    NSInteger type = [[object objectForKey:@"type"] integerValue];  //1、制热 2、制冷
    if (model == 1) {
        NSMutableDictionary *temp;
        if (self.temperAndHumiDic.allKeys.count) {
            temp  = [NSMutableDictionary dictionaryWithDictionary:[self.temperAndHumiDic objectForKey:@"temperature"] ];
        }else{
            temp = [[NSMutableDictionary alloc] init];
        }
        if (type == 1) {
            [temp setObject:@([object[@"currentValue"] floatValue]) forKey:@"currentValue"];
            [temp setObject:@([object[@"alarmValue"] integerValue]) forKey:@"hotAlarmValue"];
            [temp setObject:@([object[@"state"] boolValue]) forKey:@"hotAlarmSwitch"];
        }else{
            [temp setObject:@([object[@"currentValue"] floatValue])  forKey:@"currentValue"];
            [temp setObject:@([object[@"alarmValue"] integerValue]) forKey:@"codeAlarmValue"];
            [temp setObject:@([object[@"state"] boolValue]) forKey:@"codeAlarmSwitch"];
        }
        [self.temperAndHumiDic setObject:temp forKey:@"temperature"];
        
    }else{
        [self.temperAndHumiDic setObject:@{
                                           @"currentValue":@([object[@"currentValue"] integerValue]) ,
                                           @"alarmValue":@([object[@"alarmValue"] integerValue]),
                                           @"alarmSwitch":@([object[@"state"]boolValue]),
                                           } forKey:@"humidity"];
    }
    
    NSString *json = [ToolHandle toJsonString:self.temperAndHumiDic];
    NSLog(@"..................查询定温度.......................>%@",self.temperAndHumiDic);
    NSString *jsonCode = [NSString stringWithFormat:@"temperatureAndHumidityDataResponse('%@','%@')",deviceMac,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
        
    [[NSUserDefaults standardUserDefaults] setObject:self.temperAndHumiDic forKey:TemperAndHum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark 设置告警温度值
- (void)alarmTemperatureValueRequest:(NSDictionary *)object
{
    NSLog(@"alarmTemperatureValueRequest..........");
    [self alarmHumidityAndTemperatureValueRequest:object mode:0x01];
    
}
#pragma mark 设置告警湿度值
- (void)alarmHumidityValueRequest:(NSDictionary *)object
{
    NSLog(@"alarmHumidityValueRequest..........");
    //    [self alarmHumidityAndTemperatureValueRequest:object mode:0x02];
}

- (void)alarmHumidityAndTemperatureValueRequest:(NSDictionary *)object mode:(int8_t)mode
{
    NSLog(@"alarmHumidityAndTemperatureValueRequest..........");
    NSString *mac = [object objectForKey:@"mac"];
    BOOL state = [[object objectForKey:@"state"] boolValue];
    int temp = [[object objectForKey:@"alarmValue"] floatValue]*100;
    
    int8_t type = 0x02;
    int8_t cmd = 0x09;
    int8_t confirm = (state == true)? 0x01:0x02;
    int8_t switc = (int8_t)[[object objectForKey:@"mode"] integerValue];//0x01 0x02(上下限)
    int8_t temp_int = (int8_t)(temp/100);
    int8_t temp_deci = (int8_t)((abs(temp))%100);
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:switc]];
    [data appendData:[self getData:temp_int]];
    [data appendData:[self getData:temp_deci]];
    
    [self sendData:data mac:mac];;
    
}

#pragma mark 设置告警温度值返回
#pragma mark 设置告警湿度值返回
- (void)alarmTemperatureValueResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    NSLog(@"alarmHumidityAndTemperatureValue..........");
    NSInteger type = [[object objectForKey:@"type"] integerValue];
    NSInteger mode = [[object objectForKey:@"mode"] integerValue];
    BOOL result = [[object objectForKey:@"result"] boolValue];
    BOOL state = ([[object objectForKey:@"state"] integerValue] == 1)?true:false;
    NSString *jsCode;
    if (mode == 1) {
        NSMutableDictionary *temp;
        if (self.temperAndHumiDic.allKeys.count) {
            temp  = [NSMutableDictionary dictionaryWithDictionary:[self.temperAndHumiDic objectForKey:@"temperature"] ];
        }else{
            temp = [[NSMutableDictionary alloc] init];
        }
        if (type == 1) {
            [temp setObject:@(state) forKey:@"hotAlarmSwitch"];
            
        }else{
            [temp setObject:@(state) forKey:@"codeAlarmSwitch"];
        }
        [self.temperAndHumiDic setObject:temp forKey:@"temperature"];
        
        jsCode = [NSString stringWithFormat:@"alarmTemperatureValueResponse('%@',%d,%ld,%d)",deviceMac,state,type,result];
    }else if (type == 2){
        //湿度
        jsCode = [NSString stringWithFormat:@"alarmHumidityValueResponse('%@',%d,%d)",deviceMac,state,result];
    }
    [self.web evaluateJavaScript:jsCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 定量定费查询
- (void)spendingCountdownDataRequest:(NSDictionary *)object
{
    [self spendingCountdownDataRequest:object model:0x01];
    [self spendingCountdownDataRequest:object model:0x02];
}
- (void)spendingCountdownDataRequest:(NSDictionary *)object model:(int8_t)mode
{
    
    int8_t type= 0x02;
    int8_t cmd = 0x17;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:mode]];
    
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 查询定量定费返回
- (void)spendingCountdownDataResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    Byte *byte = (Byte *)[[object objectForKey:@"data"] bytes];
    uint8_t reserve = 2;
    uint8_t resultLoc = 3+reserve+2;
    BOOL result = !byte[resultLoc];
    BOOL confirm = byte[resultLoc+1] == 0x01 ? true : false;
    NSInteger mode = (NSInteger)byte[resultLoc+2];
    NSInteger year = byte[resultLoc+3] + 2000;
    NSInteger month = byte[resultLoc+4];
    NSInteger day = byte[resultLoc+5];
    NSInteger jing = (byte[resultLoc+6]<<8)+byte[resultLoc+7];
    NSInteger use = (byte[resultLoc+8]<<8)+byte[resultLoc+9];
    NSInteger price = (byte[resultLoc+10]<<8)+byte[resultLoc+11];
    NSDictionary *dic = @{
                          @"currentValue": @(use),
                          @"alarmValue": @(jing),
                          @"alarmSwitch": @(confirm),
                          @"year": @(year),
                          @"month": @(month),
                          @"day": @(day),
                          //        @"price":@(price),
                          };
    if (mode == 1) {
        [self.powerAndCostDic setObject:dic forKey:@"power"];
    }else{
        [self.powerAndCostDic setObject:dic forKey:@"cost"];
    }
    NSString *json = [ToolHandle toJsonString:self.powerAndCostDic];
    NSString *jsonCode = [NSString stringWithFormat:@"spendingCountdownDataResponse('%@',%d,'%@')",deviceMac,result,json];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
}

#pragma mark 设置定量定费
- (void)spendingCountdownAlarmRequest:(NSDictionary *)object
{
    uint16_t alarm = [[object objectForKey:@"alarmValue"]integerValue];
    
    int8_t type= 0x02;
    int8_t cmd = 0x15;
    int8_t confirm = [[object objectForKey:@"alarmSwitch"]boolValue] == true? 0x01:0x02;
    int8_t mode = (int8_t)[[object objectForKey:@"mode"]integerValue];
    int8_t year = (int8_t)([[object objectForKey:@"year"]integerValue] - 2000);
    int8_t month = (int8_t)[[object objectForKey:@"month"]integerValue];
    int8_t day = (int8_t)[[object objectForKey:@"day"]integerValue];
    int8_t jing = (int8_t)(alarm>>8);
    int8_t jing1 = alarm;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self getData:type]];
    [data appendData:[self getData:cmd]];
    [data appendData:[self getData:confirm]];
    [data appendData:[self getData:mode]];
    [data appendData:[self getData:year]];
    [data appendData:[self getData:month]];
    [data appendData:[self getData:day]];
    [data appendData:[self getData:jing]];
    [data appendData:[self getData:jing1]];
    
    NSString *mac = [object objectForKey:@"mac"];
    [self sendData:data mac:mac];;
}

#pragma mark 查询定量定费返回
-(void)spendingCountdownAlarmResponse:(NSDictionary *)object deviceMac:(NSString *)deviceMac
{
    BOOL result = [[object objectForKey:@"result"]boolValue];
    BOOL state = [[object objectForKey:@"state"]integerValue] == 1?true:false;
    NSInteger mode = [[object objectForKey:@"mode"]integerValue];
    NSString *jsonCode = [NSString stringWithFormat:@"spendingCountdownAlarmResponse('%@',%ld,%d,%d)",deviceMac,mode,state,result];
    [self.web evaluateJavaScript:jsonCode completionHandler:^(id _Nullable web, NSError * _Nullable error) {
        
    }];
    
}

#pragma rmark 消息组包发送
- (void)sendData:(NSMutableData *)data mac:(NSString *)mac
{
    data = [ToolHandle getPacketData:data];
    [self sendDataWithMac:mac data:data];
}

- (void)registFunctionWithWeb:(WKWebView *)web
{
    self.web = web;
    __weak typeof(self) weakSelf = self;
    [self.funArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[weakSelf.web configuration].userContentController addScriptMessageHandler:self name:obj];
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([self.funDic.allKeys containsObject:message.name]) {
        SEL sel = NSSelectorFromString(self.funDic[message.name]);
        if ([self respondsToSelector:sel]) {
            [[HandlingDataModel shareInstance] regegistDelegate:self];
            [self performSelector:sel withObject:message.body];
        }
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler  API_AVAILABLE(ios(10.0)){
    
//    NSDictionary * userInfo = notification.request.content.userInfo;
//    UNNotificationRequest *request = notification.request; // 收到推送的请求
//    UNNotificationContent *content = request.content; // 收到推送的消息内容
//    NSNumber *badge = content.badge;  // 推送消息的角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;  // 推送消息的声音
//    NSString *subtitle = content.subtitle;  // 推送消息的副标题
//    NSString *title = content.title;  // 推送消息的标题
//
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        // 远程通知
    } else {
        // 判断为本地通知
        
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

@end

