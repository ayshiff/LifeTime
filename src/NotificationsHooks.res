let useNotificationStatus = () => {
  let (notificationStatus, notificationStatus_set) = React.useState(() => None)
  let appState = ReactNativeHooks.useAppState()
  React.useEffect2(() => {
    if appState === #active {
      Js.log("[LifeTime] NotificationsHooks: checkNotifications request")
      open ReactNativePermissions
      checkNotifications()
      ->FutureJs.fromPromise(error =>
        Js.Console.error(("[LifeTime] NotificationsHooks: checkNotifications", error))
      )
      ->Future.tapOk(res => notificationStatus_set(_ => Some(res.status)))
      ->ignore
    }
    None
  }, (appState, notificationStatus_set))

  let requestNotificationPermission = React.useCallback2(() =>
    notificationStatus !== Some(ReactNativePermissions.blocked)
      ? {
          open ReactNativePermissions
          requestNotifications(["alert", "badge", "sound"])
          ->FutureJs.fromPromise(error =>
            Js.Console.error((
              "[LifeTime] NotificationsHooks: requestNotificationPermission",
              error,
            ))
          )
          ->Future.tapOk(res => notificationStatus_set(_ => Some(res.status)))
          ->ignore
        }
      : ReactNativePermissions.openSettings()->ignore
  , (notificationStatus, notificationStatus_set))

  (notificationStatus, requestNotificationPermission)
}
