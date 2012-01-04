GetConfirm() {
  echoex -cyan
  if [ -n "$1" ]; then
    echo "$@"
  else
    echo "are you sure?"
  fi
  echo -n "['y' or 'yes' for confirm, any other word for no]"
  echoex -reset
  local x=
  read x
  case $x in
    [yY] | [yY][eE][sS])
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
