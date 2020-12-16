#!/usr/bin/env bash

set -e

OUT=/tmp/out
ERR=/tmp/err

touch "$OUT"
touch "$ERR"

if [[ ! -x "$UNILANG" ]]; then
	UNILANG=./unilang
fi

run()
{
	set +e
	echo > "$ERR"
	echo "$1" | "$UNILANG" 1> "$OUT" 2> "$ERR"
	set -e
}

# NOTE: Test cases should print no errors.
test()
{
	echo "Running case:" "$1"
	if ! (run "$1") || [ -s "$ERR" ]; then
		echo "FAIL."
		echo "Error:"
		cat "$ERR"
	else
		echo "PASS."
	fi
}

# Sanity.
test 'display'

# Documented examples.
test 'display "Hello, world!"'
test 'display (display "Hello, world!")'
test '(display "Hello, world!")'
test '() newline'
test '() display "Hello, world!"'
test 'display "Hello, world!";'
test '$sequence display "Hello, world!"'
test 'display "Hello, "; display "world!"'
test '$sequence (display "Hello, ") (display "world!")'
test '$def! x "hello"'
test 'list "hello" "world"'
test 'cons "x" ()'
test 'list "x"'
test 'cons "x" (cons "y" ())'
test 'list "x" "y"'
test '$lambda (x) display x'
test '$lambda (x) x'
test '($lambda (x) display x)'
test '($lambda (x) (display x))'
test '$lambda (x y) $sequence (display x) (display y)'
test '$def! id $lambda (x) x;'
test 'display (($lambda ((x y)) x) (list "hello" "world"))'
test '$def! car $lambda ((x .)) x; $def! cdr $lambda ((#ignore .x)) x;'
test 'eval (list display "Hello, world!") (() get-current-environment)'
test '$def! (x y) list "hello" "world"; display x; display y;'
test '$def! id $lambda (x) x;'
test '$defl! id (x) x;'
test '$def! x (); display "x is "; display ($if (null? x) "empty" "not empty");'

