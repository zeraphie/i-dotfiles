# git wrapper — no-args shows status + pretty log, otherwise runs git normally
function git --wraps git --description 'git wrapper: no args shows status, otherwise normal git'
    if test (count $argv) -gt 0
        command git $argv
    else
        command git status
        and command git log \
            --graph \
            --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' \
            --abbrev-commit \
            --max-count=10
    end
end
