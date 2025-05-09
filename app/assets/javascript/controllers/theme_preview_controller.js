document.addEventListener("DOMContentLoaded", function () {
    const previewBg = document.getElementById("preview-bg");
    const previewHeader = document.getElementById("preview-header");
    const previewCard = document.getElementById("preview-card");
    const previewInputs = document.querySelectorAll(".input-bordered");

    const primaryInput = document.getElementById("primary-color");
    const secondaryInput = document.getElementById("secondary-color");
    const accentInput = document.getElementById("accent-color");

    const base100Input = document.getElementById("base-100-color");
    const base200Input = document.getElementById("base-200-color");
    const base300Input = document.getElementById("base-300-color");
    const base500Input = document.getElementById("base-500-color");
    const baseContentInput = document.getElementById("base-content-color");

    const previewPrimaryBtn = document.getElementById("preview-primary-btn");
    const previewAccentBtn = document.getElementById("preview-accent-btn");

    const builtInThemes = {
        light: {
            primary: "#570df8",
            secondary: "#f000b8",
            accent: "#37cdbe",
            base100: "#ffffff",
            base200: "#f8f8f8",
            baseContent: "#00182A",
        },
        cupcake: {
            primary: "#65c3c8",
            secondary: "#ef9fbc",
            accent: "#eeaf3a",
            base100: "#faf7f5",
            base200: "#efeae6",
            baseContent: "#291334",
        },
        emerald: {
            primary: "#34d399",
            secondary: "#3b82f6",
            accent: "#f97316",
            base100: "#ffffff",
            base200: "#f2f2f2",
            baseContent: "#000000",
        },
        pastel: {
            primary: "#d1c1d7",
            secondary: "#f4c2c2",
            accent: "#b5ead7",
            base100: "#ffffff",
            base200: "#f8f8f8",
            baseContent: "#00182A",
        },
    };

    function getContrastingTextColor(hex) {
        if (!hex || hex.length !== 7) return "#ffffff";
        const r = parseInt(hex.slice(1, 3), 16);
        const g = parseInt(hex.slice(3, 5), 16);
        const b = parseInt(hex.slice(5, 7), 16);
        const luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
        return luminance > 0.5 ? "#000000" : "#ffffff";
    }

    function applyThemeToPreview({ primary, secondary, accent, base100, base200, baseContent }) {
        const primaryContent = getContrastingTextColor(primary);
        const secondaryContent = getContrastingTextColor(secondary);
        const accentContent = getContrastingTextColor(accent);

        // Set CSS variables globally on preview container
        previewBg.style.setProperty("--primary", primary);
        previewBg.style.setProperty("--primary-content", primaryContent);
        previewBg.style.setProperty("--secondary", secondary);
        previewBg.style.setProperty("--secondary-content", secondaryContent);
        previewBg.style.setProperty("--accent", accent);
        previewBg.style.setProperty("--accent-content", accentContent);
        previewBg.style.setProperty("--base-100", base100);
        previewBg.style.setProperty("--base-200", base200);
        previewBg.style.setProperty("--base-content", baseContent);

        // Gradient only for Slide 1
        const slideSignin = document.getElementById("slide-signin");
        if (slideSignin) {
            slideSignin.style.backgroundImage = `linear-gradient(to right, ${accent}, ${primary})`;
        }

        const navbarButton = document.getElementById("preview-navbar-button");
        if (navbarButton) {
            navbarButton.style.backgroundColor = primary;
            navbarButton.style.color = primaryContent;
        }

        // thead
        const tableHead = document.getElementById("preview-table-head");
        if (tableHead) {
            tableHead.style.backgroundColor = secondary;
            tableHead.style.color = getContrastingTextColor(secondary);
        }

        // Card + form styling
        previewCard.style.backgroundColor = base200;
        previewHeader.style.color = baseContent;

        const previewForgotLink = document.getElementById("preview-secondary-link");
        const previewHomeLink = document.getElementById("preview-tertiary-link");

        if (previewForgotLink) previewForgotLink.style.color = primary;
        if (previewHomeLink) previewHomeLink.style.color = secondary;
        if (previewPrimaryBtn) {
            previewPrimaryBtn.style.backgroundColor = primary;
            previewPrimaryBtn.style.color = primaryContent;
        }
        if (previewAccentBtn) {
            previewAccentBtn.style.backgroundColor = accent;
            previewAccentBtn.style.color = accentContent;
        }

        // Input styling
        previewInputs.forEach((input) => {
            input.style.borderColor = base500Input?.value || "#d0d0d0";
            input.style.backgroundColor = base100;
            input.style.caretColor = base500Input?.value || "#d0d0d0";
            input.style.color = "#9ca3af";

            const existingStyle = document.getElementById("dynamic-placeholder-style");
            if (existingStyle) existingStyle.remove();

            const style = document.createElement("style");
            style.id = "dynamic-placeholder-style";
            style.innerHTML = `
      #preview-bg input::placeholder {
        color: #9ca3af !important;
      }
    `;
            document.head.appendChild(style);
        });

        // Navbar and table head
        const navbar = document.getElementById("preview-navbar");
        const hoverRows = document.querySelectorAll(".hover-row");

        if (navbar) navbar.style.backgroundColor = primary;
        if (tableHead) {
            tableHead.style.backgroundColor = secondary;
            tableHead.style.color = getContrastingTextColor(secondary);
        }

        hoverRows.forEach((row) => {
            row.addEventListener("mouseenter", () => (row.style.backgroundColor = accent));
            row.addEventListener("mouseleave", () => (row.style.backgroundColor = base100));
        });
    }

    function updateCustomPreview() {
        applyThemeToPreview({
            primary: primaryInput?.value || "#000000",
            secondary: secondaryInput?.value || "#000000",
            accent: accentInput?.value || "#000000",
            base100: base100Input?.value || "#ffffff",
            base200: base200Input?.value || "#f8f8f8",
            baseContent: baseContentInput?.value || "#00182A",
        });
    }

    document.addEventListener("themeChanged", (e) => {
        const selected = e.detail.theme;
        previewBg.setAttribute("data-theme", selected === "custom" ? "mytheme" : selected);
        if (selected === "custom") {
            base100Input.value = "#ffffff";
            base200Input.value = "#f8f8f8";
            base300Input.value = "#f0f0f0";
            base500Input.value = "#d0d0d0";
            baseContentInput.value = "#00182A";

            updateCustomPreview();
        } else {
            const theme = builtInThemes[selected];
            if (theme) applyThemeToPreview(theme);
        }
    });

    [primaryInput, secondaryInput, accentInput].forEach((input) => {
        input?.addEventListener("input", () => {
            const selectedTheme = document.querySelector(".theme-radio:checked")?.value;
            if (selectedTheme === "custom") updateCustomPreview();
        });
    });

    // Slider logic
    const slides = document.querySelectorAll(".preview-slide");
    const dots = document.querySelectorAll("[data-slide]");
    let currentSlide = 0;

    function showSlide(index) {
        slides.forEach((slide, i) => {
            slide.classList.toggle("hidden", i !== index);
        });
        dots.forEach((dot, i) => {
            dot.classList.toggle("bg-gray-400", i !== index);
            dot.classList.toggle("bg-primary", i === index);
        });
        currentSlide = index;
    }

    document.getElementById("slide-next")?.addEventListener("click", () => {
        showSlide((currentSlide + 1) % slides.length);
    });

    document.getElementById("slide-prev")?.addEventListener("click", () => {
        showSlide((currentSlide - 1 + slides.length) % slides.length);
    });

    dots.forEach((dot) => {
        dot.addEventListener("click", () => showSlide(parseInt(dot.dataset.slide)));
    });

    showSlide(0);

    const initiallySelected = document.querySelector(".theme-radio:checked")?.value;
    if (initiallySelected === "custom") {
        updateCustomPreview();
    } else {
        const theme = builtInThemes[initiallySelected];
        if (theme) applyThemeToPreview(theme);
    }

});
