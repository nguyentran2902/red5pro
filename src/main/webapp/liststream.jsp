<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>


  <%@ page import="org.springframework.context.ApplicationContext,
                    org.springframework.web.context.WebApplicationContext,
                    com.nguyentran.livedemo.Application,
                    java.util.List
                    " %>
    <% ApplicationContext appCtx=(ApplicationContext)
      application.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE); Application
      service=(Application) appCtx.getBean("web.handler"); List<String> streamNames = service.getLiveStreams();
      StringBuffer buffer = new StringBuffer();

      if(streamNames.size() == 0) {
      buffer.append("No streams found. Refresh if needed.");
      }
      else {
      buffer.append("<ul>\n");
        for (String streamName:streamNames) {

        String onclickString = "startStream('" + streamName + "')";
        buffer.append("<li><button onClick=" + onclickString + ">" + streamName + "</button></li>\n");
        }
        buffer.append("</ul>\n");
      }

      %>

      <!doctype html>
      <html>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
        integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM"
        crossorigin="anonymous"></script>

        <style>
          ul {
            list-style: none;
          }
          ul li {
            margin-top: 10px;
          }

          ul button {
            color: white;
            background-color:  rgb(13, 79, 211);
            border: none;
            border-radius: 8px;
            padding: 4px 10px;
          }
        </style>

      <body>
        <div class="container-fluid mt-5">
          <h4 style="color: red;margin-top: 20px;">List streams:</h4>
          <%=buffer.toString()%>
        </div>
        <hr>


        <!-- bitrate -->
       

        <div class="container-fluid mt-2">
          <div class="row">

            <!-- video block -->
            <div class="col-lg-6 col-md-12 mt-3">
              <div id="bitrate-div" class="text-center" style="height: 50px;color: blue"></div>
              <div id="video-container" class="mt-1 text-center">
                <video id="red5pro-subscriber" controls autoplay></video>
              </div>
              <h4 class="text-center" style="color: blue;margin-top: 20px;">Event RTCSubscriber log:</h4>
              <div class="text-center "> <button class="btn btn-warning"  onclick="clearLog()">Clear Log</button></div>
             
              <div id="event-log" class="text-center " style="color: blue;margin-top: 20px;">
      
                <!-- div clear log -->
              </div>
      
            </div>

            <!-- report block -->
            <div class="col-lg-6 col-md-12">

              <div id="report-container" class="reports-container">

                <div id="show-hide-event" style="height: 36px;">
                  <button class="btn btn-warning" onclick="showEvent()">Show detail event livestream</button>
                </div>

                <div id="report-content" class="container" style="display: none;">
                  <div class="row" >

                    <!-- video -->
                    <div class="col-6">
                      <div class="report-field mt-2">
                        <div id="video-report_stats" class="statistics-field text-center"  style="height: 50px;color: blue"></div>
                        <div  class="report-field_header text-center" style=" background-color: rgb(211, 22, 22); color: white;height: 42px;line-height: 42px;">Video</div>
                        <div id="video-report" class="report mt-2"></div>
                      </div>
                    </div>
  
  
                    <div class="col-6">
                      <!-- audio -->
                      <div class="report-field mt-2">
                        <div id="audio-report_stats" class="statistics-field text-center"  style="height: 50px;color: blue"></div>
                        <div  class="report-field_header text-center" style=" background-color: rgb(211, 22, 22); color: white;height: 42px;line-height: 42px;">Audio</div>
                        <div id="audio-report" class="report mt-2"></div>
                      </div>
                    </div>
                  </div>
                </div>
              



              </div>
            </div>
          </div>

        </div>




       

      </body>
      <!-- WebRTC Shim -->
      <script src="https://webrtc.github.io/adapter/adapter-latest.js"></script>
      <!-- Exposes `red5prosdk` on the window global. -->
      <script src="https://cdn.jsdelivr.net/npm/red5pro-webrtc-sdk"></script>
      <script>

       function showEvent(){
        document.getElementById("report-content").style.display="block";
        document.getElementById("show-hide-event").innerHTML = ` <button class="btn btn-warning" onclick="hideEvent()">Hide event livestream</button>`
      
       }

       function hideEvent(){
        document.getElementById("report-content").style.display="none";
        document.getElementById("show-hide-event").innerHTML = ` <button  class="btn btn-warning" onclick="showEvent()">Show detail event livestream</button>`
      
       }


        async function startStream(name) {



          // Create a new instance of the WebRTC subcriber.
          var subscriber = new red5prosdk.RTCSubscriber();


          // Create a view instance based on video element id.
          var viewer = new red5prosdk.PlaybackView('red5pro-subscriber');
          // Attach the subscriber to the view.
          viewer.attachSubscriber(subscriber);

          //    var protocol = window.location.protocol;
          //    var isSecure = protocol.charAt(protocol.length - 2);

          // Using Chrome/Google TURN/STUN servers.
          var iceServers = [{ urls: 'stun:stun2.l.google.com:19302' }];

          try {
            await subscriber.init({
              protocol: 'ws',
              host: 'localhost',
              //địa chỉ local ip của máy
              // host: '10.75.0.1',
              port: 5080,
              app: 'livedemo',
              streamName: name,
              rtcConfiguration: {
                iceServers: [{ urls: 'stun:stun2.l.google.com:19302' }],
                iceCandidatePoolSize: 2,
                bundlePolicy: 'max-bundle'
              },
              
              subscriptionId: 'subscriber-' + Math.floor(Math.random() * 0x10000).toString(16),
              //        rtcpMuxPolicy: 'negotiate'
            });

            await subscriber.subscribe();

            //log bitrate video and audio
            toggleReportTracking(subscriber, true);
            
            //log event
            subscriber.on('*', onSubscribeEvent);
            console.log('Playing!');


          } catch (error) {
            console.log('Could not play: ' + error);

          }


        };

        //render event log
        function onSubscribeEvent(event) {

          var eventLog = '[Red5ProSubscribe] ' + event.type + '.';
          if (event.type !== 'Subscribe.Time.Update') {
            document.getElementById("event-log").innerHTML += `
            <p> \${eventLog}
              </p>
          `
          }
         

        }

        var bitrateInterval = 0;
        var vRegex = /VideoStream/;
        var aRegex = /AudioStream/;

        window.untrackBitrate = function () {
          clearInterval(bitrateInterval);
        }
      

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


      // set log event video and audio
        function toggleReportTracking(subscriber, turnOn) {


          var bitrateElement = document.getElementById('bitrate-div');
          if (subscriber && turnOn) {


            var $audio = document.getElementById('audio-report');
            var $video = document.getElementById('video-report');
            var $audioStats = document.getElementById('audio-report_stats');
            var $videoStats = document.getElementById('video-report_stats');
            var videoElement = document.getElementById('red5pro-subscriber');


          
            try {
              window.trackBitrate(subscriber.getPeerConnection(), function (type, report, bitrate, packetsLastSent) {

                bitrateElement.innerText = 'Bitrate: ' + parseInt(bitrate, 10) + '. ' + videoElement.videoWidth + 'x' + videoElement.videoHeight;
                videoElement.style['max-height'] = videoElement.videoHeight + 'px';

                generateReportStats(parseInt(bitrate, 10), packetsLastSent, type === 'video' ? $videoStats : $audioStats);
                Object.keys(report).forEach(function (key) {
                  generateReportBlock(key, report[key], type === 'video' ? $video : $audio);
                });
                // with &analyze.
                if (window.r5pro_ws_send) {
                  var clientId = window.adapter.browserDetails.browser + '+' + subscriptionId;
                  if (idContainer && idContainer.classList && idContainer.classList.contains('hidden')) {
                    idContainer.classList.remove('hidden');
                    idContainer.innerText = clientId
                  }
                  window.r5pro_ws_send(clientId, type, 'bitrate=' + parseInt(bitrate, 10) +
                    '|last_packets_in=' + packetsLastSent +
                    '|lost_packets=' + report.packetsLost);
                }
              }); // eslint-disable-line no-unused-vars
            } catch (e) {
              //
            }
          } else {
            window.untrackBitrate();
            // statsField.classList.add('hidden');
          }
        }

        //render header report
        function generateReportStats(bitrate, packets, $parent) {

          var $b = $parent.querySelectorAll('.bitrate');
          var $p = $parent.querySelectorAll('.packets');
          if ($b.length > 0 && $p.length > 0) {

            $b[0].innerText = ` \${bitrate}`;
            $p[0].innerText = ` \${packets}`;
          } else {
            $parent.innerHTML = '<span>Bitrate: </span><span class="bold bitrate">' + bitrate + '</span>' +
              '<span>. Packets Received: </span><span class="bold packets">' + packets + '</span>' +
              '<span>.</span>';
          }
        }

        //render content report
        function generateReportBlock(key, value, $parent) {
        
          var $el = $parent.getElementsByClassName(key);
         
          if ($el.length > 0) {
            $el[0].innerText = `\${value}`;
          } else {
            $parent.innerHTML += '<p><span class="report_key">' + key + '</span> :  <span class="report_value ' + key + '">' +    value + '</span></p>';
          }
        }

        
        //clear log
        function clearLog() {
          document.getElementById("event-log").innerHTML = ""
        }




      </script>

      </html>