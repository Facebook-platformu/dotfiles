

# ================================================================
# Appearance
# ================================================================

# 色
autoload -Uz colors; colors             # プロンプトに色を付ける
# export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# export LSCOLORS=gxfxcxdxbxegedabagacad
# zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

#### vcs_info ###
# ref: http://mollifier.hatenablog.com/entry/20090814/p1
# ref: http://mollifier.hatenablog.com/entry/20100906/p1
# ref: http://qiita.com/mollifier/items/8d5a627d773758dd8078
autoload -Uz vcs_info
autoload -Uz is-at-least        # zshのバージョンによる分岐を有効に

# 以下の3つのメッセージをエクスポート
# - $vcs_info_msg_0_ : 通常メッセージ（green）
# - $vcs_info_msg_1_ : 警告メッセージ（yellow）
# - $vcs_info_msg_2_ : エラーメッセージ（red）
zstyle ':vcs_info:*' max-exports 2

zstyle ':vcs_info:*' enable git svn hg bzr

# 標準フォーマット
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

if is-at-least 4.3.10; then
    # git用フォーマット（ステージしているかの表示）
    # - %b: branch
    # - %a: action(only actionformats)
    # - %c: stagedstr
    # - %u: unstagedstr
    # - %m: others
    zstyle ':vcs_info:git:*' formats '%F{4}%b%f %F{2}%c%f%F{1}%u%f%m'
    zstyle ':vcs_info:git:*' actionformats '%F{13}%b-%a%f %F{2}%c%f%F{1}%u%f%m'
    # zstyle ':vcs_info:git:*' actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    zstyle ':vcs_info:git:*' check-for-changes true     # リポジトリの変更通知
fi

# hooks設定
if is-at-least 4.3.11; then
    # formats，actionformatsのメッセージを設定する際のフック関数
    # formatsは2つ，actionformatsは3つのメッセージがあるので各関数が最大3回呼ばれる
    zstyle ':vcs_info:git+set-message:*' hooks \
        git-hook-begin \
        git-status \

    # gitの作業コピーのあるディレクトリのみフック関数を呼び出す
    # - `git rev-parse`: gitリポジトリ名を返す
    # - `git rev-parse --is-inside-work-tree`: .gitディレクトリ内にいるかどうかの判定
    # - `2> /dev/null`: 標準エラー出力を/dev/nullに捨てる
    function +vi-git-hook-begin() {
        if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]];then
            return 1    # 0以外を返すとそれ以降のフック関数は呼び出されない
        fi
        return 0
    }

    function +vi-git-status() {
        hook_com[staged]=''
        hook_com[unstaged]=''

        # リポジトリに変更がなければreturnする（プロンプトを緑色に決定）
        # - `git status --porcelain`: machine readableなgit status（e.g. `?? hoge`みたいな出力）
        # - `wc`: 文字数，行数，バイト数を返す（`wc -l`: 行数のみ返す）
        # - `tr`: 文字の置換（`tr -d arg1`: arg1を消去）
        if [[ $(command git status --porcelain 2> /dev/null | wc -l | tr -d ' ') == "0" ]]; then
            hook_com[staged]+="✔"
        fi

        # ステージングされてないファイル数を取得（プロンプトをマゼンタに決定）
        # - `awk '{print $0}`: 渡された文字列を行ごとに出力
        # - `grep -F`: 固定文字列の検索
        local unstaged
        unstaged=$(command git status --porcelain 2> /dev/null \
            | awk '{print substr($0, 0, 2)}' | grep -F ' M' | wc -l | tr -d ' ')

        if [[ "$unstaged" -gt 0 ]]; then
            hook_com[unstaged]+="u${unstaged}"
        fi

        # ステージング済みのファイル数を取得
        local staged
        staged=$(command git status --porcelain 2> /dev/null \
            | awk '{print substr($0, 0, 2)}' | grep -e '[MA] ' | wc -l | tr -d ' ')

        if [[ "$staged" -gt 0 ]]; then
            hook_com[staged]+="s${staged}"
        fi

        # トラッキングされてないファイル数を取得
        # - `awk '{print $1}'`: 各行の1列目を出力
        local untracked
        untracked=$(command git status --porcelain 2> /dev/null \
            | awk '{print $1}' | grep -F '??' | wc -l | tr -d ' ')

        if [[ "$untracked" -gt 0 ]]; then
            hook_com[misc]+="%F{6}?${untracked}%f"
        fi

        # コンフリクトしてるファイル数を取得（プロンプトをマゼンタに決定）
        local unmerged
        unmerged=$(command git status --porcelain 2> /dev/null \
            | awk '{print $1}' | grep -F 'UU' | wc -l | tr -d ' ')

        if [[ "$unmerged" -gt 0 ]]; then
            hook_com[misc]+=" %F{13}c${unmerged}%f"
        fi

        local stashed
        stashed=$(command git stash list 2> /dev/null | wc -l | tr -d ' ')
        if [[ "$stashed" -gt 0 ]]; then
            hook_com[misc]+=" %F{6}s${stashed}%f"
        fi
    }
fi

function _update_vcs_info_msg() {
    LANG=en_US.UTF-8 vcs_info

    local p_cdir="%F{3}[%~]%f"
    local p_user="%(?.%F{10}:).%F{9}:()%f %# "
    local p_job="%(1j,%F{1}(%j jobs)%f,)"

    if [[ -z ${vcs_info_msg_0_} ]]; then
        # vcs_infoで何も取得していない場合はプロンプトを表示しない
        PROMPT=$'\n'${p_cdir}\ ${p_job}$'\n'${$p_user}
    else
        PROMPT=$'\n'${p_cdir}\ \(${vcs_info_msg_0_}\)\ ${p_job}$'\n'${p_user}
        # RPROMPT="${vcs_info_msg_0_}"
    fi
}

add-zsh-hook precmd _update_vcs_info_msg