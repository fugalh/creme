#! /bin/sh
cd `dirname $0`/..
export PATH="$PATH:bin"
# -w because growlnotify sometimes faileth otherwise
# different -n because don't want to interfere with attention-getter settings
# by user for notifications. 
(ruby -Ilib bin/creme $1 || echo fail) | \
    growlnotify --image applet.icns -n 'creme pid' -w
