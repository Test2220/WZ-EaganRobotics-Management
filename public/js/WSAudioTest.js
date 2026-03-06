function connect() {
    var url =  "ws://"+window.location.hostname+":81/"
  var ws = new WebSocket(url);
  ws.onopen = function() {
    // subscribe to some channels
    ws.send(JSON.stringify({
        //.... some message the I must send when I connect ....
    }));
  };

  ws.onmessage = function(evt) {
            if (typeof evt.data === 'string') {
        try {
        const data = JSON.parse(evt.data);
            if(data.type === "playaudio"){
                var SFXLocation = "/audio/" + data.data;
                let audio = new Audio(SFXLocation);
                audio.play();
                console.log('Parsed JSON:', SFXLocation);
            }
        console.log('Parsed JSON:', data);
        } catch (e) {
        console.error('Error parsing JSON:', e);
        // Handle non-JSON text message
        }
    }
  };

  ws.onclose = function(e) {
    console.log('Socket is closed. Reconnect will be attempted in 1 second.', e.reason);
    setTimeout(function() {
      connect();
    }, 1000);
  };

  ws.onerror = function(err) {
    console.error('Socket encountered error: ', err.message, 'Closing socket');
    ws.close();
  };
}

connect();