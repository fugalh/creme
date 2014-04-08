#! /bin/sh
# I don't know why ruby 2 doesn't work right. I get an error in fork and popen
# when I already close stdout, but if I don't then the subshell hangs.
ruby=/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby
cd `dirname $0`/..
export PATH="$PATH:bin"
msg=$($ruby -Ilib bin/creme "$@" || echo fail)
echo display notification \"$msg\" with title \"Crème Rappel\" | exec osascript
