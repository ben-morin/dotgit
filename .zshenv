# Keep path/fpath arrays unique. Prevents duplicate entries from
# accumulating across nested shells, since FPATH is exported (by
# `brew shellenv`) and dotfiles prepend to it unconditionally.
typeset -U path fpath PATH FPATH
