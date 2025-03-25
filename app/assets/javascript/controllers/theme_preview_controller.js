// app/javascript/controllers/theme_preview_controller.js
document.addEventListener("DOMContentLoaded", function () {
    // Input fields
    const primaryInput     = document.getElementById("primary-color");
    const secondaryInput   = document.getElementById("secondary-color");
    const tertiaryInput    = document.getElementById("tertiary-color");
    const accentInput      = document.getElementById("accent-color");
    const backgroundInput  = document.getElementById("background-color");

    // Preview elements
    const previewHeader    = document.getElementById("preview-header");
    const previewText      = document.getElementById("preview-text");
    const previewBg        = document.getElementById("preview-bg");
    const primaryBtn       = document.getElementById("preview-primary-btn");
    const tertiaryBtn      = document.getElementById("preview-tertiary-btn");

    function updatePreview() {
        const primary    = primaryInput?.value     || "#000000";
        const secondary  = secondaryInput?.value   || "#000000";
        const tertiary   = tertiaryInput?.value    || "#000000";
        const accent     = accentInput?.value      || "#000000";
        const background = backgroundInput?.value  || "#FFFFFF";

        previewHeader.style.color = primary;
        previewText.style.color   = secondary;
        previewBg.style.backgroundColor = background;

        primaryBtn.style.backgroundColor = primary;
        primaryBtn.style.color = "#FFFFFF";

        tertiaryBtn.style.backgroundColor = tertiary;
        tertiaryBtn.style.color = "#000000";
    }

    // Add listeners
    [primaryInput, secondaryInput, tertiaryInput, accentInput, backgroundInput].forEach(input => {
        if (input) {
            input.addEventListener("input", updatePreview);
        }
    });

    updatePreview();
});
