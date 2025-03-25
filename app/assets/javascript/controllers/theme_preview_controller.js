// app/javascript/controllers/theme_preview_controller.js
document.addEventListener("DOMContentLoaded", function () {
    // Grab all input elements
    const primaryInput   = document.getElementById("primary-color");
    const secondaryInput = document.getElementById("secondary-color");
    const accentInput    = document.getElementById("accent-color");
    const neutralInput   = document.getElementById("neutral-color");

    // Grab preview elements
    const previewHeader = document.getElementById("preview-header");
    const previewText   = document.getElementById("preview-text");
    const previewBg     = document.getElementById("preview-bg");
    const primaryBtn    = document.getElementById("preview-primary-btn");
    const accentBtn     = document.getElementById("preview-accent-btn");

    // A helper function to update the preview area
    function updatePreview() {
        const primary   = primaryInput?.value || "#000000";
        const secondary = secondaryInput?.value || "#000000";
        const accent    = accentInput?.value || "#000000";
        const neutral   = neutralInput?.value || "#FFFFFF";

        previewHeader.style.color = primary;
        previewText.style.color   = secondary;
        previewBg.style.backgroundColor = neutral;

        primaryBtn.style.backgroundColor = primary;
        primaryBtn.style.color = "#FFFFFF"; // or pick a contrasting color

        accentBtn.style.backgroundColor = accent;
        accentBtn.style.color = "#000000"; // or pick a contrasting color
    }

    // Listen for changes on each color input
    [primaryInput, secondaryInput, accentInput, neutralInput].forEach(input => {
        if (input) {
            input.addEventListener("input", updatePreview);
        }
    });

    // Run once on page load, so the preview matches any existing saved colors
    updatePreview();
});
