# Manual test checklist

Run `swift test` first, then check these in the built app.

## Copy with ⌘C in Finder

- [ ] One file shows "File copied"
- [ ] Three files show "3 files copied"
- [ ] One folder shows "Folder copied"
- [ ] Two folders show "2 folders copied"
- [ ] Three files and two folders show "3 files and 2 folders copied"
- [ ] One file and one folder show "1 file and 1 folder copied"
- [ ] An app such as Calculator shows "File copied"

## Copy as Pathname with ⌥⌘C in Finder

- [ ] One path shows "Path copied"
- [ ] One path containing spaces shows "Path copied"
- [ ] Several paths show the right count
- [ ] Several paths, some containing spaces, show the right count
- [ ] A path containing an apostrophe is counted correctly

## No toast

- [ ] Text selected while renaming a file
- [ ] Copies made while another app is frontmost
- [ ] Copies marked as concealed or temporary by a password manager
- [ ] Copies made in another app just before switching to Finder
- [ ] Copies made while copyToast is paused, including after resuming

## Toast

- [ ] Copying again while a toast is visible updates it without stacking
- [ ] It appears on the screen containing the mouse
- [ ] It doesn't take focus, and clicks pass through it
- [ ] It slides in and out, and skips the animation with Reduce Motion on
- [ ] It inverts correctly in light and dark mode
- [ ] It doesn't appear in screenshots

## Menu

- [ ] Pause dims the menu bar icon and stops toasts
- [ ] Launch at Login works when the app is in Applications
- [ ] About shows the icon, name, and version
- [ ] Buy me a coffee in About opens the support page in the default browser
- [ ] Quit closes the app
