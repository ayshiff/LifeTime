open ReactNative

@react.component
let make = (~children) => {
  let theme = Theme.useTheme(AppSettings.useTheme())
  <BlockFootnoteContainer>
    <Text
      style={
        open Style
        array([Theme.text["footnote"], theme.styles["textOnDarkLight"]])
      }>
      children
    </Text>
  </BlockFootnoteContainer>
}
