#import <foundation/Foundation.h>

#define RS_PRESCREENER_LATER_DATE @"RS_PRESCREENER_LATER_DATE"
#define RS_PRESCREENER_ASKED @"RS_PRESCREENER_ASKED"
#define RS_PRESCREENER_NEVER @"RS_PRESCREENER_NEVER"

#define RS_MESSAGE_TITLE @"App Notifications"
#define RS_MESSAGE_BODY @"Would you like to recieve notifications from this app?"
#define RS_MESSAGE_LABEL_YES @"Yes"
#define RS_MESSAGE_LABEL_LATER @"Later"
#define RS_MESSAGE_LABEL_NEVER @"Never"

#define RS_SETTINGS_ALERT_TITLE @"Notifications"
#define RS_SETTINGS_ALERT_BODY @"Enable or disable notifications in the Settings Application."
#define RS_SETTINGS_ALERT_CONFIRM @"Confirm"

#define RS_DELAY_SECONDS 604800

#define RS_LOGGING false

@interface RSPrescreener : NSObject {
    //prescreen some arbitrary apple dialog with arbitrary message based on arbitrary logic.
    NSString *messageTitle;
    NSString *messageBody;
    NSString *messageLabelYes;
    NSString *messageLabelLater;
    NSString *messageLabelNever;
    
    NSString *settingsAlertTitle;
    NSString *settingsAlertBody;
    NSString *settingsAlertConfirm;
    
    BOOL logging;
    NSInteger laterDateDelaySeconds;//laterDateDelaySeconds

    UIViewController *vc;
    BOOL (^customValidation)(void);//shouldPrescreen
    void (^yes)(void);//yes
    void (^later)(void);//later
    void (^never)(void);//never
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

@property (nonatomic) BOOL logging;
@property (nonatomic) NSInteger laterDateDelaySeconds;

@property (nonatomic, retain) UIViewController *vc;

@property (nonatomic, copy) BOOL (^customValidation)(void);
@property (nonatomic, copy) void (^yes)(void);
@property (nonatomic, copy) void (^later)(void);
@property (nonatomic, copy) void (^never)(void);

+ (RSPrescreener *)manager;

- (void)run;//prescreen with vc
- (void)runWithVC: (UIViewController *) localVC;

- (void)resetAllSettings;
- (void)clearNever;
- (void)clearLaterDate;

- (void)showSettingsMessage;
- (void)storeLaterDate: (NSDate *) date;

- (BOOL)retrieveAsked;
- (void)RSLog: (NSString *)message;

- (BOOL)isLessThanOS8;

@end