open Belt
open ReactNative
open ReactMultiversal
open ReactNavigation

open Navigators

module StatsStackScreen = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let theme = Theme.useTheme(AppSettings.useTheme())
    <StatsStack.Navigator screenOptions={_ => Stack.TransitionPresets.slideFromRightIOS}>
      <StatsStack.Screen
        name="HomeScreen"
        component=HomeScreen.make
        options={_ => StatsStack.options(~headerShown=false, ())}
      />
      <StatsStack.Screen
        name="ActivityOptionsScreen"
        component=ActivityOptionsScreen.make
        options={screenOptions =>
          StatsStack.options(
            ~title=screenOptions.route.params
            ->Option.flatMap(params => params.currentActivityTitle)
            ->Option.getWithDefault("Activity"),
            ~headerBackTitle="Back",
            ~headerTitleContainerStyle={
              open Style
              viewStyle(~paddingHorizontal=(Spacer.space *. 3.)->dp, ())
            },
            ~headerTintColor=theme.colors.blue,
            ~headerTitleStyle=theme.styles["text"],
            ~headerStyle=theme.styles["stackHeader"],
            (),
          )}
      />
    </StatsStack.Navigator>
  }
}

module GoalsStackScreen = {
  @react.component
  let make = (~navigation as _, ~route as _) =>
    <GoalsStack.Navigator screenOptions={_ => Stack.TransitionPresets.slideFromRightIOS}>
      <GoalsStack.Screen
        name="GoalsScreen"
        component=GoalsScreen.make
        options={_ => GoalsStack.options(~headerShown=false, ())}
      />
    </GoalsStack.Navigator>
}

module SettingsStackScreen = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let theme = Theme.useTheme(AppSettings.useTheme())
    <SettingsStack.Navigator screenOptions={_ => Stack.TransitionPresets.slideFromRightIOS}>
      <SettingsStack.Screen
        name="SettingsScreen"
        component=SettingsScreen.make
        options={_ => StatsStack.options(~headerShown=false, ~title=SettingsScreen.title, ())}
      />
      <SettingsStack.Screen
        name="SettingsDangerZoneScreen"
        component=SettingsDangerZoneScreen.make
        options={_ =>
          StatsStack.options(
            ~title=SettingsDangerZoneScreen.title,
            ~headerTintColor=theme.colors.blue,
            ~headerTitleStyle=theme.styles["text"],
            ~headerStyle=theme.styles["stackHeader"],
            (),
          )}
      />
      <SettingsStack.Screen
        name="SettingsNotificationsScreen"
        component=SettingsNotificationsScreen.make
        options={_ => {
          open StatsStack
          options(
            ~title=SettingsNotificationsScreen.title,
            ~headerTintColor=theme.colors.blue,
            ~headerTitleStyle=theme.styles["text"],
            ~headerStyle=theme.styles["stackHeader"],
            (),
          )
        }}
      />
    </SettingsStack.Navigator>
  }
}

module TabsScreen = {
  @react.component
  let make = (~navigation as _, ~route as _) => {
    let theme = Theme.useTheme(AppSettings.useTheme())
    <>
      <NavigationBar backgroundColor=theme.namedColors.background />
      <Tabs.Navigator
        initialRouteName="StatsStack"
        tabBarOptions={Tabs.bottomTabBarOptions(
          ~activeTintColor=theme.colors.blue,
          ~inactiveTintColor=theme.colors.gray,
          ~style={
            open Style
            array([theme.styles["background"], viewStyle(~borderTopColor=theme.colors.gray4, ())])
          },
          (),
        )}>
        <Tabs.Screen
          name="StatsStack"
          component=StatsStackScreen.make
          options={_props =>
            Tabs.options(
              ~title="Summary",
              ~tabBarIcon=tabBarIconProps =>
                <SVGTimeline
                  width={tabBarIconProps.size->Style.dp}
                  height={tabBarIconProps.size->Style.dp}
                  fill=tabBarIconProps.color
                />,
              (),
            )}
        />
        <Tabs.Screen
          name="GoalsStack"
          component=GoalsStackScreen.make
          options={_props =>
            Tabs.options(
              ~title="Goals",
              ~tabBarIcon=tabBarIconProps =>
                <SVGPennant
                  width={tabBarIconProps.size->Style.dp}
                  height={tabBarIconProps.size->Style.dp}
                  fill=tabBarIconProps.color
                />,
              (),
            )}
        />
        <Tabs.Screen
          name="SettingsStack"
          component=SettingsStackScreen.make
          options={_props =>
            Tabs.options(
              ~title=SettingsScreen.title,
              ~tabBarIcon=tabBarIconProps =>
                <SVGSettings
                  width={tabBarIconProps.size->Style.dp}
                  height={tabBarIconProps.size->Style.dp}
                  fill=tabBarIconProps.color
                />,
              (),
            )}
        />
      </Tabs.Navigator>
    </>
  }
}

module RootNavigator = {
  @react.component
  let make = () =>
    <RootStack.Navigator
      initialRouteName="Tabs"
      mode=#modal
      headerMode=#none
      screenOptions={_ =>
        RootStack.options(~gestureEnabled=true, ~cardOverlayEnabled=true, ())->Stack.mergeOptions(
          Stack.TransitionPresets.modalPresentationIOS,
        )}>
      <RootStack.Screen name="Tabs" component=TabsScreen.make />
      <RootStack.Screen
        name="WelcomeModalScreen"
        component=WelcomeScreen.make
        options={_ => RootStack.options(~gestureEnabled=false, ())}
      />
      <RootStack.Screen name="PrivacyModalScreen" component=PrivacyModalScreen.make />
      <RootStack.Screen name="FiltersModalScreen" component=FiltersModalScreen.make />
      <RootStack.Screen name="GoalNewModalScreen" component=GoalNewModalScreen.make />
      <RootStack.Screen name="GoalEditModalScreen" component=GoalEditModalScreen.make />
      <RootStack.Screen name="HelpModalScreen" component=HelpModalScreen.make />
    </RootStack.Navigator>
}
