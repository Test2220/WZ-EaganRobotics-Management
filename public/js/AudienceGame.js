async function updateTagFromJson() {
  try {
    // 1. Fetch data from your JSON endpoint
    var url = "http://" + window.location.hostname + "/api/arena/AudianceDisplay";

    const response = await fetch(url);
    const data = await response.json();

    // 2. Access the specific value you need
    const BluenewValue = data.bluescore;
    const RednewValue = data.redscore;
    const R1 = data.r1;
    const R2 = data.r2;
    const R3 = data.r3;
    
    const B1 = data.b1;
    const B2 = data.b2;
    const B3 = data.b3;

    const Matchtime = data.matchtimer
    const totalmatchtime = 160;


    // 3.calculate the remaning time
    let TimerMin = Math.floor((totalmatchtime - Matchtime)/60);
    let timersec = (totalmatchtime - Matchtime) % 60; 
  

  // Use padStart to add a leading zero if the number is less than 10
  const formattedMinutes = String(TimerMin).padStart(1, '0');
  const formattedSeconds = String(timersec).padStart(2, '0');

  const timerstring =  `${formattedMinutes}:${formattedSeconds}`;
  



    // 4. Replace the text in the HTML tag
    document.getElementById('pointsRight').innerText = BluenewValue;
    document.getElementById('pointsLeft').innerText = RednewValue;
    document.getElementById('B1').innerText = B1;
    document.getElementById('B2').innerText = B2;
    document.getElementById('B3').innerText = B3;
    document.getElementById('R1').innerText = R1;
    document.getElementById('R2').innerText = R2;
    document.getElementById('R3').innerText = R3;
    document.getElementById('TimerContainer').innerText = timerstring;


    




  } catch (error) {
    console.error('Update failed:', error);
  }
}

// 4. Run immediately, then every 500ms (.5 seconds)
updateTagFromJson(); 
setInterval(updateTagFromJson, 500);