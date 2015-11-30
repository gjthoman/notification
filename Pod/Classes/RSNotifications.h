#import <foundation/Foundation.h>

#define RS_NOTIFICATION_DATE @"RS_NOTIFICATION_DATE"
#define RS_NOTIFICATION_ASKED @"RS_NOTIFICATION_ASKED"
#define RS_NOTIFICATION_NEVER @"RS_NOTIFICATION_NEVER"

#define RS_MESSAGE_TITLE @"App Notifications"
#define RS_MESSAGE_BODY @"Would you like to recieve notifications from this app?"
#define RS_MESSAGE_LABEL_YES @"Yes"
#define RS_MESSAGE_LABEL_LATER @"Later"
#define RS_MESSAGE_LABEL_NEVER @"Never"

#define RS_SETTINGS_ALERT_TITLE @"App Notifications"
#define RS_SETTINGS_ALERT_BODY @"Enable or disable notifications in the Settings Application."
#define RS_SETTINGS_ALERT_CONFIRM @"OK"

#define RS_DELAY_SECONDS 604800
#define RS_ENABLED true

#define RS_LOGGING false

@interface RSNotifications : NSObject {
    NSString *messageTitle;
    NSString *messageBody;
    NSString *messageLabelYes;
    NSString *messageLabelLater;
    NSString *messageLabelNever;
    
    NSString *settingsAlertTitle;
    NSString *settingsAlertBody;
    NSString *settingsAlertConfirm;
    
    BOOL enabled;
    BOOL logging;
    NSInteger delaySeconds;

    UIViewController *vc;
    BOOL (^customValidation)(void);
    void (^primaryCallback)(void);
    void (^onVerificationComplete)(void);
    void (^onYes)(void);
    void (^onLater)(void);
    void (^onNever)(void);
}

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@property (nonatomic, retain) NSString *messageTitle;
@property (nonatomic, retain) NSString *messageBody;
@property (nonatomic, retain) NSString *messageLabelYes;
@property (nonatomic, retain) NSString *messageLabelLater;
@property (nonatomic, retain) NSString *messageLabelNever;

@property (nonatomic, retain) NSString *settingsAlertTitle;
@property (nonatomic, retain) NSString *settingsAlertBody;
@property (nonatomic, retain) NSString *settingsAlertConfirm;

@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL logging;
@property (nonatomic) NSInteger delaySeconds;

@property (nonatomic, retain) UIViewController *vc;

@property (nonatomic, copy) BOOL (^customValidation)(void);
@property (nonatomic, copy) void (^primaryCallback)(void);
@property (nonatomic, copy) void (^onVerificationComplete)(void);
@property (nonatomic, copy) void (^onYes)(void);
@property (nonatomic, copy) void (^onLater)(void);
@property (nonatomic, copy) void (^onNever)(void);

+ (id)notificationManager;

- (void)run;

- (void)resetAllSettings;

- (void)showSettingsMessage;
- (void)storeLaterDate: (NSDate *) date;

- (BOOL)isLessThanOS8;

@end