$(document).ready(() => {
    // bind submit on the form to send message to the server
    $('#bc-form').submit(function(e) {
        e.preventDefault();

        ws.send(JSON.stringify({
            message: $('input[name=message]').val()
        }));

        $('input[name=message]').val('');
    });

    // create the websocket
    var hostname = window.location.hostname 
    var ws = new WebSocket("ws://"+hostname+":81/");

    // event for inbound messages to append them
    ws.onmessage = function(evt) {
        if (typeof evt.data === 'string') {
        try {
        const data = JSON.parse(evt.data);
            if(data.type === "playaudio"){
                
                var SFXLocation = "/audio/" + data.data
                let audio = new Audio(SFXLocation);
                audio.play()
                console.log('Parsed JSON:', SFXLocation);
            }
        console.log('Parsed JSON:', data);
        } catch (e) {
        console.error('Error parsing JSON:', e);
        // Handle non-JSON text message
        }
    }
  // ... handle binary data
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
});