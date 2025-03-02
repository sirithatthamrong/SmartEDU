document.addEventListener("DOMContentLoaded", function () {
  // Create a new scanner instance using the video element with id "preview"
  let scanner = new Instascan.Scanner({ video: document.getElementById("preview") });
  let activeCamera = null;

  scanner.addListener("scan", function (content) {
    let [uid, hash] = content.split(",");

    fetch("/admin/checkin", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify({ uid: uid, hash: hash }) // now include hash
    })
    .then(response => response.json())
    .then(data => {
      alert(data.message || "Check-in failed!");
    })
    .catch(error => console.error("Error:", error));
  });

  // Get available cameras and start the scanner with the first available one
  Instascan.Camera.getCameras()
    .then(function (cameras) {
      if (cameras.length > 0) {
        activeCamera = cameras[0];
        scanner.start(activeCamera);
      } else {
        console.error("No cameras found.");
      }
    })
    .catch(function (e) {
      console.error(e);
    });

  // Stop the camera when navigating away
  function stopScanner() {
    if (scanner) {
      scanner.stop(); // Stops scanning
    }
    if (activeCamera && activeCamera.stream) {
      activeCamera.stream.getTracks().forEach(track => track.stop()); // Stops the camera stream
    }
  }

  // Stop camera on page unload
  window.addEventListener("beforeunload", stopScanner);
  window.addEventListener("pagehide", stopScanner);
});
