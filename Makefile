.POSIX:

CRYSTAL = crystal
CRFLAGS =
FILES = test/*_test.cr test/**/*_test.cr test/**/*_spec.cr
OPTS = -v

a.out: .phony
	$(CRYSTAL) build --prelude=empty $(CRFLAGS) test/*_test.cr -o a.out

test: .phony
	$(CRYSTAL) run --prelude=empty $(CRFLAGS) $(FILES) -- $(OPTS)

.phony:
