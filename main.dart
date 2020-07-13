import 'dart:io';
import 'gui_utils.dart';

void main() {
  handle();
}

void handle() async {
  while (true) {
    switch (GuiUtils.main_menu()) {
      case 1:
        await GuiUtils.twoPlayersLocal(computer: true);
        break;
      case 2:
        await GuiUtils.twoPlayersLocal();
        break;
      case 3:
        await GuiUtils.twoPlayersOnline();
        break;
      case 4:
        GuiUtils.instructions();
        break;
      case 5:
        if (GuiUtils.exit_app()) exit(0);
    }
  }
}
