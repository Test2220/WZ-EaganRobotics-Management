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
    }
});