# Simple
# https://github.com/sotayamashita/simple
#
# MIT © Sota Yamashita

function __git_upstream_configured
    git rev-parse --abbrev-ref @"{u}" > /dev/null 2>&1
end

function __print_color
    set -l color  $argv[1]
    set -l string $argv[2]

    set_color $color
    printf $string
    set_color normal
end

function fish_prompt -d "Simple Fish Prompt"
    echo -sn " "

    # User
    #

    if test ! -z "$SSH_CLIENT"
        set -l user (id -un $USER)
        __print_color FF7676 "$user"


        # Host
        #
        set -l host_name (hostname -s)
        set -l host_glyph " at "

        __print_color ffffff "$host_glyph"
        __print_color F6F49D "$host_name"


        # Only print the " in " if we are on a remote machine
        set -l pwd_glyph " in "
        __print_color ffffff "$pwd_glyph"
    end

    # Current Working Directory
    #

    set parent_dir (dirname "$PWD")
    set current_dir (basename "$PWD")

    if test "$parent_dir" = "$HOME"
        set parent_dir "~"
    else if test "$parent_dir" = "/"
        set parent_dir ""
    end

    set parent_dir (basename $parent_dir)

    # vdka/json
    set pwd_string "$parent_dir/$current_dir"

    if test "$PWD" = ~
        set pwd_string "~"
    else if test "$PWD" = "/"
        set pwd_string "/"
    end

    echo -sn "$dir"
    echo -sn "$color_normal" #reset



    #set -l pwd_string (echo $PWD | sed 's|^'$HOME'\(.*\)$|~\1|')

    __print_color 018752 "$pwd_string"


    # Git
    #
    if git_is_repo
        set -l branch_name (git_branch_name)
        set -l git_glyph " on "
        set -l git_branch_glyph

        __print_color ffffff "$git_glyph"
        __print_color 0d8489 "$branch_name"

        if git_is_touched
          if git_is_staged
            if git_is_dirty
              # set git_branch_color "8D6CAB" # Some files staged, some dirty
              set git_branch_glyph_color "D0021B"
              set git_branch_glyph " *"
            else
              # set git_branch_color "EDB220" # All files staged
              set git_branch_glyph_color "5CE6CD"
              set git_branch_glyph " *"
            end
          else
            # set git_branch_color "E68523"
            set git_branch_glyph_color "F5A623"
            set git_branch_glyph " *"
          end
        end

        __print_color 6597ca "$git_branch_glyph"

        if __git_upstream_configured
             set -l git_ahead (command git rev-list --left-right --count HEAD...@"{u}" ^ /dev/null | awk '
                $1 > 0 { printf("⇡") } # can push
                $2 > 0 { printf("⇣") } # can pull
             ')

             if test ! -z "$git_ahead"
                __print_color 5DAE8B " $git_ahead"
            end
        end
    end

    if test -e .swift-version
        if set swift_version (cat .swift-version | ack -o '(?<=-)(\d\d-\d\d)')
            __print_color ffffff " using "
            __print_color F5871F "$swift_version"
        end
    end

    __print_color EEEEFF " "
end
