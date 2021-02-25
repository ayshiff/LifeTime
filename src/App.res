open Belt
open ReactNative
open ReactNavigation

NativeStack.enableScreens()

let navigatorEmitter = EventEmitter.make()

{
  open ReactNativePushNotification
  configure(
    configureOptions(
      ~requestPermissions=false,
      ~popInitialNotification=true,
      ~onNotification=notification => {
        Js.log(("[LifeTime] App: onNotification ", notification))
        switch notification.id {
        | Some(id) when id == Notifications.Ids.reminderDailyCheck =>
          navigatorEmitter->EventEmitter.emit("navigate", "GoalsScreen")
        | _ => ()
        }
        notification.finish(ReactNativePushNotificationIOS.FetchResult.noData)
      },
      (),
    ),
  )
  createChannel(
    channel(
      ~channelId="reminders",
      ~channelName="Reminders",
      ~channelDescription="Reminders for your goals",
      (),
    ),
  )
}

type navigationState
let navigationStateStorageKey = "react-navigation:state:2"
// remove old entries
ReactNativeAsyncStorage.removeItem("react-navigation:state")->ignore

let rec navigateToIfPossible = (navigation, navigateTo) =>
  switch navigation {
  | Some(navigation) when navigateTo == "GoalsScreen" =>
    navigation->Navigators.RootStack.Navigation.navigateWithParams(
      "GoalsStack",
      Navigators.RootStack.M.params(~screen="GoalsScreen", ()),
    )
  | _ => Js.Global.setTimeout(() => navigateToIfPossible(navigation, navigateTo), 250)->ignore
  }

@react.component
let app = () => {
  let navigationRef = React.useRef(None)
  React.useEffect1(() => {
    Js.log("[LifeTime] App: navigatorEmitter on(navigate) ")
    navigatorEmitter->EventEmitter.on("navigate", navigateTo =>
      navigateToIfPossible(navigationRef.current, navigateTo)
    )
    None
  }, [])

  let (initialStateContainer, setInitialState) = React.useState(() => None)

  React.useEffect2(() => {
    if initialStateContainer->Option.isNone {
      Js.log("[LifeTime] App: Restoring Navigation initialStateContainer is empty")
      ReactNativeAsyncStorage.getItem(navigationStateStorageKey)
      ->FutureJs.fromPromise(error => {
        // @todo error
        Js.log(("[LifeTime] App: Restoring Navigation State: ", error))
        error
      })
      ->Future.tap(res => {
        Js.log("[LifeTime] App: Restoring Navigation State")
        switch res {
        | Result.Ok(jsonState) =>
          switch jsonState->Js.Null.toOption {
          | Some(jsonState) =>
            switch Js.Json.parseExn(jsonState) {
            | state => setInitialState(_ => Some(Some(state)))
            | exception _ =>
              Js.log((
                "[LifeTime] App: Restoring Navigation State: unable to decode valid json",
                jsonState,
              ))
              setInitialState(_ => Some(None))
            }
          | None => setInitialState(_ => Some(None))
          }
        | Result.Error(e) =>
          Js.log(("[LifeTime] App: Restoring Navigation State: unable to get json state", e))
          setInitialState(_ => Some(None))
        }
      })
      ->ignore
    }
    None
  }, (initialStateContainer, setInitialState))

  let onStateChange = React.useCallback0(state => {
    let maybeJsonState = Js.Json.stringifyAny(state)
    switch maybeJsonState {
    | Some(jsonState) =>
      ReactNativeAsyncStorage.setItem(navigationStateStorageKey, jsonState)->ignore
    | None =>
      Js.log(
        "[LifeTime] App: <Native.NavigationContainer> onStateChange: Unable to stringify navigation state",
      )
    }
  })

  let calendarsContextValue = Calendars.useEventsContext()
  let onReady = React.useCallback0(() => {
    ReactNativeBootsplash.hide({fade: true})->Js.Promise.then_(() => {
      Js.log("[LifeTime] BootSplash: fading is over")
      Js.Promise.resolve()
    }, _)->Js.Promise.catch(error => {
      Js.log(("[LifeTime] BootSplash: cannot hide splash", error))
      Js.Promise.resolve()
    }, _)->ignore
  })

  // let (initialized, initialized_set) = React.useState(() => false);
  let (optionalSettings, optionalSettings_set) = React.useState(() => None)
  React.useEffect1(() => {
    AppSettings.getSettings()
    ->Future.tap(settings => optionalSettings_set(_ => Some(settings)))
    ->ignore
    None
  }, [optionalSettings_set])

  let settings_set = settingsCallback => {
    Js.log("[LifeTime] App: Updating settings")
    InteractionManager.runAfterInteractions(() => {
      Js.Global.setTimeout(() => {
        optionalSettings_set(settings =>
          settings
          ->Option.map(settings => {
            let newSettings = settingsCallback(settings)
            InteractionManager.runAfterInteractions(() => {
              Js.Global.setTimeout(() => {
                AppSettings.setSettings(newSettings)
              }, 0)->ignore
            })->ignore
            Some(newSettings)
          })
          ->Option.getWithDefault(settings)
        )
      }, 0)->ignore
    })->ignore
  }

  optionalSettings
  ->Option.map(settings =>
    <ReactNativeSafeAreaContext.SafeAreaProvider>
      <AppSettings.ContextProvider value=(settings, settings_set)>
        <Calendars.ContextProvider value=calendarsContextValue>
          {initialStateContainer
          ->Option.map(initialState =>
            <Native.NavigationContainer
              ref={navigationRef->Obj.magic}
              // doesn't work properly with native-stack
              // ?initialState
              onStateChange
              onReady>
              <Nav.RootNavigator />
            </Native.NavigationContainer>
          )
          ->Option.getWithDefault(React.null)}
          <NotificationsRegisterer />
        </Calendars.ContextProvider>
      </AppSettings.ContextProvider>
    </ReactNativeSafeAreaContext.SafeAreaProvider>
  )
  ->Option.getWithDefault(React.null)
}
