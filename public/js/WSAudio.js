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
    var ws = new WebSocket("ws://localhost:80/");

    // event for inbound messages to append them
    ws.onmessage = function(evt) {
        $('#messages').append(`<p>${evt.data}</p>`);
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
});