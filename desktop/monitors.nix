rec {
  all = [ laptop ] ++ pluggables;

  laptop = {
    id = "eDP-1";
    idSource = "id";
    position = {
      x = 2000;
      y = 2000;
    };
  };

  pluggables = [
    {
      id = "Ancor Communications Inc ASUS PB278 D1LMTF019074";
      idSource = "description";
      position = {
        x = 1680;
        y = 560;
      };
    }
    {
      id = "BNQ BenQ GW3290QT H9P00939019";
      idSource = "description";
      position = {
        x = 1680;
        y = 560;
      };
    }
    {
      id = "Eizo Nanao Corporation S2402W 68610031";
      idSource = "description";
      position = {
        x = 2000;
        y = 800;
      };
    }
    {
      id = "Philips Consumer Electronics Company PHL 241P6Q UHB1609027039";
      idSource = "description";
      position = {
        x = 2000;
        y = 920;
      };
    }
  ];
}
