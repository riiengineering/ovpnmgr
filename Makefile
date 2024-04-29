.POSIX:

prefix = /usr/local
bindir = $(prefix)/sbin

BUILD_CONFIG_FILE = build.config
YGPP = ygpp
INSTALL = install
RM = rm -f

all: ovpnmgr

ovpnmgr: .FORCE
	@+echo 'YGPP ovpnmgr'
	@set -a; test -f '$(BUILD_CONFIG_FILE)' && . '$(BUILD_CONFIG_FILE)'; $(YGPP) src/ovpnmgr.ygpp >$@

install: ovpnmgr .FORCE
	$(INSTALL) -d '$(DESTDIR)$(bindir)'
	$(INSTALL) -m 0755 ovpnmgr '$(DESTDIR)$(bindir)/ovpnmgr'

uninstall: .PHONY
	$(RM) '$(DESTDIR)$(bindir)/ygpp'

clean: .FORCE
	$(RM) ovpnmgr

.FORCE:
