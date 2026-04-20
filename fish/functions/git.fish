# git wrapper — no-args shows status + interactive repl, otherwise runs git normally
function git --wraps git --description 'git wrapper: no args shows status + repl, otherwise normal git'
    if test (count $argv) -gt 0
        command git $argv
    else
        command git status
        and command git repl 2>/dev/null
    end
end
