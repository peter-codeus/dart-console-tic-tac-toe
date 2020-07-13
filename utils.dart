import 'dart:io';

int choiceValidator({min: int, max:int })
{
  int choice;
  while (true) {
      try {
        stdout.write('Make Valid Choice [$min - $max]:: ');
        choice = int.parse(stdin.readLineSync());
        if (choice < min || choice > max) throw Exception('Not in Range');
        break;
      } on Exception{
        // print(e);
        continue;
      }
    }
    return choice;
}