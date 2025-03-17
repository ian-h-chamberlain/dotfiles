{ lib, vimMode ? false, ... }: {
  settings = {
    theme = "monokai";

    keys = lib.mkIf vimMode {
      insert.esc = [ "collapse_selection" "normal_mode" ];
      normal = {
        "#" = [
          "move_char_right"
          "move_prev_word_start"
          "move_next_word_end"
          "search_selection"
          "search_prev"
        ];
        "$" = "goto_line_end";
        "%" = "match_brackets";
        "*" = [
          "move_char_right"
          "move_prev_word_start"
          "move_next_word_end"
          "search_selection"
          "search_next"
        ];
        "0" = "goto_line_start";
        B = [ "move_prev_long_word_start" "collapse_selection" ];
        C = [ "extend_to_line_end" "yank_main_selection_to_clipboard" "delete_selection" "insert_mode" ];
        C-h = "select_prev_sibling";
        C-j = "shrink_selection";
        C-k = "expand_selection";
        C-l = "select_next_sibling";
        C-o = ":config-open";
        C-r = ":config-reload";
        D = [ "extend_to_line_end" "yank_main_selection_to_clipboard" "delete_selection" ];
        E = [ "move_next_long_word_end" "collapse_selection" ];
        G = "goto_file_end";
        O = [ "open_above" "normal_mode" ];
        P = [ "paste_clipboard_before" "collapse_selection" ];
        S = "surround_add";
        V = [ "select_mode" "extend_to_line_bounds" ];
        W = [ "move_next_long_word_start" "move_char_right" "collapse_selection" ];
        Y = [ "extend_to_line_end" "yank_main_selection_to_clipboard" "collapse_selection" ];
        "^" = "goto_first_nonwhitespace";
        a = [ "append_mode" "collapse_selection" ];
        b = [ "move_prev_word_start" "collapse_selection" ];
        d.G = [
          "select_mode"
          "extend_to_line_bounds"
          "goto_last_line"
          "extend_to_line_bounds"
          "yank_main_selection_to_clipboard"
          "delete_selection"
          "normal_mode"
        ];
        d.W = [ "move_next_long_word_start" "yank_main_selection_to_clipboard" "delete_selection" ];
        d.a = [ "select_textobject_around" ];
        d.d = [ "extend_to_line_bounds" "yank_main_selection_to_clipboard" "delete_selection" ];
        d.down = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_below"
          "yank_main_selection_to_clipboard"
          "delete_selection"
          "normal_mode"
        ];
        d.g.g = [
          "select_mode"
          "extend_to_line_bounds"
          "goto_file_start"
          "extend_to_line_bounds"
          "yank_main_selection_to_clipboard"
          "delete_selection"
          "normal_mode"
        ];
        d.i = [ "select_textobject_inner" ];
        d.j = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_below"
          "yank_main_selection_to_clipboard"
          "delete_selection"
          "normal_mode"
        ];
        d.k = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_above"
          "yank_main_selection_to_clipboard"
          "delete_selection"
          "normal_mode"
        ];
        d.s = [ "surround_delete" ];
        d.t = [ "extend_till_char" ];
        d.up = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_above"
          "yank_main_selection_to_clipboard"
          "delete_selection"
          "normal_mode"
        ];
        d.w = [ "move_next_word_start" "yank_main_selection_to_clipboard" "delete_selection" ];
        e = [ "move_next_word_end" "collapse_selection" ];
        esc = [ "collapse_selection" "keep_primary_selection" ];
        i = [ "insert_mode" "collapse_selection" ];
        j = "move_line_down";
        k = "move_line_up";
        o = [ "open_below" "normal_mode" ];
        p = [ "paste_clipboard_after" "collapse_selection" ];
        u = [ "undo" "collapse_selection" ];
        w = [ "move_next_word_start" "move_char_right" "collapse_selection" ];
        x = "delete_selection";
        y.G = [
          "select_mode"
          "extend_to_line_bounds"
          "goto_last_line"
          "extend_to_line_bounds"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.W = [
          "move_next_long_word_start"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.down = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_below"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.g.g = [
          "select_mode"
          "extend_to_line_bounds"
          "goto_file_start"
          "extend_to_line_bounds"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.j = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_below"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.k = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_above"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.up = [
          "select_mode"
          "extend_to_line_bounds"
          "extend_line_above"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.w = [
          "move_next_word_start"
          "yank_main_selection_to_clipboard"
          "collapse_selection"
          "normal_mode"
        ];
        y.y = [
          "extend_to_line_bounds"
          "yank_main_selection_to_clipboard"
          "normal_mode"
          "collapse_selection"
        ];
        "{" = [ "goto_prev_paragraph" "collapse_selection" ];
        "}" = [ "goto_next_paragraph" "collapse_selection" ];
      };
      select = {
        "$" = "goto_line_end";
        "%" = "match_brackets";
        "0" = "goto_line_start";
        C = [ "goto_line_start" "extend_to_line_bounds" "change_selection" ];
        C-a = [ "append_mode" "collapse_selection" ];
        D = [ "extend_to_line_bounds" "delete_selection" "normal_mode" ];
        G = "goto_file_end";
        P = "paste_clipboard_before";
        S = "surround_add";
        U = [ "switch_to_uppercase" "collapse_selection" "normal_mode" ];
        Y = [
          "extend_to_line_bounds"
          "yank_main_selection_to_clipboard"
          "goto_line_start"
          "collapse_selection"
          "normal_mode"
        ];
        "^" = "goto_first_nonwhitespace";
        a = "select_textobject_around";
        d = [ "yank_main_selection_to_clipboard" "delete_selection" ];
        esc = [ "collapse_selection" "keep_primary_selection" "normal_mode" ];
        i = "select_textobject_inner";
        j = [ "extend_line_down" "extend_to_line_bounds" ];
        k = [ "extend_line_up" "extend_to_line_bounds" ];
        p = "replace_selections_with_clipboard";
        tab = [ "insert_mode" "collapse_selection" ];
        u = [ "switch_to_lowercase" "collapse_selection" "normal_mode" ];
        x = [ "yank_main_selection_to_clipboard" "delete_selection" ];
        y = [
          "yank_main_selection_to_clipboard"
          "normal_mode"
          "flip_selections"
          "collapse_selection"
        ];
        "{" = [ "extend_to_line_bounds" "goto_prev_paragraph" ];
        "}" = [ "extend_to_line_bounds" "goto_next_paragraph" ];
      };
    };
  };
}
