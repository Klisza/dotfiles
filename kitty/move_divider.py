"""Move a split divider in screen coordinates instead of resizing by pane size.

Uses the split tree and drag-resize API from Kitty 0.49.2. The nearest ancestor
split on the requested axis determines which divider moves in nested layouts.
"""

from kittens.tui.handler import result_handler


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return
    tab = window.tabref()
    if tab is None or tab.current_layout.name != "splits":
        return
    direction = args[1] if len(args) > 1 else ""
    if direction not in ("left", "right", "up", "down"):
        return
    group = tab.windows.group_for_window(window)
    if group is None:
        return
    path = tab.current_layout.pairs_root.find_window_in_tree(group.id)
    horizontal = direction in ("left", "right")
    increment = -2 if direction in ("left", "up") else 2
    for pair, _ in reversed(path or []):
        if pair.horizontal == horizontal and not pair.is_redundant:
            tab.drag_resize_window(id(pair), increment, horizontal)
            return
