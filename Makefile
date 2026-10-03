# Thin wrapper around the `erlanglings` escript for people who like `make`.
# Everything here also works without make:  ./erlanglings <command>

.PHONY: all test list run hint solution reset watch verify clean help

EX ?=

all: test

## Run the current exercise (the first one still marked I AM NOT DONE)
test:
	@./erlanglings

## Show every exercise and its status
list:
	@./erlanglings list

## Run one exercise:  make run EX=05   or   make run EX=tagged_tuples
run:
	@./erlanglings run $(EX)

## Print hints:  make hint EX=05   (defaults to the current exercise)
hint:
	@./erlanglings hint $(EX)

## Print the reference solution:  make solution EX=05
solution:
	@./erlanglings solution $(EX)

## Restore an exercise to its starting state:  make reset EX=05
reset:
	@./erlanglings reset $(EX)

## Rerun the current exercise whenever one of its files changes
watch:
	@./erlanglings watch

## Maintainers / CI: every solution must pass, every starter must fail
verify:
	@./erlanglings verify

clean:
	@rm -rf _build

help:
	@grep -E '^##' Makefile | sed 's/^## //'
