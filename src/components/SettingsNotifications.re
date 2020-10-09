open ReactNative;
open ReactMultiversal;

let title = "Settings";

[@react.component]
let make = () => {
  let (settings, setSettings) = React.useContext(AppSettings.context);
  let theme = Theme.useTheme(AppSettings.useTheme());

  let (notificationStatus, requestNotificationPermission) =
    Notifications.useNotificationStatus();
  let notificationsGranted =
    notificationStatus === Some(ReactNativePermissions.granted);

  <>
    <Spacer size=L />
    <Separator style=theme.styles##separatorOnBackground />
    <View style=theme.styles##background>
      <View style=Predefined.styles##rowCenter>
        <Spacer size=S />
        <View style=Predefined.styles##flex>
          <SpacedView vertical=XS horizontal=None>
            <View style=Predefined.styles##row>
              <View
                style=Style.(
                  array([|
                    Predefined.styles##flex,
                    Predefined.styles##justifyCenter,
                  |])
                )>
                <Text
                  style={Style.array([|
                    Theme.text##body,
                    theme.styles##textOnBackground,
                  |])}>
                  "Allow Notifications"->React.string
                </Text>
              </View>
              <Switch
                value=notificationsGranted
                onValueChange={value =>
                  if (value) {
                    requestNotificationPermission();
                  } else {
                    ReactNativePermissions.openSettings()->ignore;
                  }
                }
              />
              <Spacer size=S />
            </View>
          </SpacedView>
        </View>
      </View>
    </View>
    <Separator style=theme.styles##separatorOnBackground />
    <Spacer size=L />
    <Separator style=theme.styles##separatorOnBackground />
    <View style=theme.styles##background>
      <View style=Predefined.styles##rowCenter>
        <Spacer size=S />
        <View style=Predefined.styles##flex>
          <SpacedView vertical=XS horizontal=None>
            <View style=Predefined.styles##row>
              <View
                style=Style.(
                  array([|
                    Predefined.styles##flex,
                    Predefined.styles##justifyCenter,
                  |])
                )>
                <Text
                  style={Style.array([|
                    Theme.text##body,
                    theme.styles##textOnBackground,
                  |])}>
                  "Daily Reminders"->React.string
                </Text>
              </View>
              <Switch
                disabled={!notificationsGranted}
                value={settings.notificationsDailyRemindersState}
                onValueChange={notificationsDailyRemindersState => {
                  setSettings(settings =>
                    {...settings, notificationsDailyRemindersState}
                  );
                  if (!notificationsDailyRemindersState) {
                    ReactNativePushNotification.cancelLocalNotifications({
                      "id": Notifications.Ids.reminderDailyCheck,
                    });
                  };
                }}
              />
              <Spacer size=S />
            </View>
          </SpacedView>
        </View>
      </View>
    </View>
    <Separator style=theme.styles##separatorOnBackground />
    <Spacer />
  </>;
};
