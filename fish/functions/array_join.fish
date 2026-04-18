# array_join - Join array elements with a delimiter
#
# Usage: array_join DELIMITER [ELEMENTS...]
#
# Examples:
#   array_join ", " a b c         # → a, b, c
#   array_join ":" $PATH          # → /usr/bin:/usr/local/bin:...
#   set result (array_join "-" foo bar baz)

function array_join --description 'Join array elements with a delimiter'
    if test (count $argv) -lt 1
        echo "Usage: array_join DELIMITER [ELEMENTS...]" >&2
        return 1
    end

    set --local delimiter $argv[1]
    set --local elements $argv[2..]

    if test (count $elements) -eq 0
        return 0
    end

    set --local result $elements[1]

    for i in (seq 2 (count $elements))
        set result "$result$delimiter$elements[$i]"
    end

    echo $result
end
