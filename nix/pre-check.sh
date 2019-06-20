TEST_ROOT_DEST=${TMPDIR:-/tmp}/nix-test/nix
mkdir -p $TEST_ROOT_DEST
TEST_ROOT=$(realpath $TEST_ROOT_DEST)

# prevent us from creating $HOME if it doesn’t exist
export XDG_CACHE_HOME=${TMPDIR:-/tmp}/nix-test/xdg-cache-dir

export NIX_STORE_DIR=$TEST_ROOT/store
mkdir -p $NIX_STORE_DIR
export NIX_LOCALSTATE_DIR=$TEST_ROOT/var
mkdir -p $NIX_LOCALSTATE_DIR
export NIX_LOG_DIR=$TEST_ROOT/var/log/nix
mkdir -p $NIX_LOG_DIR
export NIX_STATE_DIR=$TEST_ROOT/var/nix
mkdir -p $NIX_STATE_DIR
export NIX_CONF_DIR=$TEST_ROOT/etc
mkdir -p $NIX_CONF_DIR

# https://github.com/NixOS/nix/blob/5112a33fb17f792ceb6d641738277cbbe6a58bfc/tests/common.sh.in#L15
if [[ -n $NIX_STORE ]]; then
    export _NIX_TEST_NO_SANDBOX=1
fi

# Avoid "sqlite is busy" errors in the single-user build mode
echo 'use-sqlite-wal = false' > $NIX_CONF_DIR/nix.conf
echo 'sandbox = false' >> $NIX_CONF_DIR/nix.conf

# Setup the store directories to reduce races later
# https://github.com/NixOS/nix/issues/2706
nix-store --init
