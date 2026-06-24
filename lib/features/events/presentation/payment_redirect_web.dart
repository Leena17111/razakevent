import 'dart:html' as html;

void redirectToBrowseEvents() {
  html.window.location.replace('${html.window.location.origin}/#/events/browse');
}
