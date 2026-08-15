function load_env
    set -l env_file .env.local
    if count $argv > /dev/null
        set env_file $argv[1]
    end

    if test -f $env_file
        for line in (cat $env_file | grep -v '^#' | grep -v '^\s*$')
            set -l item (string split -m 1 = $line)
            set -gx $item[1] (string trim -c '"' (string trim -c "'" $item[2]))
        end
        echo "Loaded $env_file"
    else
        echo "File $env_file not found"
    end
end
