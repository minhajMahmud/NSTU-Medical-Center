// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

void printReceiptHtml(String htmlContent) {
  final frame = html.IFrameElement()
    ..style.position = 'fixed'
    ..style.right = '0'
    ..style.bottom = '0'
    ..style.width = '0'
    ..style.height = '0'
    ..style.border = '0'
    ..srcdoc = htmlContent;

  html.document.body?.append(frame);

  frame.onLoad.listen((_) {
    (frame.contentWindow as dynamic).focus();
    (frame.contentWindow as dynamic).print();
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      frame.remove();
    });
  });
}
