set-face global HiddenSelection 'white,bright-red+F'

declare-option range-specs hidden_selections_indicator_ranges
declare-option str hidden_selections_above_and_below_indicator '●'
declare-option str hidden_selections_above_indicator '▲'
declare-option str hidden_selections_below_indicator '▼'

# add-highlighter shared/hidden_selections_indicator replace-ranges hidden_selections_indicator_ranges

define-command update_hidden_selections_indicator_ranges %{
  set-option window hidden_selections_indicator_ranges %val{timestamp}

  try %{
    # Determine multiple selections.
    execute-keys -draft '<a-,>'

    try %{
      # Determine hidden selections above and below.
      execute-keys -draft -save-regs '^tb' 'Zgt"tZgbx;"bZe"tzb"tz"b<a-z>u<a-z>a<a-,>'
      set-option -add window hidden_selections_indicator_ranges "%val{cursor_line}.%val{cursor_char_column}+1|{HiddenSelection}%opt{hidden_selections_above_and_below_indicator}"
    } catch %{
      # Determine hidden selections above.
      execute-keys -draft -save-regs '^t' 'Zgt"tZb"tzGe<a-z>a<a-,>'
      set-option -add window hidden_selections_indicator_ranges "%val{cursor_line}.%val{cursor_char_column}+1|{HiddenSelection}%opt{hidden_selections_above_indicator}"
    } catch %{
      # Determine hidden selections below.
      execute-keys -draft -save-regs '^b' 'Zgbx;"bZe"bzGg<a-z>a<a-,>'
      set-option -add window hidden_selections_indicator_ranges "%val{cursor_line}.%val{cursor_char_column}+1|{HiddenSelection}%opt{hidden_selections_below_indicator}"
    } catch %{
    }
  }
}

hook global NormalIdle '' update_hidden_selections_indicator_ranges
hook global InsertIdle '' update_hidden_selections_indicator_ranges
hook global PromptIdle '' update_hidden_selections_indicator_ranges

# add-highlighter global/hidden_selections_indicator ref hidden_selections_indicator_ranges
add-highlighter global/hidden_selections_indicator replace-ranges hidden_selections_indicator_ranges

