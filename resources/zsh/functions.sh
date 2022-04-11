# Define Utility functions for zsh


#######################################
# Set the terminal application (from where this function is invoked) window title, to the given value.
# Arguments:
#   Window Title to set, an alphanumeric string
#######################################
function set-title() {
  echo "\033]0;${1}\007\c"
}
