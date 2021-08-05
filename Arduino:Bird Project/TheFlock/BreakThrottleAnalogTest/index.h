const char MAIN_page[] PROGMEM = R"=====(
<!DOCTYPE html>
<html>
<body>
 
<div id="demo">
<h1>TheFlock</h1>
</div>
<div>
    Current Break Value: <span id="BrkValue">0</span><br>
    Max Break Value: <span id="maxBrkValue">1023</span><br>
    Min Break Value: <span id="minBrkValue">0</span><br><br>
    Current Throttle Value: <span id="ThrotValue">0</span><br>
    Max Throttle Value: <span id="maxThrotValue">1023</span><br>
    Min Throttle Value: <span id="minThrotValue">0</span><br><br>
    
</div>
<script>
 
setInterval(function() {
  // Call a function repetatively with 0.25 Second interval
  getData();
}, 250); //250mSeconds update rate
 
function getData() {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      var myArr = JSON.parse(this.responseText)
      document.getElementById("BrkValue").innerHTML = myArr[0];
      document.getElementById("ThrotValue").innerHTML = myArr[1];
      document.getElementById("maxBrkValue").innerHTML = myArr[2];
      document.getElementById("minBrkValue").innerHTML = myArr[3];
      document.getElementById("maxThrotValue").innerHTML = myArr[4];
      document.getElementById("minThrotValue").innerHTML = myArr[5];
    }
  };
  xhttp.open("GET", "readADC", true);
  xhttp.send();
}
</script>
</body>
</html>
)=====";
