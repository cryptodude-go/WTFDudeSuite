# Settings scroll visibility · 0.17.3

- Root cause: arrow/theme picker cards focus their entire grid row. When the grid is taller than the viewport, the existing focus handler scrolls its bottom into view, moving the Show arrow checkbox above the viewport. The arrow visibility setting itself was unchanged.
- Mouse hover and selection on picker cards now preserve the current scroll position. Other focus/navigation behavior is retained.
- All settings tabs and nested pages share a visible right-side scrollbar when content overflows. The scrollbar supports thumb dragging, mouse wheel, track paging and up/down buttons. Thumb size/position and button state follow content and scroll position. A dedicated right gutter prevents overlap with settings rows.
- Regression checks hover/click every arrow skin, verifies Show arrow stays checked and visible, and covers scrollbar ranges/clamping, buttons, thumb dragging, track clicks, all six tabs and nested pages. Earlier native/menu/guide/profession/navigation/dragging/blinking tests also passed.

Addon-code update only; no WTF edits. Reload the UI after installing. Automated mock-client checks are not live WoW visual sign-off.
