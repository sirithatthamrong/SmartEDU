document.addEventListener("DOMContentLoaded", () => {
    const themeRadios = document.querySelectorAll(".theme-radio");
    const customForm = document.getElementById("custom-form");
    const themeField = document.getElementById("selected-theme-name");
    const previewThemeLabel = document.getElementById("theme-preview-label");

    function highlightSelectedTheme(selectedTheme) {
        themeRadios.forEach(radio => {
            const label = radio.closest("label");
            if (radio.value === selectedTheme) {
                label.classList.add("ring-2", "ring-primary");
            } else {
                label.classList.remove("ring-2", "ring-primary");
            }
        });
    }

    themeRadios.forEach(radio => {
        radio.addEventListener("change", (e) => {
            const selectedTheme = e.target.value;

            // Update form and hidden input
            if (customForm) {
                customForm.classList.toggle("hidden", selectedTheme !== "custom");
            }
            if (themeField) themeField.value = selectedTheme;
            if (previewThemeLabel) previewThemeLabel.textContent = selectedTheme;

            // Highlight selected
            highlightSelectedTheme(selectedTheme);

            // Let preview controller handle the visual update
            const previewEvent = new CustomEvent("themeChanged", {
                detail: { theme: selectedTheme }
            });
            document.dispatchEvent(previewEvent);
        });

        if (radio.checked) {
            radio.dispatchEvent(new Event("change"));
        }
    });
});
