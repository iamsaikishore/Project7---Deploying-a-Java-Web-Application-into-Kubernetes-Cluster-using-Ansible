<!DOCTYPE html>
<html lang="en" xml:lang="en">
  <head>
    <title>Kishq App</title>
    <style>
      /* Styles for the color boxes */
      .color-box {
        display: inline-block;
        width: 50px;
        height: 50px;
        margin-right: 10px;
        margin-bottom: 10px;
      }

      /* Color classes */
      .red {
        background-color: #ff5733;
      }

      .green {
        background-color: #00cc44;
      }

      .blue {
        background-color: #1a75ff;
      }

      .yellow {
        background-color: #ffff00;
      }

      .purple {
        background-color: #993399;
      }
    </style>
    
    <script>
      document.addEventListener("DOMContentLoaded", function() {
        var hostname = window.location.hostname;
        var hostnameElement = document.getElementById("hostname");
        hostnameElement.textContent = hostname;
      });
    </script>
    
  </head>
  <body>
    <h1> Hurrayyyyyyyyy! We have deployed the application successfully. </h1>
    <h2> Deployed By: @iamsaikishore </h2>

    <br>
    <br>
    <h2> App Status  : Up & Running !!! </h2>
    <h2> Image       : iamsaikishore/IMAGE_NAME </h2>
    <h2> Hostname    : <span id="hostname"></span> </h2>
    <br>
    <div class="color-box blue"></div>
    <div class="color-box red"></div>
    <div class="color-box green"></div>
    <div class="color-box yellow"></div>
    <div class="color-box purple"></div>

 </html>
