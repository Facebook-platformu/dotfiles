_register_keycommand() {
  zle -N $2
  bindkey "$1" $2
}

_buffer_insert() {
  local rbuf="$RBUFFER"
  BUFFER="$LBUFFER$(cat)"
  CURSOR=$#BUFFER
  BUFFER="$BUFFER$rbuf"
}

_buffer_replace() {
  BUFFER="$(cat)"
  CURSOR=$#BUFFER
}

_peco_select() {
  local tx="$(cat)"
  local query="$1"

  if [ "$tx" = '' ]; then
    tx=' '
    query='(nothing)'
  fi

  peco --query "$query" <<< "$tx"
}

_reverse() {
    if which tac > /dev/null; then
        tac <<< $(cat)
    else
        tail -r <<< $(cat)
    fi
}

_is_git_repo() {
    git rev-parse --is-inside-work-tree > /dev/null 2>&1
}

# ==== peco project ================================================================
peco_ghq_list() {
    ghq list -p \
        | _peco_select \
        | {
            local repo=$(cat)
            if [ -n "$repo" ]; then
                _buffer_replace <<< "cd $repo"
                zle accept-line
            fi
        }
}

_register_keycommand '^]' peco_ghq_list


# ==== tmux attach ================================================================
tmux_attach() {
    tmux list-sessions \
        | _peco_select \
        | awk -F: '{ print $1 }' \
        | {
            local session=$(cat)
            if [ -n "$session" ]; then
                title $session
                _buffer_replace <<< "tmux attach -t $session"
                zle accept-line
            fi
        }
}

_register_keycommand '^@' tmux_attach


# ==== git status ===============================================================
git_status() {
    if _is_git_repo; then
        echo git status -sb
        git status -sb
    fi
    zle reset-prompt
}

_register_keycommand '^gs' git_status


# ==== git patch ================================================================
git_patch() {
    _is_git_repo \
        && git status --porcelain \
        | _peco_select \
        | awk '{ print $2 }' \
        | {
            local target="$(cat)"
            if [ -n "$target" ]; then
                _buffer_replace <<< "git add -p $target"
                zle accept-line
            fi
            zle clear-screen
        }
}

_register_keycommand '^gp' git_patch


# ==== peco history ===============================================================
peco_history() {
    \history -n 1 \
        | _reverse \
        | _peco_select "$LBUFFER" \
        | _buffer_replace
}

_register_keycommand '^r' peco_history
