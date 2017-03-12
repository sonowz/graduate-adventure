// Interface for Elm that handles HTTP form request & intercepts response
// Elm 0.18 does not support 'file input request' in native.
var elmApp = Elm.Main.fullscreen();

elmApp.ports.fileRequest.subscribe(function (param) {
  var split = param.split('@');
  var id = split[0];
  var url = split[1];

  var formNode = document.getElementById(id);
  if (formNode == null)
    return;

  var form = new FormData();
  for(var i = 0; formNode[i] != null;  i++) {
    var item = formNode[i];
    if(item.name == '')
      continue;
    if(item.type == 'file')
      form.append(item.name, item.files[0]);
    else
      form.append(item.name, item. value);
  }

  var request = new XMLHttpRequest();
  request.open('POST', url, false);
  request.onreadystatechange = function() {
    if(this.readyState == XMLHttpRequest.DONE && this.status == 200) {
      // http://stackoverflow.com/questions/7885096/how-do-i-decode-a-string-with-escaped-unicode
      var decoded = unescape(JSON.parse('"' + this.responseText.replace(/\"/g, '\\"') + '"'));
      elmApp.ports.fileResponse.send(decoded);
    }
  };
  request.send(form);
});
