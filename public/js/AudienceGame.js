async function updateTagFromJson() {
  try {
    // 1. Fetch data from your JSON endpoint
    var url = "http://" + window.location.hostname + "/api/arena/AudianceDisplay";

    const response = await fetch(url);
    const data = await response.json();

    // 2. Access the specific value you need
    const BluenewValue = data.bluescore;
    const RednewValue = data.redscore;

    // 3. Replace the text in the HTML tag
    document.getElementById('pointsRight').innerText = BluenewValue;;
    document.getElementById('pointsLeft').innerText = RednewValue;
  } catch (error) {
    console.error('Update failed:', error);
  }
}

// 4. Run immediately, then every 500ms (.5 seconds)
updateTagFromJson(); 
setInterval(updateTagFromJson, 500);