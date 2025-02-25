import 'package:mason/mason.dart';

final signatureOne = '''
  ███╗   ██╗ ██████╗ ███╗   ██╗███████╗████████╗ ██████╗ ██████╗ 
  ████╗  ██║██╔═══██╗████╗  ██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
  ██╔██╗ ██║██║   ██║██╔██╗ ██║███████╗   ██║   ██║   ██║██████╔╝
  ██║╚██╗██║██║   ██║██║╚██╗██║╚════██║   ██║   ██║   ██║██╔═══╝ 
  ██║ ╚████║╚██████╔╝██║ ╚████║███████║   ██║   ╚██████╔╝██║     
  ╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
   ██████╗██╗     ██╗                                             
  ██╔════╝██║     ██║                                             
  ██║     ██║     ██║                                             
  ██║     ██║     ██║                                             
  ╚██████╗███████╗██║                                             
   ╚═════╝╚══════╝╚═╝ 
   ''';

final signatureTwo = '''
┌───┬───┬───┬───┬───┬───┬───┐ ┌───┬───┬───┐
│ N │ o │ n │ S │ t │ o │ p │ │ C │ L │ I │
└─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┘ └─┬─┴─┬─┴─┬─┘
  │   │   │   │   │   │   │     │   │   │''';

final signatureThree = '''
 +-+-+-+-+-+-+-+ +-+-+-+
 |N|o|n|S|t|o|p| |C|L|I|
 +-+-+-+-+-+-+-+ +-+-+-+
''';

final signatureFour = '''
╭──────────╮ ╭───╮
│ NonStop  │-│CLI│
╰──────────╯ ╰───╯''';

final signatureFive = '''
╔═╦═╦═╦═╦═╦═╦═╗
║N║o║n║S║t║o║p║
╠═╬═╬═╬═╬═╬═╬═╣
║C║L║I║ ║ ║ ║ ║
╚═╩═╩═╩═╩═╩═╩═╝''';

extension SignatureExtension on Logger {
  void logSignature() {
    List<String> signatures = [
      signatureOne,
      signatureTwo,
      signatureThree,
      signatureFour,
      signatureFive,
    ];

    String pickRandom() {
      return signatures[DateTime.now().microsecond % signatures.length];
    }

    info('');
    info(green.wrap(pickRandom()));
    info('');
  }
}
