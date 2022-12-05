<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css"
	rel="stylesheet"
	integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC"
	crossorigin="anonymous">
<script
	src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
	integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
	crossorigin="anonymous"></script>
</head>
<body style="margin-top: 50px">

	<div class="container">
		<!-- name -->
		<div style="margin-bottom: 20px">
			<label style="margin-right: 20px" for="">Name stream:</label> <input
				id="name-stream" type="text" />
			<p id="mess-err" style="color: red" for=""></p>
		</div>

		<!-- checkbox Record-->
		<p class="video-form-item">
			<label for="enable-record-field">Enable Recording:</label> <input
				type="checkbox" name="enable-record-field" id="enable-record-field"></input>
		</p>

		<!-- select cam -->
    <div id="camera-select-block">
      <label for="">Choose Camera: </label>
      <select name="camera-select" id="camera-select-field">
        <option value="123">Demo</option>
      </select> <br>
    </div>
  


		<div class="row">
			<div class="col-lg-6 col-md-12">
				<!-- bitrate -->
				<div id="statistics-field" class="statistics-field text-center"
					style="height: 30px; color: red"></div>

				<div id="video-container">
					<video style="width: 100%;height:auto" id="red5pro-publisher" autoplay playsinline controls></video>
				</div>

				<div id="btn-start-stop" style="margin-top: 20px">
					<button class="btn btn-primary" onclick="startStream()">Start Stream</button>
				</div>
			</div>
			<div class="col-lg-6 col-md-12" >
				<h4  class="text-center" style="color: blue; margin-top: 20px">Event log:</h4>
        <div class="text-center">
          <button class="btn btn-warning"  onclick="clearLog()">Clear</button>
        </div>
			

				<div class="text-center" id="event-log" style="color: blue; margin-top: 20px">
					<!-- div  log -->
				</div>
			</div>
		</div>



	</div>

</body>

<!-- WebRTC Shim -->
<script src="https://webrtc.github.io/adapter/adapter-latest.js"></script>
<!-- Exposes `red5prosdk` on the window global. -->
<script src="https://cdn.jsdelivr.net/npm/red5pro-webrtc-sdk"></script>

<script type="text/javascript">

    //tạo biến rtcPublisher
    var rtcPublisher = new red5prosdk.RTCPublisher();

                let video = document.getElementById("red5pro-publisher");

                 // Config select camera
                  let cameraSelect = document.getElementById('camera-select-field');

                  function enableCameraSelect(devices) {
                    var currentValue = cameraSelect.value;
                    while (cameraSelect.firstChild) {
                      cameraSelect.removeChild(cameraSelect.firstChild);
                    }
                    var videoCameras = devices.filter(function (item) {
                      return item.kind === 'videoinput';
                    });
                    var i, length = videoCameras.length;
                    var camera, option;
                    for (i = 0; i < length; i++) {
                      camera = videoCameras[i];
                      option = document.createElement('option');
                      option.value = camera.deviceId;
                      option.text = camera.label || 'camera ' + i;
                      cameraSelect.appendChild(option);
                      if (camera.deviceId === currentValue) {
                        cameraSelect.value = camera.deviceId;
                      }
                    }
                  }

                  //End config select camera
                  var host = window.location.host.split(":")[0];
                  var config = {
                    protocol: 'ws',
                    host: host,
                    port: 5080,
                    app: 'livedemo',
                    rtcConfiguration: {
                      iceServers: [{ urls: 'stun:stun2.l.google.com:19302' }],
                      iceCandidatePoolSize: 2,
                      bundlePolicy: 'max-bundle'
                    },
                    mediaConstraints: {
                      video: true,
                      audio: true
                    }
                    // See https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection#RTCConfiguration_dictionary
                  };

                  function getUserMedia() {
                    if (rtcPublisher && rtcPublisher.getMediaStream()) {
                      var stream = rtcPublisher.getMediaStream();
                      stream.getTracks().forEach(function (track) {
                        track.stop();
                      });
                    }
                    var stream;
                    return navigator.mediaDevices.getUserMedia(config.mediaConstraints)
                      .then(function (mediastream) {
                        stream = mediastream
                        // Hiển thị ra video
                        video.srcObject = stream;

                        // Trả về list divices ở dưới then tiếp theo
                        return navigator.mediaDevices.enumerateDevices()
                      })
                      .then(function (devices) {
                        enableCameraSelect(devices);
                        stream.getVideoTracks().forEach(function (track) {
                          cameraSelect.value = track.getSettings().deviceId;
                        });

                      })
                      .catch(function (error) {
                        console.log(error);
                      }
                      );
                  }

                  getUserMedia();
                  // Khúc này là xử lý chuyển đổi các camera
                  cameraSelect.addEventListener('change', function () {
                    // onCameraSelect(cameraSelect.value, true);
                    config.mediaConstraints.video = { deviceId: { exact: cameraSelect.value } };
                    getUserMedia();
                  });

    //start publisher
    async function startStream() {
      var nameStream = document.getElementById("name-stream").value;
      if (nameStream === "" || !nameStream.trim()) {
        document.getElementById("mess-err").innerText =
          "Please enter your name!!! ";
      } else {
        document.getElementById("mess-err").innerText = "";
 
        var mode =  document.getElementById("enable-record-field").checked ? 'record' : 'live';
        try {
          await rtcPublisher.init({
            ...config,
            streamMode: mode,
            streamName: nameStream,
          }
          );

          await rtcPublisher.publish();

      
          //toggle button
          document.getElementById("btn-start-stop").innerHTML = `
          <button class="btn btn-danger" onclick="stopStream()">Stop Stream</button>
          `;

          //hide came
          document.getElementById("camera-select-block").style.display = "none";
		  
		  
          //set bitrate
          setBitrateUpdate(rtcPublisher);

          //log event
          rtcPublisher.on("*", onPublisherEvent);

          console.log(`Publishing with stream name: \${nameStream}`);

        } catch (error) {
          console.error("Could not publish: " + JSON.stringify(error));
          rtcPublisher.on("*", onPublisherEvent);
        }
      }
    }

    //stop stream
    async function stopStream() {
      try {
        await rtcPublisher.unpublish();

        rtcPublisher.off("*", onPublisherEvent);
        // await rtcPublisher.unpreview();  
        document.getElementById("btn-start-stop").innerHTML = `
          <button class="btn btn-primary" onclick="startStream()">Start Stream</button>
          `;
        document.getElementById("name-stream").value = "";
        document.getElementById('statistics-field').innerText = '';

         //show came
         document.getElementById("camera-select-block").style.display = "block";

        console.log("Stopped publisher stream!");
      } catch (error) {
        console.log("Failed to stop publisher stream!");
        rtcPublisher.off("*", onPublisherEvent);
      }
    }

    //render event log
    function onPublisherEvent(event) {
      var eventLog = "[Red5ProPublisher] " + event.type + ".";

      document.getElementById("event-log").innerHTML += `
            <p> \${eventLog}
              </p>
          `;
          }
      //set bitrate
       function setBitrateUpdate(publisher) {
    
        var isRTC = publisher.getType().toLowerCase() === 'rtc';
        if (isRTC) {
           window.trackBitrate(publisher.getPeerConnection(), onBitrateUpdate);
        }

    }

      // render bitrate
      function onBitrateUpdate(bitrate, packets) {
       
         document.getElementById('statistics-field').innerText =
          "Bitrate: " +
          (bitrate === 0 ? "N/A" : Math.floor(bitrate)) +
          ".   Packets Sent: " +
          packets +
          ".";
      }
    
    //clear log
    function clearLog() {
      document.getElementById("event-log").innerHTML = "";
    }


    window.untrackBitrate = function () {
          clearInterval(bitrateInterval);
        }
        var bitrateInterval = 0;
        var vRegex = /VideoStream/;
        var aRegex = /AudioStream/;

        window.trackBitrate = function (connection, cb, resolutionCb) {
          window.untrackBitrate(cb);
          //    var lastResult;
          var lastOutboundVideoResult;
          var lastInboundVideoResult;
          var lastInboundAudioResult;

          bitrateInterval = setInterval(function () {
            connection.getStats(null).then(function (res) {

              res.forEach(function (report) {

                var bytes;
                var packets;
                var now = report.timestamp;
                if ((report.type === 'outboundrtp') ||
                  (report.type === 'outbound-rtp') ||
                  (report.type === 'ssrc' && report.bytesSent)) {
                  bytes = report.bytesSent;
                  packets = report.packetsSent;
                  if ((report.mediaType === 'video' || report.id.match(vRegex))) {
                    if (lastOutboundVideoResult && lastOutboundVideoResult.get(report.id)) {
                      // calculate bitrate
                      var bitrate = 8 * (bytes - lastOutboundVideoResult.get(report.id).bytesSent) /
                        (now - lastOutboundVideoResult.get(report.id).timestamp);

                      cb(bitrate, packets);

                    }
                    lastOutboundVideoResult = res;
                  }
                }
                // playback.
                else if ((report.type === 'inboundrtp') ||
                  (report.type === 'inbound-rtp') ||
                  (report.type === 'ssrc' && report.bytesReceived)) {
                  bytes = report.bytesReceived;
                  packets = report.packetsReceived;
                  if ((report.mediaType === 'video' || report.id.match(vRegex))) {
                    if (lastInboundVideoResult && lastInboundVideoResult.get(report.id)) {
                      // calculate bitrate
                      bitrate = 8 * (bytes - lastInboundVideoResult.get(report.id).bytesReceived) /
                        (now - lastInboundVideoResult.get(report.id).timestamp);

                      cb('video', report, bitrate, packets - lastInboundVideoResult.get(report.id).packetsReceived);
                    }
                    lastInboundVideoResult = res;
                  }
                  else if ((report.mediaType === 'audio' || report.id.match(aRegex))) {
                    if (lastInboundAudioResult && lastInboundAudioResult.get(report.id)) {
                      // calculate bitrate
                      bitrate = 8 * (bytes - lastInboundAudioResult.get(report.id).bytesReceived) /
                        (now - lastInboundAudioResult.get(report.id).timestamp);

                      cb('audio', report, bitrate, packets - lastInboundAudioResult.get(report.id).packetsReceived);
                    }
                    lastInboundAudioResult = res;
                  }
                }
                else if (resolutionCb && report.type === 'track') {
                  var fw = 0;
                  var fh = 0;
                  if (report.kind === 'video' ||
                    (report.frameWidth || report.frameHeight)) {
                    fw = report.frameWidth;
                    fh = report.frameHeight;
                    if (fw > 0 || fh > 0) {
                      resolutionCb(fw, fh);
                    }
                  }
                }
              });
            });
          }, 1000);
        }
  </script>
</html>