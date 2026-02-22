    function sendscore (ELT){

    // Creating a XHR object
    let xhr = new XMLHttpRequest();
    let url = "/api/arena/scorekeeper";

    // open a connection
    xhr.open("POST", url, true);

    // Set the request header i.e. which type of content you are sending
    xhr.setRequestHeader("Content-Type", "application/json");


    // Converting JSON data to string

        var data = JSON.stringify({ "element": ELT });
        

    

    // Sending data with the request
    xhr.send(data);
}    function sendpointred (ELT){

    // Creating a XHR object
    let xhr = new XMLHttpRequest();
    

      let url = "/api/arena/points/red/1";
    
    // open a connection
    xhr.open("POST", url, true);
    // Set the request header i.e. which type of content you are sending
    xhr.setRequestHeader("Content-Type", "application/json");
    // Converting JSON data to string
        var data = JSON.stringify({ "element": ELT });
    // Sending data with the request
    xhr.send(data);
}function sendpointblue (ELT){

    // Creating a XHR object
    let xhr = new XMLHttpRequest();

      let url = "/api/arena/points/blue/1";
    // open a connection
    xhr.open("POST", url, true);
    // Set the request header i.e. which type of content you are sending
    xhr.setRequestHeader("Content-Type", "application/json");
    // Converting JSON data to string
        var data = JSON.stringify({ "element": ELT });
    // Sending data with the request
    xhr.send(data);
}
function PlaySound (ELT){

    // Creating a XHR object
    let xhr = new XMLHttpRequest();
    let url = "/api/arena/test/playSound";
    var SoundPayload = ELT +".wav"

    // open a connection
    xhr.open("POST", url, true);

    // Set the request header i.e. which type of content you are sending
    xhr.setRequestHeader("Content-Type", "application/json");


    // Converting JSON data to string

        var data = JSON.stringify({ "sound": SoundPayload });
        

    

    // Sending data with the request
    xhr.send(data);
}function TestMode (ELT){

    // Creating a XHR object
    let xhr = new XMLHttpRequest();
    let url = "/api/arena/test";

    // open a connection
    xhr.open("POST", url, true);

    // Set the request header i.e. which type of content you are sending
    xhr.setRequestHeader("Content-Type", "application/json");


    // Converting JSON data to string

        var data = JSON.stringify({ "value": ELT });
        

    

    // Sending data with the request
    xhr.send(data);
}

var getJSON = function(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
    xhr.responseType = 'json';
    xhr.onload = function() {
      var status = xhr.status;
      if (status === 200) {
        callback(null, xhr.response);
      } else {
        callback(status, xhr.response);
      }
    };
    xhr.send();
    updateTagFromJson(); 
};


// 4. Run immediately, then every 1000ms (1 seconds)
updateTagFromJson(); 
setInterval(updateTagFromJson, 1000);