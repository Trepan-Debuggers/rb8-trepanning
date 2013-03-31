# I'll admit it -- I'm an absent-minded old-timer who has trouble
# learning new tricks.
.PHONY: all test test-unit test-integration rmChangeLog

GIT2CL ?= git2cl

all: test

#: Run unit, and integration without bloated output
check-short:
	$(MAKE) check 2>&1  | ruby check-filter.rb


#: Run all tests (same as "test")
check:
	rake test

#: Run all tests (same as "check")
test:
	rake test

rmChangeLog:
	rm ChangeLog || true

#: Create a ChangeLog from git via git log and git2cl
ChangeLog: rmChangeLog
	git log --pretty --numstat --summary | $(GIT2CL) >$@

.PHONY: $(PHONY)

%:
	rake $@
