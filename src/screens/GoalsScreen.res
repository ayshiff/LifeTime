open ReactNative
open ReactMultiversal

@react.component
let make = (~navigation, ~route as _) => {
  let (settings, _setSettings) = React.useContext(AppSettings.context)
  let theme = Theme.useTheme(AppSettings.useTheme())
  let safeAreaInsets = ReactNativeSafeAreaContext.useSafeAreaInsets()
  let scrollYAnimatedValue = React.useRef(Animated.Value.create(0.))
  <>
    <StatusBar
      barStyle={Theme.statusBarStyle(theme.mode, #darkContent)}
      backgroundColor={Theme.statusBarColor(theme.mode, #darkContent)}
    />
    <View
      style={
        open Style
        array([Predefined.styles["flexGrow"], theme.styles["backgroundDark"]])
      }>
      <StickyHeader
        scrollYAnimatedValue=scrollYAnimatedValue.current
        scrollOffsetY=80.
        safeArea=true
        animateTranslateY=false
        backgroundElement={<StickyHeaderBackground />}
        textStyle={theme.styles["text"]}
        title=Goals.title
      />
      <Animated.ScrollView
        style={
          open Style
          array([
            Predefined.styles["flexGrow"],
            viewStyle(
              ~marginTop=safeAreaInsets.top->dp,
              // no bottom, handled by bottom tabs
              // ~marginBottom=safeAreaInsets.bottom->dp,
              ~paddingLeft=safeAreaInsets.left->dp,
              ~paddingRight=safeAreaInsets.right->dp,
              (),
            ),
          ])
        }
        showsHorizontalScrollIndicator=false
        showsVerticalScrollIndicator=false
        scrollEventThrottle=16
        onScroll={
          open Animated
          event1(
            [
              {
                "nativeEvent": {
                  "contentOffset": {
                    y: scrollYAnimatedValue.current,
                  },
                },
              },
            ],
            eventOptions(~useNativeDriver=true, ()),
          )
        }>
        <Goals
          onNewGoalPress={goalType =>
            navigation->Navigators.RootStack.Navigation.navigateWithParams(
              "GoalNewModalScreen",
              Navigators.RootStack.M.params(~newGoalType=goalType, ()),
            )}
          onEditGoalPress={goalId =>
            navigation->Navigators.RootStack.Navigation.navigateWithParams(
              "GoalEditModalScreen",
              Navigators.RootStack.M.params(~goalId, ()),
            )}
        />
      </Animated.ScrollView>
      {settings.notificationsPermissionsDismissed === 0. && settings.goals->Array.length > 0
        ? <NotificationsPermissionsPopin />
        : React.null}
    </View>
  </>
}
