open Belt;
open ReactNative;
open ReactMultiversal;

let styles =
  Style.(
    StyleSheet.create({
      "text": textStyle(~fontSize=16., ~lineHeight=16. *. 1.4, ()),
      "durationText":
        textStyle(~fontSize=12., ~lineHeight=12., ~fontWeight=`_700, ()),
      "dash": style(~alignSelf=`stretch, ()),
    })
  );

let slices = 4;
let graphHeight = 100.;
let graphLetterHeight = 16.;

[@react.component]
let make = (~events, ~mapTitleDuration, ~startDate, ~supposedEndDate) => {
  let (settings, _setSettings) = React.useContext(AppSettings.context);
  let theme = Theme.useTheme();
  let themeStyles = Theme.useStyles();

  let supposedNumberOfDays =
    Date.durationInMs(startDate, supposedEndDate)->Date.msToDays;
  let dates =
    Array.range(0, supposedNumberOfDays->int_of_float)
    ->Array.map(n => startDate->Date.addDays(n));

  let durationPerDate =
    React.useMemo2(
      () =>
        events->Option.map(evts => {
          let events = evts->Calendars.filterEvents(settings);

          dates->Array.map(date => {
            let startOfDate = date->Date.startOfDay;
            let endOfDate = date->Date.endOfDay;
            (
              date,
              events->Array.reduce(
                Map.String.empty,
                (mapPerCategories, e) => {
                  // @todo real categories
                  let cat = e##title;
                  if (Date.hasOverlap(
                        e##startDate->Js.Date.fromString,
                        e##endDate->Js.Date.fromString,
                        date,
                      )) {
                    mapPerCategories->Map.String.set(
                      cat,
                      mapPerCategories
                      ->Map.String.get(cat)
                      ->Option.getWithDefault(0.)
                      +. Date.durationInMs(
                           e##startDate
                           ->Js.Date.fromString
                           ->Date.max(startOfDate),
                           e##endDate
                           ->Js.Date.fromString
                           ->Date.min(endOfDate),
                         )
                         ->Date.msToMin,
                    );
                  } else {
                    mapPerCategories;
                  };
                },
              ),
            );
          });
        }),
      (events, settings),
    );

  let maxDuration =
    durationPerDate
    ->Option.flatMap(durationPerDate =>
        durationPerDate
        ->Array.map(((_date, mapPerCategories)) =>
            mapPerCategories
            ->Map.String.toArray
            ->Array.reduce(0., (mins, (_, min)) => mins +. min)
          )
        ->SortArray.stableSortBy((minA, minB) =>
            minA > minB ? (-1) : minA < minB ? 1 : 0
          )[0]
      )
    ->Option.map(max => (max /. 60. /. 4.)->ceil *. 4. *. 60.);

  let (width, setWidth) = React.useState(() => 0.);
  let onLayout =
    React.useCallback0((layoutEvent: Event.layoutEvent) => {
      let width = layoutEvent##nativeEvent##layout##width;
      setWidth(_ => width);
    });

  let boxStyle =
    Style.(
      viewStyle(
        ~alignItems=`flexEnd,
        ~borderTopWidth=StyleSheet.hairlineWidth,
        ~borderTopColor=Theme.themedColors(theme).gray4,
        ~height=(graphHeight +. graphLetterHeight)->dp,
        (),
      )
    );

  <Row>
    <View onLayout style=Predefined.styles##flexGrow>
      <View
        style=Style.(
          list([
            StyleSheet.absoluteFill,
            Predefined.styles##rowSpaceBetween,
            boxStyle,
          ])
        )>
        {Array.range(0, supposedNumberOfDays->int_of_float)
         ->Array.map(i =>
             <React.Fragment key={i->string_of_int}>
               <Dash
                 style=Style.(
                   list([
                     styles##dash,
                     viewStyle(
                       ~position=`absolute,
                       ~top=0.->dp,
                       ~bottom=0.->dp,
                       ~left=(100. /. supposedNumberOfDays *. i->float)->pct,
                       (),
                     ),
                   ])
                 )
                 dashColor={Theme.themedColors(theme).gray4}
               />
               <SpacedView
                 horizontal=XXS
                 vertical=None
                 style=Style.(
                   viewStyle(
                     ~position=`absolute,
                     ~bottom=0.->dp,
                     ~left=(100. /. supposedNumberOfDays *. i->float)->pct,
                     //  ~height=graphHeight->dp,
                     (),
                   )
                 )>
                 <Text
                   style=Style.(
                     list([
                       themeStyles##textLightOnBackground,
                       textStyle(~fontSize=10., ()),
                     ])
                   )>
                   {startDate
                    ->Date.addDays(i)
                    ->Js.Date.getDay
                    ->Date.dayLetterString
                    ->React.string}
                 </Text>
               </SpacedView>
             </React.Fragment>
           )
         ->React.array}
        <Dash
          style=Style.(
            list([
              styles##dash,
              viewStyle(
                ~position=`absolute,
                ~top=0.->dp,
                ~bottom=0.->dp,
                ~left=100.->pct,
                (),
              ),
            ])
          )
          dashColor={Theme.themedColors(theme).gray4}
        />
      </View>
      {maxDuration
       ->Option.map(maxDuration => {
           let maxHours = maxDuration /. 60.;
           <View
             style=Style.(
               list([
                 StyleSheet.absoluteFill,
                 Predefined.styles##colSpaceBetween,
                 boxStyle,
                 viewStyle(~height=graphHeight->dp, ()),
               ])
             )>
             {Array.range(1, slices - 1)
              ->Array.reverse
              ->Array.map(i =>
                  <React.Fragment key={i->string_of_int}>
                    <View
                      style=Style.(
                        list([
                          styles##dash,
                          viewStyle(
                            ~position=`absolute,
                            ~left=0.->dp,
                            ~right=0.->dp,
                            ~bottom=(100. /. slices->float *. i->float)->pct,
                            ~height=StyleSheet.hairlineWidth->dp,
                            ~backgroundColor=Theme.themedColors(theme).gray5,
                            (),
                          ),
                        ])
                      )
                    />
                    <SpacedView
                      horizontal=XXS
                      vertical=None
                      style=Style.(
                        viewStyle(
                          ~position=`absolute,
                          ~right=0.->dp,
                          ~bottom=(100. /. slices->float *. i->float)->pct,
                          (),
                        )
                      )>
                      <Text
                        style=Style.(
                          list([
                            textStyle(
                              ~position=`absolute,
                              ~top=(-5.)->dp,
                              ~right=(-20.)->dp,
                              (),
                            ),
                            themeStyles##textLightOnBackground,
                            textStyle(~fontSize=10., ~lineHeight=10., ()),
                          ])
                        )>
                        {(maxHours /. slices->float *. i->float)
                         ->Js.Float.toString
                         ->React.string}
                        "h"->React.string
                      </Text>
                    </SpacedView>
                  </React.Fragment>
                )
              ->React.array}
             <View
               style=Style.(
                 list([
                   styles##dash,
                   viewStyle(
                     ~position=`absolute,
                     ~left=0.->dp,
                     ~right=0.->dp,
                     ~bottom=0.->pct,
                     ~height=StyleSheet.hairlineWidth->dp,
                     ~backgroundColor=Theme.themedColors(theme).gray5,
                     (),
                   ),
                 ])
               )
             />
           </View>;
         })
       ->Option.getWithDefault(React.null)}
      <View
        style=Style.(array([|Predefined.styles##rowSpaceBetween, boxStyle|]))>
        {durationPerDate
         ->Option.map(dpd =>
             dpd
             ->Array.map(((date, mapPerCategories)) =>
                 <SpacedView
                   key={date->Js.Date.toISOString}
                   horizontal=XS
                   vertical=None
                   style=Style.(
                     viewStyle(
                       ~width=(width /. dates->Array.length->float)->dp,
                       ~flexDirection=`columnReverse,
                       ~height=(graphHeight +. graphLetterHeight)->dp,
                       ~paddingBottom=graphLetterHeight->dp,
                       (),
                     )
                   )>
                   {mapTitleDuration
                    ->Option.map(mapTitleDuration =>
                        mapTitleDuration
                        ->Array.map(((title, _)) =>
                            mapPerCategories
                            ->Map.String.toArray
                            ->Array.map(((key, value)) =>
                                key !== title
                                  ? React.null
                                  : <View
                                      key
                                      style=Style.(
                                        array([|
                                          themeStyles##backgroundGray,
                                          viewStyle(
                                            ~height=
                                              (
                                                graphHeight
                                                /. maxDuration->Option.getWithDefault(
                                                     0.,
                                                   )
                                                *. value
                                              )
                                              ->dp,
                                            (),
                                          ),
                                        |])
                                      )
                                      // {!Global.__DEV__
                                      //    ? React.null
                                      //    : <Text
                                      //        style=Style.(
                                      //          textStyle(~fontSize=6., ())
                                      //        )>
                                      //        key->React.string
                                      //      </Text>}
                                    />
                              )
                            ->React.array
                          )
                        ->React.array
                      )
                    ->Option.getWithDefault(React.null)}
                 </SpacedView>
               )
             //  </Text>
             //    {date->Js.Date.getDay->Js.Float.toString->React.string}
             //  <Text key={date->Js.Date.toISOString}>
             ->React.array
           )
         ->Option.getWithDefault(React.null)}
      </View>
    </View>
    <Spacer />
  </Row>;
};