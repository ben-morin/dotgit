#!/usr/bin/env zsh

# global configuration...
# override in the environment before this file is sourced.

#   ATUIN_HISTORY_SEARCH_FILTER_MODE  history scope the arrows search:
#       global | host | session | directory | workspace | session-preload
: ${ATUIN_HISTORY_SEARCH_FILTER_MODE='session-preload'}

#   ATUIN_HISTORY_SEARCH_SEARCH_MODE  how the typed text is matched:
#       prefix | full-text | fuzzy | skim | daemon-fuzzy
: ${ATUIN_HISTORY_SEARCH_SEARCH_MODE='prefix'}

# internal variables...

typeset -g -i _atuin_history_match_index
typeset -g    _atuin_history_search_result
typeset -g    _atuin_history_search_query
typeset -g -i _atuin_history_refresh_display

# main functions and key bindings...

atuin-history-up() {
  _atuin-history-search-begin
  _atuin-history-up-buffer || _atuin-history-up-search
  _atuin-history-search-end
}

atuin-history-down() {
  _atuin-history-search-begin
  _atuin-history-down-buffer || _atuin-history-down-search
  _atuin-history-search-end
}

zle -N atuin-history-up
zle -N atuin-history-down

# plain Up/Down: native zsh history (walks $HISTFILE), respecting multi-line buffers...
bindkey '\eOA' up-line-or-history
bindkey '\eOB' down-line-or-history
bindkey '\e[A' up-line-or-history
bindkey '\e[B' down-line-or-history

# Shift+Up / Shift+Down: atuin history search...
bindkey '\e[1;2A' atuin-history-up
bindkey '\e[1;2B' atuin-history-down

# implementation functions...

_atuin-history-search-begin() {
  # assume not rendering anything...
  _atuin_history_refresh_display=0

  # if buffer is the same, step through matches, else new search...
  if [[ -n $BUFFER && $BUFFER == ${_atuin_history_search_result:-} ]]; then
    return
  fi

  # clear previous result....
  _atuin_history_search_result=''

  # setup search query...
  _atuin_history_search_query="$BUFFER"

  # reset search index...
  _atuin_history_match_index=0
}

_atuin-history-search-end() {
  # if index is <= 0 just print original search query...
  if [[ $_atuin_history_match_index -le 0 ]]; then
    _atuin_history_search_result="$_atuin_history_search_query"
  fi

  # draw buffer if needed...
  if [[ $_atuin_history_refresh_display -eq 1 ]]; then
    BUFFER="$_atuin_history_search_result"
    CURSOR="${#BUFFER}"
  fi
}

_atuin-history-up-buffer() {
  # Check if UP arrow was pressed to move the cursor within a multi-line buffer...
  #
  # 1. $#buflines -gt 1.
  #
  # 2. Check if on the first line of current multi-line buffer, leave on UP.
  #
  #    Check by adding extra "x" to $LBUFFER, which makes xlbuflines always equal to
  #    the number of lines up to $CURSOR (including the line with the cursor).
  #
  local buflines XLBUFFER xlbuflines
  buflines=(${(f)BUFFER})
  XLBUFFER="${LBUFFER}x"
  xlbuflines=(${(f)XLBUFFER})

  if [[ $#buflines -gt 1 && $#xlbuflines -ne 1 ]]; then
    zle up-line-or-history
    return 0
  fi

  return 1
}

_atuin-history-down-buffer() {
  # Check if DOWN arrow was pressed to move the cursor within a multi-line buffer...
  #
  # 1. $#buflines -gt 1.
  #
  # 2. Check if on the last line of current multi-line buffer, leave on DOWN.
  #
  #    Check by adding extra "x" to $RBUFFER, which makes xrbuflines always equal to
  #    the number of lines from $CURSOR (including the line with the cursor).
  #
  local buflines XRBUFFER xrbuflines
  buflines=(${(f)BUFFER})
  XRBUFFER="x${RBUFFER}"
  xrbuflines=(${(f)XRBUFFER})

  if [[ $#buflines -gt 1 && $#xrbuflines -ne 1 ]]; then
    zle down-line-or-history
    return 0
  fi

  return 1
}

_atuin-history-up-search() {
  local offset search_result

  _atuin_history_match_index+=1

  offset=$((_atuin_history_match_index-1))
  search_result=$(_atuin-history-search $offset "$_atuin_history_search_query")

  if [[ -z $search_result ]]; then
    # if search result is empty, no more history, just show previous result...
    _atuin_history_match_index+=-1
    return 1
  fi

  _atuin_history_refresh_display=1
  _atuin_history_search_result="$search_result"
  return 0
}

_atuin-history-down-search() {
  local offset

  if [[ $_atuin_history_match_index -le 0 ]]; then
    return 1
  fi

  _atuin_history_refresh_display=1
  _atuin_history_match_index+=-1

  offset=$((_atuin_history_match_index-1))
  _atuin_history_search_result=$(_atuin-history-search $offset "$_atuin_history_search_query")

  return 0
}

_atuin-history-search() {
  if [[ $1 -ge 0 ]]; then
    atuin search --author '$all-user' --shell-up-key-binding \
			--filter-mode "$ATUIN_HISTORY_SEARCH_FILTER_MODE" \
			--search-mode "$ATUIN_HISTORY_SEARCH_SEARCH_MODE" \
      --limit 1 --offset "$1" --format "{command}" \
      "$2"
  fi
}


