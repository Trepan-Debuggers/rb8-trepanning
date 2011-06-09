# ********************************************************
# This tests mostly invalid breakpoints.
# We have some valid ones too.
# ********************************************************
set debug testing
set callstyle last
set autoeval off
set basename on
break ../example/gcd.rb:6
continue
pr a 
eval [a,b]
continue
eval [a,b]
up
eval [a,b]
q!
