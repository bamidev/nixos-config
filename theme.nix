# Source: https://user-images.githubusercontent.com/58662350/213884044-fdd95ba6-d75c-4983-8297-f5b39d794027.png
# Gruvbox Material, mix hard dark variant

rec {
  background = dark.black;
  foreground = normal.white;

  bg = {
    black = dark.black;
    blue = dark.blue;
    green = dark.green;
    red = dark.red;
    white = dark.white;
    yellow = dark.yellow;
  };
  dim = {
    black = "3c3836";
    blue = "2e3b3b";
    green = "333e34";
    red = "442e2d";
    white = "a89984";
    yellow = dark.yellow;
  };
  dark = {
    black = "141617";
    blue = "0d3138";
    green = "32361a";
    red = "3c1f1e";
    white = "a89984";
    yellow = "4f442e";
  };
  bright = {
    black = "282828";
    blue = normal.blue;
    cyan = normal.cyan;
    green = normal.green;
    magenta = normal.magenta;
    red = "f2594b";
    white = normal.white;
    yellow = normal.yellow;
  };
  normal = {
    black = "1d2021";
    blue = "80aa9e";
    cyan = "8bba7f";
    green = "b0b846";
    magenta = "d3869b";
    red = "db4740";
    white = "e2cca9";
    yellow = "e9b143";
  };
}
