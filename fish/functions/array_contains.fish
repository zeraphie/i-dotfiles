# array_contains.fish
# Check whether a value exists in a list/array.
#
# Usage:
#   array_contains <needle> $some_list
#   array_contains <needle> val1 val2 val3
#
# Returns 0 (true) if the needle is found, 1 (false) otherwise.
#
# Examples:
#   set fruits apple banana cherry
#   if array_contains banana $fruits
#       echo "Found it!"
#   end
#
#   array_contains rust typescript python bun rust
#   # → exits 0 (found)

function array_contains
    if test (count $argv) -lt 2
        echo "Usage: array_contains <needle> [values...]" >&2
        return 2
    end

    set --local needle $argv[1]
    set --local haystack $argv[2..]

    for item in $haystack
        if test "$item" = "$needle"
            return 0
        end
    end

    return 1
end
