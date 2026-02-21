async function updateTagFromJson() {
  try {
    // 1. Fetch data from your JSON endpoint
    var url = "http://" + window.location.hostname + "/api/arena/Stack/status";

    const response = await fetch(url);
    const data = await response.json();

    // 2. Access the specific value you need  	
const redTotal = data.redTotal
const blueTotal = data.bluetotal	
const blueFuel = data.blueFuel
const redFuel = data.RedFuel

const redAutol1 = data.redAutoL1
const redTeleL1 = data.redTeleL1
const redTeleL2 = data.redTeleL2
const redTeleL3 = data.redTeleL3	

const BlueAutoL1 = data.BlueAutoL1
const BlueTeleL1 = data.BlueTeleL1
const BlueTeleL2 = data.BlueTeleL2
const BlueTeleL3 = data.BlueTeleL3

const redMinorFoul = data.redMinorFoul
const blueMinorFoul = data.blueMinorFoul

const redMajorFoul = data.redMajorFoul
const blueMajorFoul = data.blueMajorFoul
const arenaState = data.mode



    // 4. Replace the text in the HTML tag
    document.getElementById('redAutoL1Score').innerText = redAutol1*15;
    document.getElementById('blueautoL1Score').innerText = BlueAutoL1*15;
    
    document.getElementById('redAutoL1Value').innerText = redAutol1;
    document.getElementById('blueautoL1Value').innerText = BlueAutoL1;

    document.getElementById('REDTeleL1Score').innerText = redTeleL1*10;
    document.getElementById('blueTeleL1Score').innerText = BlueTeleL1*10;
    
    document.getElementById('REDTeleL1Value').innerText = redTeleL1;
    document.getElementById('blueTeleL1Value').innerText = BlueTeleL1;

    document.getElementById('REDTeleL2Score').innerText = redTeleL2*20;
    document.getElementById('blueTeleL2Score').innerText = BlueTeleL2*20;
    
    document.getElementById('REDTeleL2Value').innerText = redTeleL2;
    document.getElementById('blueTeleL2Value').innerText = BlueTeleL2;

    document.getElementById('REDTeleL3Score').innerText = redTeleL3*30;
    document.getElementById('blueTeleL3Score').innerText = BlueTeleL3*30;
    
    document.getElementById('REDTeleL3Value').innerText = redTeleL3;
    document.getElementById('blueTeleL3Value').innerText = BlueTeleL3;

    document.getElementById('REDFuelScore').innerText = redFuel;
    document.getElementById('blueFuelScore').innerText = blueFuel;
    
    document.getElementById('REDtotalScore').innerText = redTotal;
    document.getElementById('blueTotalScore').innerText = blueTotal;

    document.getElementById('redFoulValue').innerText = redMinorFoul;
    document.getElementById('blueFoulvalue').innerText = blueMinorFoul;
    document.getElementById('blueFoulScore').innerText = redMinorFoul * 5;
    document.getElementById('redFoulScore').innerText = blueMinorFoul *5;

    document.getElementById('redTFoulValue').innerText = redMajorFoul;
    document.getElementById('blueTFoulvalue').innerText = blueMajorFoul;
    document.getElementById('blueTFoulScore').innerText = redMajorFoul * 5;
    document.getElementById('redTFoulScore').innerText = blueMajorFoul *5;

     document.getElementById('arenaState').innerText = arenaState;
    

  } catch (error) {
    console.error('Update failed:', error);
  }
}
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