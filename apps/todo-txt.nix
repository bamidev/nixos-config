{
  home.file.".todo/config".text = ''
    export TODO_DIR=''${HOME:-$USERPROFILE}
    export TODO_FILE="$TODO_DIR/Documents/todo.txt"
    export DONE_FILE="$TODO_DIR/Documents/done.txt"
    export REPORT_FILE="$TODO_DIR/Documents/report.txt"
  '';
}
