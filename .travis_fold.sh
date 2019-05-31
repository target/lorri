# fold a named ($1) command in travisCI
function lorri_travis_fold() {
    name=$1
    shift
    echo "travis_fold:start:$name"
    command "$@"
    status="$?"
    # don’t fold when there was an error
    if [ "$status" -eq 0 ]; then
        echo "travis_fold:end:$name"
    fi
    return "$status"
}
