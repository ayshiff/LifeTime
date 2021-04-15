open Belt
open ReactNative
open ReactMultiversal

let rightSpace = 40.

@react.component
let make = (
  ~activityTitle,
  ~refreshing,
  ~onRefreshDone,
  ~onSkipActivity,
  ~currentWeek: (string, string),
) => {
  let (settings, setSettings) = React.useContext(AppSettings.context)
  let (getEvents, fetchEvents, _updatedAt, requestUpdate) = React.useContext(Calendars.context)

  let windowDimensions = Dimensions.useWindowDimensions()

  let appStateUpdateIsActive = ReactNativeHooks.useAppStateUpdateIsActive()
  React.useEffect2(() => {
    if appStateUpdateIsActive {
      requestUpdate()
    }
    None
  }, (appStateUpdateIsActive, requestUpdate))

  let (today, todayUpdate) = Date.Hooks.useToday()

  React.useEffect4(() => {
    if refreshing {
      Log.info("ActivityOption: refreshing...")
      todayUpdate()
      requestUpdate()
      onRefreshDone()
    }
    None
  }, (refreshing, todayUpdate, requestUpdate, onRefreshDone))

  let todayDates = Date.Hooks.useWeekDates(today)

  let last5Weeks = React.useMemo1(
    () =>
      Array.range(0, 5)
      ->Array.map(currentWeekReverseIndex =>
        Date.weekDates(today->DateFns.addDays((-currentWeekReverseIndex * 7)->Js.Int.toFloat))
      )
      ->Array.reverse,
    [today],
  )

  let (currentDates, currentDates_set) = React.useState(() =>
    last5Weeks[last5Weeks->Array.length - 1]->Option.getWithDefault(todayDates)
  )
  let (startDate, supposedEndDate) = currentDates
  let endDate = supposedEndDate->Date.min(today)

  let fetchedEvents = getEvents(startDate, endDate)
  React.useEffect4(() => {
    switch fetchedEvents {
    | NotAsked => fetchEvents(startDate, endDate)
    | _ => ()
    }
    None
  }, (fetchEvents, fetchedEvents, startDate, endDate))
  let events = switch fetchedEvents {
  | Done(events) => Some(events)
  | _ => None
  }

  let scrollViewRef = React.useRef(Js.Nullable.null)
  let scrollViewWidth = windowDimensions.width

  let onMomentumScrollEnd = React.useCallback5((event: Event.scrollEvent) => {
    let x = event.nativeEvent.contentOffset.x
    let index = (x /. scrollViewWidth)->Js.Math.unsafe_round
    let dates = last5Weeks[index]->Option.getWithDefault(todayDates)
    if dates !== currentDates {
      currentDates_set(_ => dates)
    }
  }, (currentDates_set, currentDates, todayDates, scrollViewWidth, last5Weeks))

  let filteredEvents =
    events
    ->Option.map(event =>
      event->Calendars.filterEventsByTitle(activityTitle)->Calendars.sortEventsByDecreasingStartDate
    )
    ->Option.getWithDefault([])

  let todayDates = Date.weekDates(today)

  let previousDates = Date.weekDates(today->DateFns.addDays(-7.))
  let _followingDates = Date.weekDates(today->DateFns.addDays(7.))

  let (todayFirst, _) = todayDates
  let (previousFirst, _) = previousDates

  React.useEffect2(() => {
    let (currentStartDate, _) = currentWeek
    let index = last5Weeks->Js.Array2.findIndex(week => {
      let (weekStart, _) = week
      weekStart->Js.Date.toString == currentStartDate
    })
    let dates = last5Weeks[index]->Option.getWithDefault(todayDates)
    if dates !== currentDates {
      currentDates_set(_ => dates)
    }
    scrollViewRef.current
    ->Js.Nullable.toOption
    ->Option.map(scrollView =>
      scrollView->ScrollView.scrollTo(
        ScrollView.scrollToParams(
          ~x=index->Js.Int.toFloat *. (scrollViewWidth -. rightSpace),
          ~y=0.,
          ~animated=false,
          (),
        ),
      )
    )
    ->ignore
    None
  }, (last5Weeks, currentWeek))

  let themeModeKey = AppSettings.useTheme()
  let theme = Theme.useTheme(themeModeKey)
  let isSkipped =
    settings.activitiesSkipped->Array.some(skipped => Activities.isSimilar(skipped, activityTitle))
  <SpacedView horizontal=None>
    <Row> <Spacer size=XS /> <BlockHeading text="Category" /> </Row>
    <ListSeparator />
    {ActivityCategories.defaults
    ->List.mapWithIndex((index, (id, name, colorName, iconName)) => {
      let color = colorName->ActivityCategories.getColor(theme.mode)
      <React.Fragment key=id>
        <ListItem
          onPress={_ => {
            let createdAt = Js.Date.now()
            setSettings(settings => {
              ...settings,
              lastUpdated: Js.Date.now(),
              activities: settings.activities
              ->Array.keep(acti => !Activities.isSimilar(acti.title, activityTitle))
              ->Array.concat([
                {
                  id: Utils.makeId(activityTitle, createdAt),
                  title: activityTitle,
                  createdAt: createdAt,
                  categoryId: id,
                },
              ]),
            })
          }}
          left={<NamedIcon name=iconName fill=color />}
          right={id != activityTitle->Calendars.categoryIdFromActivityTitle(settings.activities)
            ? <SVGCircle width={26.->Style.dp} height={26.->Style.dp} fill=color />
            : <SVGCheckmarkcircle width={26.->Style.dp} height={26.->Style.dp} fill=color />}>
          <ListItemText> {name->React.string} </ListItemText>
        </ListItem>
        {index !== ActivityCategories.defaults->List.length - 1
          ? <ListSeparator spaceStart={Spacer.size(S) *. 2. +. NamedIcon.size} />
          : React.null}
      </React.Fragment>
    })
    ->List.toArray
    ->React.array}
    <Separator style={theme.styles["separatorOnBackground"]} />
    <Spacer size=S />
    <Row> <Spacer size=XS /> <BlockHeading text="Activity chart" /> </Row>
    <Separator style={theme.styles["separatorOnBackground"]} />
    <View style={theme.styles["background"]}>
      <SpacedView vertical=None>
        <ScrollView
          ref={scrollViewRef->Ref.value}
          horizontal=true
          pagingEnabled=true
          showsHorizontalScrollIndicator=false
          onMomentumScrollEnd
          style={Style.array([Predefined.styles["row"], Predefined.styles["flexGrow"]])}>
          {last5Weeks
          ->Array.map(((currentStartDate, currentSupposedEndDate)) => {
            let endDate = currentSupposedEndDate->Date.min(today)
            let fetchedEvents = getEvents(currentStartDate, endDate)
            let events = switch fetchedEvents {
            | Done(evts) => Some(evts)
            | _ => None
            }
            let filteredEvents =
              events
              ->Option.map(event =>
                event
                ->Calendars.filterEvents(
                  settings.calendarsSkipped,
                  settings.activitiesSkippedFlag,
                  settings.activitiesSkipped,
                )
                ->Calendars.filterEventsByTitle(activityTitle)
                ->Calendars.sortEventsByDecreasingStartDate
              )
              ->Option.getWithDefault([])
            Js.log(filteredEvents)
            Js.log(currentStartDate)
            <WeeklyBarChartDetail
              key={currentStartDate->Js.Date.toString}
              today
              todayFirst
              previousFirst
              events=filteredEvents
              startDate=currentStartDate
              activityTitle
              supposedEndDate=currentSupposedEndDate
              width=scrollViewWidth
              rightSpace
            />
          })
          ->React.array}
        </ScrollView>
      </SpacedView>
      <Separator style={theme.styles["separatorOnBackground"]} />
    </View>
    <Row> <Spacer size=XS /> <BlockHeading text="Events" /> </Row>
    <Separator style={theme.styles["separatorOnBackground"]} />
    <View style={theme.styles["background"]}>
      <Events startDate endDate events=filteredEvents />
    </View>
    <Separator style={theme.styles["separatorOnBackground"]} />
    <ListSeparator />
    <Spacer size=L />
    <ListSeparator />
    <ListItem
      onPress={_ => {
        setSettings(settings => {
          let isSkipped =
            settings.activitiesSkipped->Array.some(skipped =>
              Activities.isSimilar(skipped, activityTitle)
            )
          {
            ...settings,
            lastUpdated: Js.Date.now(),
            activitiesSkipped: !isSkipped
              ? settings.activitiesSkipped->Array.concat([activityTitle])
              : settings.activitiesSkipped->Array.keep(alreadySkipped =>
                  !Activities.isSimilar(alreadySkipped, activityTitle)
                ),
          }
        })
        onSkipActivity()
      }}>
      <ListItemText color=theme.colors.red center=true>
        {(!isSkipped ? "Hide Activity" : "Reveal Activity")->React.string}
      </ListItemText>
    </ListItem>
    <ListSeparator />
    <BlockFootnote>
      {(
        !isSkipped
          ? "This will hide similar activities from all reports."
          : "This will reveal similar activities in all reports."
      )->React.string}
    </BlockFootnote>
  </SpacedView>
}
