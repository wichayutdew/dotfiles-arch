function uuid --description 'Generate a random UUID (v4)'
    uuidgen | tr '[:upper:]' '[:lower:]'
end
