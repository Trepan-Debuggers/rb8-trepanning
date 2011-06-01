# ********************************************************
# This tests that the debugger doesn't step into itself
# when the application doesn't terminate the right way.
# ********************************************************
set debug testing
catch x
catch ZeroDivisionError
info catch
catch 5
step
quit
