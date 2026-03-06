    function PlaylistChange (ELT){

    // Creating a XHR object
    let xhr = new XMLHttpRequest();
    let url = "./music/change-song";

    // open a connection
    xhr.open("POST", url, true);

    // Set the request header i.e. which type of content you are sending
    xhr.setRequestHeader("Content-Type", "application/json");


    // Converting JSON data to string
    if (ELT =="CrowdRally") {

        selectElement = document.querySelector('#SongChoice');
        var SongID = selectElement.value;
        var data = JSON.stringify({ "Player": ELT, "Crowdrallysong": SongID });
    } else {
        var data = JSON.stringify({ "Player": ELT });
        
    }
    

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
};
