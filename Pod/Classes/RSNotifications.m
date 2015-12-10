#import "RSNotifications.h"

@implementation RSNotifications

@synthesize userDefaults;

@synthesize messageTitle;
@synthesize messageBody;
@synthesize messageLabelYes;
@synthesize messageLabelLater;
@synthesize messageLabelNever;

@synthesize settingsAlertTitle;
@synthesize settingsAlertBody;
@synthesize settingsAlertConfirm;

@synthesize logging;
@synthesize delaySeconds;

@synthesize vc;

@synthesize customValidation;
@synthesize primaryCallback;
@synthesize onVerificationComplete;

@synthesize onYes, onLater, onNever;
static RSNotifications *notificationLogic = nil;
#pragma mark Singleton Methods

+ (RSNotifications *)notificationManager {
    if(notificationLogic == nil){
        notificationLogic = [[super allocWithZone:NULL] init];
        
        notificationLogic.messageTitle = RS_MESSAGE_TITLE;
        notificationLogic.messageBody = RS_MESSAGE_BODY;
        notificationLogic.messageLabelYes = RS_MESSAGE_LABEL_YES;
        notificationLogic.messageLabelLater = RS_MESSAGE_LABEL_LATER;
        notificationLogic.messageLabelNever = RS_MESSAGE_LABEL_NEVER;
        
        notificationLogic.settingsAlertTitle = RS_SETTINGS_ALERT_TITLE;
        notificationLogic.settingsAlertBody = RS_SETTINGS_ALERT_BODY;
        notificationLogic.settingsAlertConfirm = RS_SETTINGS_ALERT_CONFIRM;
        
        notificationLogic.logging = RS_LOGGING;
        notificationLogic.delaySeconds = RS_DELAY_SECONDS;
        
        notificationLogic.vc = nil;
        
        notificationLogic.customValidation = ^BOOL{
            return true;
        };
        
        notificationLogic.primaryCallback = ^{
            [[RSNotifications notificationManager]RSLog:@"primaryCallback not specified"];
        };
        
        notificationLogic.onVerificationComplete = ^{
            [[RSNotifications notificationManager]RSLog:@"onVerificationComplete not specified"];
        };
        
        notificationLogic.onYes = notificationLogic.onLater = notificationLogic.onNever = ^{return;};
    }
    
    return notificationLogic;
}

- (id)init {
    if (self = [super init]) {
        
    }
    
    return self;
}

- (NSUserDefaults *)userDefaults
{
    if (!userDefaults) {
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return userDefaults;
}

- (void)RSLog: (NSString *)message {
    if (logging) {
        NSLog(@"RSNotifications: %@", message);
    }
}

- (void)run {
    if (!self.customValidation()) {
        [self RSLog:@"customValidation has failed"];
        onVerificationComplete();
    }
    
    if ([self retrieveAsked]) {
        [self RSLog:@"Already Asked"];
        return;
    } else {
        if ([self primaryDialogConditionsMet]) [self showAlertToUser];
    }
}

- (void)showSettingsMessage
{
    if ([self retrieveAsked] || !self.customValidation()) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: settingsAlertTitle
                                                                                 message: settingsAlertBody
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle: settingsAlertConfirm
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
        [alertController addAction:ok];
        
        [self.vc presentViewController:alertController animated:YES completion:nil];
    }
    
    [self clearLaterDate];
    [self clearNever];
    [self run];
    
    return;
}

- (void)resetAllSettings
{
    [self clearAsked];
    [self clearLaterDate];
    [self clearNever];
}
/* example customValidation
- (BOOL)hasNotificationPermissions
{
    if ( ![self isLessThanOS8] ){
        UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (grantedSettings.types == UIUserNotificationTypeNone) {
            return false;
        } else {
            return true;
        }
    } else {
        return false;
    }
}
*/
- (BOOL)primaryDialogConditionsMet
{
    if ([self isLessThanOS8] || [self retrieveNever] || [self retrieveAsked]) {
        [self RSLog:@"Do not show notification dialog"];
        return false;
    }
    
    if (!self.customValidation()){
        [self RSLog:@"Failed customValidation"];
        return false;
    }
    
    if ([self retrieveLaterDate] == nil) {
        [self RSLog:@"Show notification dialog"];
        return true;
    }
    
    if (![self afterLaterDate]) [self RSLog:@"Not After Stored Later Date"];
    
    return [self afterLaterDate];
}

- (void)showAlertToUser
{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: messageTitle
                                                                   message: messageBody
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle: messageLabelYes
                                                        style: UIAlertActionStyleDefault
                                                      handler: ^(UIAlertAction * action) {
                                                          [self handleYesAction];
                                                      }];
    
    UIAlertAction* laterAction = [UIAlertAction actionWithTitle: messageLabelLater
                                                          style: UIAlertActionStyleDefault
                                                        handler: ^(UIAlertAction * action) {
                                                            [self handleLaterAction];
                                                        }];
    
    UIAlertAction* neverAction = [UIAlertAction actionWithTitle: messageLabelNever
                                                          style: UIAlertActionStyleDefault
                                                        handler: ^(UIAlertAction * action) {
                                                            [self handleNeverAction];
                                                        }];
    [alert addAction:yesAction];
    [alert addAction:laterAction];
    [alert addAction:neverAction];
    
    [self.vc presentViewController:alert animated:YES completion:nil];
}

- (void)handleYesAction
{
    [self storeAsked];
    primaryCallback();
    onYes();
}

- (void)handleLaterAction
{
    [self storeLaterDate];
    [self clearNever];
    onLater();
}

- (void)handleNeverAction
{
    [self storeNever];
    [self clearLaterDate];
    onNever();
}

/* Example primaryCallback
- (void)setNotificationSettings
{
    [self RSLog:@"SHOWING APPLE NOTIFICATION"];
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
}
*/

- (void)storeLaterDate {
    [self storeLaterDate: [self timeIntervalFromNow]];
}

- (void)storeLaterDate: (NSDate *) date
{
    [[self userDefaults] setObject:[self timeIntervalFromNow] forKey: RS_NOTIFICATION_DATE];
}

- (void)clearLaterDate {
    [[self userDefaults] removeObjectForKey: RS_NOTIFICATION_DATE];
}

- (NSDate *)retrieveLaterDate {
    return [[self userDefaults] objectForKey: RS_NOTIFICATION_DATE];
}

- (BOOL)afterLaterDate
{
    NSDate *storedDate = [[self userDefaults] objectForKey: RS_NOTIFICATION_DATE];
    
    if (storedDate == nil) return false;
    
    NSComparisonResult result = [[NSDate date] compare: storedDate];
    
    return result == NSOrderedDescending;
}

//STATUS ASKED

- (void)storeAsked {
    [[self userDefaults] setBool:true forKey: RS_NOTIFICATION_ASKED];
}

- (void)clearAsked {
    [[self userDefaults] removeObjectForKey: RS_NOTIFICATION_ASKED];
}

- (BOOL)retrieveAsked {
    return [[self userDefaults] boolForKey: RS_NOTIFICATION_ASKED];
}

//STATUS NEVER

- (void)storeNever {
    [[self userDefaults] setBool:true forKey: RS_NOTIFICATION_NEVER];
}

- (void)clearNever {
    [[self userDefaults] removeObjectForKey: RS_NOTIFICATION_NEVER];
}

- (BOOL)retrieveNever {
    return [[self userDefaults] boolForKey: RS_NOTIFICATION_NEVER];
}

- (NSDate *)timeIntervalFromNow
{
    return [[NSDate date] dateByAddingTimeInterval: delaySeconds];
}

- (BOOL)isLessThanOS8
{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) return false;
    
    return true;
}

@end