async function updateTagFromJson() {
  try {
    // 1. Fetch data from your JSON endpoint
    var url = "http://" + window.location.hostname + "/api/arena/FullScreenDisplay";

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

    const RedAuto = data.RedAuto;
    const BlueAuto = data.BlueAuto;
    
    const RedTele = data.RedTele;
    const BlueTele = data.BlueTele;

    const RedEnd = data.RedEnd;
    const BlueEnd = data.BlueEnd;

    const RedAutoL1 = data.RedAutoL1;
    const BlueAutoL1 = data.BlueAutoL1;

    const RedTeleL1 = data.RedTeleL1;
    const BlueTeleL1 = data.RedTeleL1;
    const RedTeleL2 = data.RedTeleL2;
    const BlueTeleL2 = data.RedTeleL2;
    const RedTeleL3 = data.RedTeleL3;
    const BlueTeleL3 = data.RedTeleL3;

    const RedMinorFoul = data.RedMinorFoul;
    const RedMajorFoul = data.RedMajorFoul;
    const BlueMinorFoul = data.BlueMinorFoul;
    const BlueMajorFoul = data.BlueMajorFoul;
 const MatchID = data.matchID;
    const pausetime = 3;
    const autostop = 20;

      let Matchtime = data.matchtimer;
    

    const totalmatchtime = 160;


    // 3.calculate the remaning time
    let TimerMin = Math.floor((totalmatchtime - Matchtime)/60);
    let timersec = (totalmatchtime - Matchtime) % 60; 
  

  // Use padStart to add a leading zero if the number is less than 10
  const formattedMinutes = String(TimerMin).padStart(1, '0');
  const formattedSeconds = String(timersec).padStart(2, '0');

  const timerstring =  `${formattedMinutes}:${formattedSeconds}`;
  



    // 4. Replace the text in the HTML tag
    document.getElementById('BluePointCount').innerText = BluenewValue;
    document.getElementById('RedPointCount').innerText = RednewValue;
    document.getElementById('Blue1').innerText = B1;
    document.getElementById('Blue2').innerText = B2;
    document.getElementById('Blue3').innerText = B3;
    document.getElementById('Red1').innerText = R1;
    document.getElementById('Red2').innerText = R2;
    document.getElementById('Red3').innerText = R3;
    document.getElementById('TimerValue').innerText = timerstring;

    document.getElementById('RedAutoFuel').innerText = RedAuto;
    document.getElementById('BlueAutoFuel').innerText = BlueAuto;
    
    document.getElementById('RedAutoTower').innerText = RedAutoL1 *15;
    document.getElementById('BlueAutoTower').innerText = BlueAutoL1 * 15;

    document.getElementById('RedTeleoFuel').innerText  = RedTele+RedEnd;
    document.getElementById('BlueTeleoFuel').innerText = BlueTele+BlueEnd;

    document.getElementById('RedTeleopTower').innerText = (RedTeleL1 *10)+ (RedTeleL2*20) +(RedTeleL3 * 30);
    document.getElementById('BlueTeleopTower').innerText =(BlueTeleL1*10) + (BlueTeleL2*20)+(BlueTeleL3*30);

    document.getElementById('RedFoulPoint').innerText = (RedMinorFoul*5)+(RedMajorFoul*15);
    document.getElementById('BlueFoulPoint').innerText =(BlueMinorFoul*5)+(BlueMajorFoul*15);

// 4.5 check if match ID is 0 if it is then rename Practice to Test
    let Topstring = "ERROR In MatchID Check"
    if(MatchID == 0){
       Topstring = "Test Match"

    }else{
       Topstring = "Practice Match " + MatchID + " of 42" //hardcode match of data


    }document.getElementById('centerTBText').innerText = Topstring
  } catch (error) {
    console.error('Update failed:', error);
  }
}
async function shifttimers(){
  try{
 // 1. Fetch data from your JSON endpoint
    var url = "http://" + window.location.hostname + "/api/arena/shifttiming";

    const response = await fetch(url);
    const data = await response.json();

    let CurrntShift = data.currentshift;
    let Shift1Hub = data.shift1;
    let Shift2Hub = data.shift2;
    let Shift3Hub = data.shift3;
    let Shift4Hub = data.shift4;

    if(CurrntShift == "Auto"){
        document.getElementById('BlueArrowContainer').style.visibility = 'visible';
        document.getElementById('RedArrowContainer').style.visibility = 'visible';
   
    }
    else if(CurrntShift == "shift1"){
      if(Shift1Hub == "red"){
        document.getElementById('BlueArrowContainer').style.visibility = 'hidden';
        document.getElementById('RedArrowContainer').style.visibility = 'visible';
      }
      if(Shift1Hub == "blue"){
        document.getElementById('BlueArrowContainer').style.visibility = 'visible';
        document.getElementById('RedArrowContainer').style.visibility = 'hidden';
      }

    }
    else if(CurrntShift == "shift2"){
      if(Shift2Hub == "red"){
        document.getElementById('BlueArrowContainer').style.visibility = 'hidden';
        document.getElementById('RedArrowContainer').style.visibility = 'visible';
      }
      if(Shift2Hub == "blue"){
        document.getElementById('BlueArrowContainer').style.visibility = 'visible';
        document.getElementById('RedArrowContainer').style.visibility = 'hidden';
      }

    }
    else if(CurrntShift == "shift3"){
        if(Shift3Hub == "red"){
        document.getElementById('BlueArrowContainer').style.visibility = 'hidden';
        document.getElementById('RedArrowContainer').style.visibility = 'visible';
      }
      if(Shift3Hub == "blue"){
        document.getElementById('BlueArrowContainer').style.visibility = 'visible';
        document.getElementById('RedArrowContainer').style.visibility = 'hidden';
      }
    }
    else if(CurrntShift == "shift4"){
      if(Shift4Hub == "red"){
        document.getElementById('BlueArrowContainer').style.visibility = 'hidden';
        document.getElementById('RedArrowContainer').style.visibility = 'visible';
      }
      if(Shift4Hub == "blue"){
        document.getElementById('BlueArrowContainer').style.visibility = 'visible';
        document.getElementById('RedArrowContainer').style.visibility = 'hidden';
      }

    }else if(CurrntShift == "endgame"){
        document.getElementById('BlueArrowContainer').style.visibility = 'visible';
        document.getElementById('RedArrowContainer').style.visibility = 'visible';
    }
    else {
        document.getElementById('BlueArrowContainer').style.visibility = 'hidden';
        document.getElementById('RedArrowContainer').style.visibility = 'hidden';
    }


  }catch (error) {
    console.error('Shift Update failed:', error);
  }
}

// 4. Run immediately, then every 500ms (.5 seconds)
updateTagFromJson(); 
shifttimers();
setInterval(updateTagFromJson, 500);
setInterval(shifttimers, 1000);