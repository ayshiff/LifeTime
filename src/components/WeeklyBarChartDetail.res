open ReactNative
open ReactMultiversal

@react.component
let make = (
  ~today: Js.Date.t,
  ~todayFirst,
  ~previousFirst,
  ~events,
  ~startDate,
  ~supposedEndDate,
  ~activityTitle,
  ~width,
  ~rightSpace,
) => {
  let (settings, _setSettings) = React.useContext(AppSettings.context)
  let theme = Theme.useTheme(AppSettings.useTheme())

  let endDate = supposedEndDate->Date.min(today)

  let categoryId = activityTitle->Calendars.categoryIdFromActivityTitle(settings.activities)

  <View style={
    open Style
        viewStyle(~width=(width -. rightSpace)->dp, ())
      }>
    <Spacer />
    <SpacedView vertical=None>
      <Text style={theme.styles["textLight2"]}>
        {if todayFirst == startDate {
          "Current Week's Events"
        } else if previousFirst == startDate {
          "Last Week's Events"
        } else {
          startDate->Js.Date.getDate->Js.Float.toString ++
            (" - " ++
            (endDate->Js.Date.getDate->Js.Float.toString ++
              (" " ++
              (endDate->Date.monthShortString ++ " Events"))))
        }->React.string}
      </Text>
    </SpacedView>
    <SpacedView vertical=XS>
      <WeeklyGraphDetail width events startDate supposedEndDate categoryId />
    </SpacedView>
    <Spacer size=S />
  </View>
}
