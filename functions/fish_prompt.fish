# Author: Daniel Draper
# Fork: https://github.com/vdka/simple
# Original: https://github.com/sotayamashita/simple
#
# MIT © Sota Yamashita

function __git_upstream_configured
    git rev-parse --abbrev-ref @"{u}" > /dev/null 2>&1
end

function __git_stashed
  git stash list 2> /dev/null | wc -l | sed -e "s/ *\([0-9]*\)/\ with\ \1\ stashes/g" | sed -e "s/\ with\ 0\ stashes//" -e 's/ 1 stashes/ 1 stash/'
end

function __print_color
    set -l color  $argv[1]
    set -l string $argv[2]

    set_color $color
    printf $string
    set_color normal
end

function fish_prompt -d "Simple Fish Prompt"
  set fish_color_error "929292"
  set fish_color_command "DFDFDF"
  set fish_color_normal "C5C5C5"
  set fish_color_valid_path "C5C5C5"
  set fish_color_param "8F8F8F"
  set fish_color_operator "8F8F8F"
  set fish_color_search_match "018752"

  # -- SSH ------------------------------------------------------------------ #

  if test ! -z "$SSH_CLIENT"
    # User
    #
    set -l user (id -un $USER)
    __print_color FF7676 "$user"

    # Host
    #
    set -l host_name (hostname -s)
    set -l host_glyph " at "

    __print_color C5C5C5 "$host_glyph"
    __print_color F6F49D "$host_name"


    # Only print the " in " if we are on a remote machine
    set -l pwd_glyph " in "
    __print_color C5C5C5 "$pwd_glyph"
  end

  # -- WORKING DIRECTORY ---------------------------------------------------- #

  set parent_dir (dirname "$PWD")
  set current_dir (basename "$PWD")

  # A loose match for $HOME
  if test "$parent_dir" = "$HOME"
      set parent_dir "~"
  end

  set parent_dir (basename $parent_dir)

  # vdka/json
  set pwd_string "$parent_dir/$current_dir"

  if test "$PWD" = ~
      set pwd_string "~"
  end

  echo -sn "$dir"
  echo -sn "$color_normal" #reset

  __print_color 018752 "$pwd_string"

  # -- GIT ------------------------------------------------------------------ #

  if git_is_repo
    set -l branch_name (git_branch_name)
    set -l git_glyph " on "
    set -l git_branch_glyph
    set -l git_branch_glyph_color "FFF"

    set git_branch_color "0D8489"

    if git_is_touched
      if git_is_staged
        if git_is_dirty
          # Staged files, some are dirty
          set git_branch_glyph_color "D0021B"
          set git_branch_glyph "*"
        else
          # All files are staged
          set git_branch_glyph_color "5CE6CD"
          set git_branch_glyph "*"
        end
      else
        # Dirty
        set git_branch_glyph_color "F5A623"
        set git_branch_glyph "*"
      end
    end

    __print_color C5C5C5 "$git_glyph"
    __print_color $git_branch_color "$branch_name"
    __print_color $git_branch_glyph_color "$git_branch_glyph"

    if __git_upstream_configured
      set -l git_ahead (command git rev-list --left-right --count HEAD...@"{u}" ^ /dev/null | awk '
        $1 > 0 { printf("⇡") } # can push
        $2 > 0 { printf("⇣") } # can pull
      ')

      if test ! -z "$git_ahead"
        __print_color 5DAE8B " $git_ahead"
      end
    end

    __print_color C5C5C5 (__git_stashed)
  end

  # -- LANGUAGE VERSIONS ---------------------------------------------------- #

  if test -e .swift-version
    if set swift_version (cat .swift-version | ack -o '(?<=-)(\d\d-\d\d)')
      __print_color C5C5C5 " using "
      __print_color FCA03C "$swift_version"
    end
  end

  if test -e .ruby-version
    if set ruby_version (cat .ruby-version | ack -o '\d.\d.\d')
      __print_color C5C5C5 " using "
      __print_color DD5143 "$ruby_version"
    end
  end

  __print_color C5C5C5 " "
end
