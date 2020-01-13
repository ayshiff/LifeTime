open ReactNative;
open ReactMultiversal;

let styles =
  Style.{
    "text": textStyle(~fontSize=16., ~lineHeight=16. *. 1.4, ()),
    "mediumText": textStyle(~fontSize=14., ~lineHeight=14. *. 1.4, ()),
    "smallText": textStyle(~fontSize=12., ~lineHeight=16. *. 1.4, ()),
  }
  ->StyleSheet.create;

let title = "Goals";

[@react.component]
let make = (~onNewGoalPress) => {
  // let (settings, setSettings) = React.useContext(AppSettings.context);
  let theme = Theme.useTheme(AppSettings.useTheme());
  
  // let windowDimensions = Dimensions.useWindowDimensions();
  // let styleWidth = Style.(style(~width=windowDimensions##width->dp, ()));

  <>
    <SpacedView>
      <TitlePre> " "->React.string </TitlePre>
      <Title style=theme.styles##textOnBackground> title->React.string </Title>
    </SpacedView>
    <SpacedView vertical=None horizontal=S>
      <Text
        style=Style.(
          list([styles##mediumText, theme.styles##textLightOnBackgroundDark])
        )>
        {j|LifeTime lets you visualize the time you spend on everything. This allows you to take more informed decisions about how to use your precious time.|j}
        ->React.string
      </Text>
      <Spacer size=XS />
      <Text
        style=Style.(
          list([styles##mediumText, theme.styles##textLightOnBackgroundDark])
        )>
        {j|You can help yourself by adding goals & limits you would like to respect. LifeTime will try to remind you when you successfully achieve your goals & respect your limits and can help your to improve your self-discipline if needed.|j}
        ->React.string
      </Text>
    </SpacedView>
    <Spacer size=M />
    <Spacer size=S />
    <View style=Predefined.styles##rowSpaceBetween>
      <Row>
        <Spacer size=XS />
        <BlockHeading text="Minimum to achieve" />
      </Row>
      <Row> <Spacer size=XS /> </Row>
    </View>
    <Separator style=theme.styles##separatorOnBackground />
    <View style=theme.styles##background>
      <TouchableOpacity onPress={_ => onNewGoalPress()}>
        <View style=Predefined.styles##rowCenter>
          <Spacer size=S />
          <SpacedView vertical=XS horizontal=None>
            <NamedIcon name=`scope fill={theme.colors.green} />
          </SpacedView>
          <Spacer size=XS />
          <View style=Predefined.styles##flexGrow>
            <Text
              style=Style.(
                list([styles##text, theme.styles##textOnBackground])
              )>
              "Add a goal"->React.string
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    </View>
    <Separator style=theme.styles##separatorOnBackground />
    <Spacer />
    <View style=Predefined.styles##rowSpaceBetween>
      <Row>
        <Spacer size=XS />
        <BlockHeading text="Maximum to respect" />
      </Row>
      <Row> <Spacer size=XS /> </Row>
    </View>
    <Separator style=theme.styles##separatorOnBackground />
    <View style=theme.styles##background>
      <TouchableOpacity onPress={_ => onNewGoalPress()}>
        <View style=Predefined.styles##rowCenter>
          <Spacer size=S />
          <SpacedView vertical=XS horizontal=None>
            <NamedIcon name=`hourglass fill={theme.colors.orange} />
          </SpacedView>
          <Spacer size=XS />
          <View style=Predefined.styles##flexGrow>
            <Text
              style=Style.(
                list([styles##text, theme.styles##textOnBackground])
              )>
              "Add a limit"->React.string
            </Text>
          </View>
        </View>
      </TouchableOpacity>
    </View>
    <Separator style=theme.styles##separatorOnBackground />
  </>;
};
