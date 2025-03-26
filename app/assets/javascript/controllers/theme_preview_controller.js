document.addEventListener("DOMContentLoaded", function () {
    const primaryInput     = document.getElementById("primary-color");
    const secondaryInput   = document.getElementById("secondary-color");
    const accentInput      = document.getElementById("accent-color");
    const backgroundInput  = document.getElementById("background-color");
    const base100Input     = document.getElementById("base-100-color");
    const base200Input     = document.getElementById("base-200-color");
    const base300Input     = document.getElementById("base-300-color");
    const base500Input     = document.getElementById("base-500-color");
    const baseContentInput = document.getElementById("base-content-color");

    const previewHeader    = document.getElementById("preview-header");
    const previewBg        = document.getElementById("preview-bg");
    const previewCard      = document.getElementById("preview-card");
    const previewInputs    = document.querySelectorAll(".input-bordered");

    const primaryBtn       = document.getElementById("preview-primary-btn");
    const accentBtn        = document.getElementById("preview-accent-btn");
    const secondaryLink    = document.getElementById("preview-secondary-link");
    const tertiaryLink     = document.getElementById("preview-tertiary-link");

    function updatePreview() {
        const primary    = primaryInput?.value     || "#000000";
        const secondary  = secondaryInput?.value   || "#000000";
        const accent     = accentInput?.value      || "#000000";

        const base100    = base100Input?.value     || "#ffffff";
        const base200    = base200Input?.value     || "#f8f8f8";
        const base300    = base300Input?.value     || "#f0f0f0";
        const base500    = base500Input?.value     || "#d0d0d0";
        const baseContent = baseContentInput?.value || "#00182A";

        const black = "#000000";

        // Background gradient for outer container
        previewBg.style.setProperty("background-image", `linear-gradient(to right, ${accent}, ${secondary})`, "important");

        // Update base variables on preview container
        previewBg.style.setProperty("--base-100", base100);
        previewBg.style.setProperty("--base-200", base200);
        previewBg.style.setProperty("--base-300", base300);
        previewBg.style.setProperty("--base-500", base500);
        previewBg.style.setProperty("--base-content", baseContent);

        // Card background
        previewCard.style.setProperty("background-color", base200);

        // Inputs
        previewInputs.forEach(input => {
            input.style.setProperty("border-color", base500);
            input.style.setProperty("color", base500);
            input.style.setProperty("background-color", base100);
            input.style.setProperty("caret-color", base500);
        });

        // Header
        previewHeader.style.setProperty("color", baseContent);

        // Buttons
        primaryBtn?.style.setProperty("background-color", primary);
        primaryBtn?.style.setProperty("color", "#ffffff");

        accentBtn?.style.setProperty("background-color", accent);
        accentBtn?.style.setProperty("color", baseContent);

        // Links
        secondaryLink?.style.setProperty("color", secondary);
        tertiaryLink?.style.setProperty("color", base500);
    }

    [primaryInput, secondaryInput, accentInput].forEach(input => {
        if (input) {
            input.addEventListener("input", updatePreview);
        }
    });

    const baseThemeSelect = document.querySelector('select[name="base_color_scheme"]');
    if (baseThemeSelect) {
        baseThemeSelect.addEventListener("change", (e) => {
            if (e.target.value === "light") {
                base100Input.value     = "#ffffff";
                base200Input.value     = "#f8f8f8";
                base300Input.value     = "#f0f0f0";
                base500Input.value     = "#d0d0d0";
                baseContentInput.value = "#00182A";
            } else if (e.target.value === "dark") {
                base100Input.value     = "#1e1e1e";
                base200Input.value     = "#2a2a2a";
                base300Input.value     = "#333333";
                base500Input.value     = "#4e4e4e";
                baseContentInput.value = "#ffffff";
            }
            updatePreview();
        });
    }

    updatePreview(); // Initial call
});
