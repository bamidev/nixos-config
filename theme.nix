# Source: https://user-images.githubusercontent.com/58662350/213884044-fdd95ba6-d75c-4983-8297-f5b39d794027.png

rec {
  foreground = "#e2cca9";
  background = "#141617";

  bg = {
    black = "#1d2021";
    blue = dark.blue;
    cyan = "#2e3b3b";
    green = "#32361a";
    magenta = "#333e34";
    red = "#3c1f1e";
    white = "#504945";
    yellow = "#473c29";
  };
  dim = {
    blue = "#374141";
    red = "#4c3432";
  };
  dark = {
    blue = "#0e363e";
  };
  bright = {
    black = "#928374";
    blue = "#80aa9e";
    cyan = "#8bba7f";
    green = "#b0b846";
    magenta = "#d3869b";
    red = "#f2584b";
    white = foreground;
    yellow = "#e9b143";
  };
  normal = {
    black = "#7c6f64";
    blue = "#80aa9e";
    cyan = "#8bba7f";
    green = "#b0b846";
    magenta = "#d3869b";
    red = "#db4740";
    white = foreground;
    yellow = "#e9b143";
  };
}
