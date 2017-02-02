var app = Elm.Main.fullscreen();

app.ports.fileRequest.subscribe(function (id) {
  var node = document.getElementById(id);
  if (node === null) {
    return;
  }

  var form = new FormData();
  form.append('filename', 'course.txt');
  form.append('course.txt', node[0].files[0]);

  var request = new XMLHttpRequest();
  request.open('POST', '/api/login/file/', false);
  request.onreadystatechange = function() {
    if(this.readyState == XMLHttpRequest.DONE && this.status == 200) {
      // http://stackoverflow.com/questions/7885096/how-do-i-decode-a-string-with-escaped-unicode
      var decoded = unescape(JSON.parse('"' + this.responseText.replace(/\"/g, '\\"') + '"'));
      app.ports.fileResponse.send(decoded);
    }
  };
  request.send(form);
});