TEST_ROOT_DEST=${TMPDIR:-/tmp}/nix-test/nix
mkdir -p $TEST_ROOT_DEST
TEST_ROOT=$(realpath $TEST_ROOT_DEST)

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

# Avoid "sqlite is busy" errors in the single-user build mode
echo 'use-sqlite-wal = false' > $NIX_CONF_DIR/nix.conf
echo 'sandbox = false' >> $NIX_CONF_DIR/nix.conf

# Setup the store directories to reduce races later
# https://github.com/NixOS/nix/issues/2706
nix-store --init
