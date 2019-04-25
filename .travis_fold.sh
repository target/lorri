# fold a named ($1) command in travisCI
function travis_fold() {
    name=$1
    shift
    echo "travis_fold:start:$name"
    command "$@"
    status="$?"
    echo "travis_fold:end:$name"
    return "$status"
}
