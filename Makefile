.POSIX:

BUILD_CONFIG_FILE = build.config
YGPP = ygpp

all: ovpnmgr

ovpnmgr: $(BUILD_CONFIG_FILE) .FORCE
	@+echo 'YGPP ovpnmgr'
	@set -a; test -f '$(BUILD_CONFIG_FILE)' && . '$(BUILD_CONFIG_FILE)'; $(YGPP) src/ovpnmgr.ygpp >$@

.FORCE:
