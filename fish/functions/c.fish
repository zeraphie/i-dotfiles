# Smart cd function — navigate, print underlined path, list contents
# Equivalent of the old bash c() function, rewritten for Fish
#
# Usage:
#   c           — refresh current directory listing
#   c <path>    — cd to path, then show underlined pwd + listing
#   c -         — go back to previous directory
#   c ..        — go up one level (and so on)

function c --description 'Smart cd: navigate, print underlined path, list directory contents'
    # Only cd if the target isn't "." (bare dot just refreshes listing)
    if test (count $argv) -eq 0
        # No args — stay put, just show listing
    else if test "$argv[1]" != "."
        builtin cd $argv
        or return $status
    end

    # Print a blank line for breathing room
    echo

    # Print the current path with an underline ANSI escape
    # \e[4m = underline on, \e[0m = reset
    printf '\e[4m%s\e[0m\n' (prompt_pwd --full-length-dirs 9999)

    echo

    # List directory contents — compact columnar view with type indicators
    ls -hF
end
