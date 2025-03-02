document.addEventListener("DOMContentLoaded", function () {
  let scanner = new Instascan.Scanner({ video: document.getElementById("preview") });
  let activeCamera = null;
  let scanning = true; // Ensure scanning is enabled at the start
  let qrFrame = document.getElementById("qr-frame"); // Get QR frame element for flash effect

  scanner.addListener("scan", function (content) {
    if (!scanning) return;
    scanning = false; // Temporarily disable scanning to prevent duplicate scans

    console.log("Scanned content:", content);

    // Flash effect to indicate successful scan
    qrFrame.classList.add("flash-effect");
    setTimeout(() => qrFrame.classList.remove("flash-effect"), 500);

    let parts = content.split(",");
    if (parts.length !== 2) {
      alert("Invalid QR code! Please scan a valid check-in code.");
      return resumeScanning();
    }

    let [uid, hash] = parts.map(part => part.trim());
    if (!uid || !hash) {
      alert("Invalid QR code! Missing required data.");
      return resumeScanning();
    }

    fetch("/admin/checkin", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      },
      body: JSON.stringify({ uid: uid, hash: hash })
    })
    .then(response => response.json())
    .then(data => {
      alert(data.message || "Check-in failed!");
      scanning = true; // Allow scanning again immediately after response
    })
    .catch(error => {
      console.error("Error:", error);
      alert("Error processing QR code. Please try again.");
      scanning = true; // Ensure scanning resumes even on errors
    });
  });

  // Get available cameras and start the scanner with the first available one
  Instascan.Camera.getCameras()
    .then(function (cameras) {
      if (cameras.length > 0) {
        activeCamera = cameras[0];
        scanner.start(activeCamera);
        scanning = true; // Ensure scanning is enabled when camera starts
      } else {
        console.error("No cameras found.");
      }
    })
    .catch(function (e) {
      console.error(e);
    });

  function resumeScanning() {
    scanning = true; // Allow scanning again immediately after delay
  }

  // Stop the camera when navigating away
  function stopScanner() {
    if (scanner) {
      scanner.stop();
    }
    if (activeCamera && activeCamera.stream) {
      activeCamera.stream.getTracks().forEach(track => track.stop());
    }
  }

  window.addEventListener("beforeunload", stopScanner);
  window.addEventListener("pagehide", stopScanner);
});
