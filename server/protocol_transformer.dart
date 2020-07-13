import 'dart:async';

import 'dart:typed_data';

class ProtocolTransformer implements StreamTransformer<Uint8List, dynamic>
{
  @override
  Stream<String> bind(Stream<Uint8List> stream) async*{
    
    String previous = '';

    await for(var chars in stream)
    {
      previous = previous + String.fromCharCodes(chars);
      if(previous.indexOf('.') == -1)
        continue;
      else
      {
        List<String> results = previous.split('.');
        previous = results.last;
        results.removeLast();
        for(var r in results)
          yield r;
      }
    }
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return null;
  }
  
}