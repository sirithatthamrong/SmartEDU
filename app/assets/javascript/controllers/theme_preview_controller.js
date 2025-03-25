document.addEventListener("DOMContentLoaded", function () {
    const primaryInput     = document.getElementById("primary-color");
    const secondaryInput   = document.getElementById("secondary-color");
    const tertiaryInput    = document.getElementById("tertiary-color");
    const accentInput      = document.getElementById("accent-color");
    const backgroundInput  = document.getElementById("background-color");

    const previewHeader    = document.getElementById("preview-header");
    const previewTopbar    = document.getElementById("preview-topbar");
    const previewBg        = document.getElementById("preview-bg");
    const previewCard      = document.getElementById("preview-card");
    const previewInputs    = document.querySelectorAll(".preview-input");

    const primaryBtn       = document.getElementById("preview-primary-btn");
    const accentBtn        = document.getElementById("preview-accent-btn");

    const secondaryLink    = document.getElementById("preview-secondary-link");
    const tertiaryLink     = document.getElementById("preview-tertiary-link");

    function updatePreview() {
        const primary    = primaryInput?.value     || "#000000";
        const secondary  = secondaryInput?.value   || "#000000";
        const tertiary   = tertiaryInput?.value    || "#000000";
        const accent     = accentInput?.value      || "#000000";
        const background = backgroundInput?.value  || "#FFFFFF";
        const black      = "#000000";

        // Background gradient for the outer container
        previewBg.style.setProperty("background-image", `linear-gradient(to right, ${accent}, ${secondary})`, "important");

        // Sign-in card background
        if (previewCard) {
            previewCard.style.setProperty("background-color", background, "important");
        }

        // Header color
        previewHeader.style.setProperty("color", black, "important");

        // Inputs styling
        previewInputs.forEach(input => {
            input.style.setProperty("border-color", primary, "important");
            input.style.setProperty("color", primary, "important");
            input.style.setProperty("background-color", "#ffffff", "important");
            input.style.setProperty("caret-color", primary, "important");
        });

        // Top bar styling (if applicable)
        if (previewTopbar) {
            previewTopbar.style.setProperty("background-color", accent, "important");
            previewTopbar.style.setProperty("color", black, "important");
        }

        // Buttons styling
        if (primaryBtn) {
            primaryBtn.style.setProperty("background-color", primary, "important");
            primaryBtn.style.setProperty("color", "#ffffff", "important");
        }
        if (accentBtn) {
            accentBtn.style.setProperty("background-color", accent, "important");
            accentBtn.style.setProperty("color", primary, "important");
        }

        // Links styling
        if (secondaryLink) {
            secondaryLink.style.setProperty("color", secondary, "important");
        }
        if (tertiaryLink) {
            tertiaryLink.style.setProperty("color", tertiary, "important");
        }
    }

    [primaryInput, secondaryInput, tertiaryInput, accentInput, backgroundInput].forEach(input => {
        if (input) {
            input.addEventListener("input", updatePreview);
        }
    });

    updatePreview(); // Initialize on page load
});
