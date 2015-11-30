//
//  NotificationTests.m
//  NotificationTests
//
//  Created by Greg Thoman on 11/18/2015.
//  Copyright (c) 2015 Greg Thoman. All rights reserved.
//

// https://github.com/Specta/Specta
#import "RSNotifications.h"
//OCMock
@interface RSNotifications (Test)

@property NSUserDefaults *mockUserDefaults;

- (void)storeNever;
- (BOOL)retrieveNever;
- (void)storeAsked;
- (BOOL)retrieveAsked;
- (void)clearLaterDate;
- (NSDate *)timeIntervalFromNow;
- (NSDate *)retrieveLaterDate;
- (BOOL)afterLaterDate;
- (BOOL)primaryDialogConditionsMet;
- (void)resetAllSettings;

@end

SpecBegin(InitialSpecs)

describe(@"Notification messages and labels", ^{
    it(@"properties should be over-writeable", ^{
        RSNotifications *notifications = [[RSNotifications alloc] init];
        notifications.messageTitle = @"TITLE";
        notifications.messageBody = @"BODY";
        
        expect(notifications.messageTitle).to.equal(@"TITLE");
        expect(notifications.messageBody).to.equal(@"BODY");
    });
});

describe(@"userDefaults", ^{
    it(@"are working", ^{
        RSNotifications *notifications = [[RSNotifications alloc] init];

        [notifications storeNever];
        [notifications storeAsked];
        
        expect([notifications retrieveNever]).to.equal(true);
        expect([notifications retrieveAsked]).to.equal(true);
    });
});

describe(@"time stuff", ^{
    it(@"timeIntervalFromNow", ^{
        
        RSNotifications *notifications = [[RSNotifications alloc] init];
        notifications.delaySeconds = 86400;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"dd"];
        
        int dayInTheFuture = [[df stringFromDate:[NSDate date]] integerValue] + 1;
        
        NSDate *dateFromNow = [notifications timeIntervalFromNow];
        
        expect([[df stringFromDate:dateFromNow] integerValue]).to.equal(dayInTheFuture);
    });
    
    describe(@"retrieveLaterDate",^{
        it(@"should return a date", ^{
            RSNotifications *notifications = [[RSNotifications alloc] init];
            [notifications.userDefaults setObject:[notifications timeIntervalFromNow] forKey: RS_NOTIFICATION_DATE];
            
            NSDate *date = [notifications retrieveLaterDate];
            
            expect(date).to.beKindOf([NSDate class]);
            
        });
        
        it(@"should be falsey if no laterDate", ^{
            RSNotifications *notifications = [[RSNotifications alloc] init];
            
            [notifications clearLaterDate];
            NSDate *date = [notifications retrieveLaterDate];
            
            expect(date).to.beFalsy();
        });
    });
    
    describe(@"afterLaterDate", ^{
        it(@"should be false when date is in the future", ^{
            RSNotifications *notifications = [[RSNotifications alloc] init];
            
            [notifications.userDefaults setObject:[notifications timeIntervalFromNow] forKey: RS_NOTIFICATION_DATE];
            
            BOOL isAfterLaterDate = [notifications afterLaterDate];
            
            expect(isAfterLaterDate).to.beFalsy();
        });
        
        it(@"should be true when date is in the past", ^{
            RSNotifications *notifications = [[RSNotifications alloc] init];

            NSTimeInterval time = 60*60*24*(-7);
            NSDate *earlierDate = [[NSDate date] dateByAddingTimeInterval: time];
            
            [notifications.userDefaults setObject:earlierDate forKey: RS_NOTIFICATION_DATE];
            
            BOOL isAfterLaterDate = [notifications afterLaterDate];
            
            expect(isAfterLaterDate).to.beTruthy();
        });
    });

});

describe(@"- (BOOL)primaryDialogConditionsMet)", ^{
    it(@"should not show when NEVER is set ", ^{
        RSNotifications *notifications = [[RSNotifications alloc] init];
        [notifications.userDefaults setBool:true forKey:RS_NOTIFICATION_NEVER];
        
        expect([notifications primaryDialogConditionsMet]).to.beFalsy();
    });

    it(@"should not show when laterDate is after now", ^{
        RSNotifications *notifications = [[RSNotifications alloc] init];
        
        [notifications.userDefaults setObject:[notifications timeIntervalFromNow] forKey:RS_NOTIFICATION_DATE];
        [notifications.userDefaults setBool:false forKey:RS_NOTIFICATION_NEVER];
        
        expect([notifications primaryDialogConditionsMet]).to.beFalsy();
    });
    
    it(@"should show when no CustomPermission has yet been given (and there is no later date)", ^{
        RSNotifications *notifications = [[RSNotifications alloc] init];
        
        notifications.customValidation = ^BOOL{
            return true;
        };
        
        [notifications resetAllSettings];
        
        expect([notifications primaryDialogConditionsMet]).to.beTruthy();
    });
    
    it(@"should show when later date is before now", ^{
        RSNotifications *notifications = [[RSNotifications alloc] init];

        NSDate *earlierDate = [[NSDate date] dateByAddingTimeInterval:60*60*24*(-7)];
        
        [notifications.userDefaults setObject:earlierDate forKey:RS_NOTIFICATION_DATE];
        
        expect([notifications primaryDialogConditionsMet]).to.beTruthy();
    });
});

SpecEnd

