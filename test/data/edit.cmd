# ********************************************************
# This tests the edit command
# ********************************************************
set debug testing
# Edit using current line position.
edit
edit ../example/gcd.rb:5
# File should not exist
edit foo
# Add space to the end of 'edit'
edit 
quit
