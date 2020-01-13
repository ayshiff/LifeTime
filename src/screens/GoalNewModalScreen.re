open ReactNative;
open ReactMultiversal;

[@react.component]
let make = (~navigation, ~route as _) => {
  let theme = Theme.useTheme(AppSettings.useTheme());
  
  let safeAreaInsets = ReactNativeSafeAreaContext.useSafeArea();
  let scrollYAnimatedValue = React.useRef(Animated.Value.create(0.));
  <>
    <StatusBar barStyle=`lightContent />
    <Animated.ScrollView
      style=Style.(
        list([Predefined.styles##flexGrow, theme.styles##backgroundDark])
      )
      contentContainerStyle=Style.(
        viewStyle(
          // no top, handled by modal
          // ~paddingTop=safeAreaInsets##top->dp,
          ~paddingBottom=safeAreaInsets##bottom->dp,
          ~paddingLeft=safeAreaInsets##left->dp,
          ~paddingRight=safeAreaInsets##right->dp,
          (),
        )
      )
      showsHorizontalScrollIndicator=false
      showsVerticalScrollIndicator=false
      scrollEventThrottle=16
      onScroll=Animated.(
        event1(
          [|
            {
              "nativeEvent": {
                "contentOffset": {
                  y: scrollYAnimatedValue->React.Ref.current,
                },
              },
            },
          |],
          eventOptions(~useNativeDriver=true, ()),
        )
      )>
      <StickyHeader
        scrollYAnimatedValue={scrollYAnimatedValue->React.Ref.current}
        // scrollOffsetY=0.
        safeArea=false
        backgroundElement={<StickyHeaderBackground />}
        // animateBackgroundOpacity=`yes
        color={theme.colors.blue}
        color2={theme.colors.blue}
        textStyle=theme.styles##textOnBackground
        title=GoalNew.title
        left={({color, defaultStyle}) =>
          <TouchableOpacity
            onPress={_ => navigation->Navigators.RootStack.Navigation.goBack()}>
            <Text style=Style.(array([|defaultStyle, style(~color, ())|]))>
              "Cancel"->React.string
            </Text>
          </TouchableOpacity>
        }
        right={({color, defaultStyle}) =>
          <TouchableOpacity
            onPress={_ => navigation->Navigators.RootStack.Navigation.goBack()}>
            <Text style=Style.(array([|defaultStyle, style(~color, ())|]))>
              "Add"->React.string
            </Text>
          </TouchableOpacity>
        }
        // rightAlwaysVisible=true
      />
      <Spacer size=XL />
      <GoalNew />
    </Animated.ScrollView>
  </>;
};
