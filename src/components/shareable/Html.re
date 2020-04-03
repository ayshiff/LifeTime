open Belt;
open ReactNative;
open ReactMultiversal;

// react-native-web
[@bs.module "react-native"]
external createWebElementFromString: (string, 'props) => React.element =
  "createElement";

let styles =
  Style.(
    StyleSheet.create({
      "aText": textStyle(~textDecorationLine=`underline, ()),
      "image": imageStyle(~maxWidth=100.->pct, ()),
      "liWrapper": viewStyle(~flexDirection=`row, ()),
      "liBullet":
        textStyle(~paddingHorizontal=10.->dp, ~alignSelf=`flexStart, ()),
      "hr":
        viewStyle(
          ~marginVertical=40.->dp,
          ~marginHorizontal=20.->dp,
          ~height=4.->dp,
          ~backgroundColor="#eee",
          (),
        ),
    })
  );

module A = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <Link href=props##href>
      <Text style=Style.(array([|styles##aText|]))> children </Text>
    </Link>;
  };
};

module H1 = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View accessibilityRole=`header>
      <Spacer />
      <Text style=Style.(array([|Theme.text##largeTitle, Theme.text##bold|]))>
        children
      </Text>
      <Spacer />
    </View>;
  };
};

module H2 = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View accessibilityRole=`header>
      <Spacer size=S />
      <Text style=Style.(array([|Theme.text##title1, Theme.text##bold|]))>
        children
      </Text>
      <Spacer size=S />
    </View>;
  };
};

module H3 = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View accessibilityRole=`header>
      <Spacer size=XS />
      <Text style=Style.(array([|Theme.text##title2, Theme.text##bold|]))>
        children
      </Text>
      <Spacer size=XS />
    </View>;
  };
};

module H4 = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View accessibilityRole=`header>
      <Spacer size=XXS />
      <Text style=Style.(array([|Theme.text##title3, Theme.text##bold|]))>
        children
      </Text>
      <Spacer size=XXS />
    </View>;
  };
};

module H5 = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View accessibilityRole=`header>
      <Spacer size=XXS />
      <Text style=Style.(array([|Theme.text##headline, Theme.text##bold|]))>
        children
      </Text>
      <Spacer size=XXS />
    </View>;
  };
};

module H6 = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View accessibilityRole=`header>
      <Text
        style=Style.(array([|Theme.text##headline, Theme.text##semiBold|]))>
        children
      </Text>
      <Spacer size=XXS />
    </View>;
  };
};

module P = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View>
      <Text style=Style.(array([|Theme.text##body|]))> children </Text>
      <Spacer />
    </View>;
  };
};

module TextNode = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <Text style=Style.(array([|Theme.text##body|]))> children </Text>;
  };
};

module Image = {
  [@react.component]
  let make = (~props=Js.Obj.empty()) => {
    Platform.os == Platform.web
      ? createWebElementFromString(
          "img",
          {"style": Style.(array([|styles##image|])), "src": props##src},
        )
      : <ImageFromUri style=Style.(array([|styles##image|])) uri=props##src />;
  };
};

module Ul = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~children) => {
    <View> children <Spacer /> </View>;
  };
};

module Li = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~bullet={j|•|j}, ~children) => {
    <View style=styles##liWrapper>
      <Text style={Style.array([|Theme.text##body, styles##liBullet|])}>
        bullet->React.string
      </Text>
      <Text style=Style.(array([|Theme.text##body|]))> children </Text>
    </View>;
  };
};

module Br = {
  /* Platform.OS */
  /* let make = _children => {...component, render: _self => <View />}; */
  [@react.component]
  let make = (~props=Js.Obj.empty()) => <Text> "\n"->React.string </Text>;
};

module Hr = {
  [@react.component]
  let make = (~props=Js.Obj.empty()) => <View style=styles##hr />;
};

module Details = {
  [@react.component]
  let make = (~props=Js.Obj.empty(), ~summary, ~children) => {
    let (isExpanded, setIsExpanded) = React.useState(() => false);
    let handleClick = _ => {
      setIsExpanded(isExpanded => !isExpanded);
    };

    <View>
      <TouchableOpacity onPress=handleClick>
        <Text style=Style.(array([|Theme.text##callout|]))>
          (isExpanded ? {j|▼ |j} : {j|▶ |j})->React.string
          {summary->Option.getWithDefault(
             "Click to see details"->React.string,
           )}
        </Text>
      </TouchableOpacity>
      {isExpanded ? <View> children </View> : React.null}
    </View>;
  };
};