function ts2utc --description 'Convert unix timestamp (seconds or ms) to UTC date string'
    if test (count $argv) -ne 1
        echo "usage: ts2utc <unix_timestamp>" >&2
        return 1
    end

    set -l ts $argv[1]

    # auto-detect milliseconds (13+ digits) and convert to seconds
    if test (string length -- $ts) -ge 13
        set ts (math "$ts / 1000")
    end

    date -u -r $ts "+%Y-%m-%d %H:%M:%S UTC"
end
