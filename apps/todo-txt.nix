{
  home.file.".todo/config".text = ''
    export TODO_DIR=$${HOME:-$USERPROFILE}
    export TODO_FILE="$TODO_DIR/todo.txt"
    export DONE_FILE="$TODO_DIR/done.txt"
    export REPORT_FILE="$TODO_DIR/report.txt"
  '';
}
