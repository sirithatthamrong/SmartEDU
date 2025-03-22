document.addEventListener("DOMContentLoaded", async function () {
    for (const button of document.querySelectorAll(".check-in-btn")) {
        let studentId = button.dataset.studentId;

        let { checked_in, authorized } = await fetchCheckInStatus(studentId);
        button.dataset.checkedIn = checked_in ? "true" : "false";
        updateButtonStyle(button);

        if (!authorized) {
            button.disabled = true; // Disable the button
            button.style.pointerEvents = "none"; // Prevent clicks entirely
            button.style.opacity = "1";
            continue;
        }

        button.addEventListener("click", async function (event) {
            event.preventDefault();

            if (button.disabled) return; // Double check before executing

            try {
                let response = await fetch(window.attendancesPath, {
                    method: "POST",
                    headers: {
                        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify({ student_id: studentId })
                });

                let result = await response.json();
                if (response.ok && result.status === "success") {
                    button.dataset.checkedIn = button.dataset.checkedIn === "true" ? "false" : "true";
                    window.location.reload();
                } else {
                    console.error("Check-in failed:", result);
                }
            } catch (error) {
                console.error("Check-in request error:", error);
            }
        });
    }

// Function to fetch both check-in status and authorization
async function fetchCheckInStatus(studentId) {
    try {
        let response = await fetch(`/attendances/${studentId}/status`);
        let result = await response.json();
        return { checked_in: result.checked_in, authorized: result.authorized };
    } catch (error) {
        console.error("Error checking check-in status:", error);
        return { checked_in: false, authorized: false };
    }
}

// Function to update button style dynamically
function updateButtonStyle(button) {
    let isCheckedIn = button.dataset.checkedIn === "true";
    button.classList.toggle("checked-in", isCheckedIn);
    button.style.backgroundColor = isCheckedIn ? "lightgreen" : "lightgray";
    button.textContent = isCheckedIn ? "Checked In" : "Check-In";
}

    let gradeDropdown = document.getElementById("grade");

    gradeDropdown.addEventListener("change", function () {
        document.getElementById("gradeFilterForm").submit(); // Auto-submit form
    });
});

async function waitForPageLoad() {
    return new Promise((resolve) => {
        if (document.readyState === "complete") {
            resolve();
        } else {
            window.addEventListener("load", resolve);
        }
    });
}

async function initializeDataTable() {
    console.log("Initializing DataTable...");

    const tableId = "#shared-table";

    // Destroy DataTable if it already exists
    if ($.fn.DataTable.isDataTable(tableId)) {
        $(tableId).DataTable().destroy();
    }

    // Initialize DataTable
    $(tableId).DataTable({
        responsive: true,
        pageLength: 10,
        language: {
            search: "",
            searchPlaceholder: "Search students...",
        },
        initComplete: function () {
            styleDataTableElements();
        },
        drawCallback: function () {
            styleDataTableElements(); // Apply styles every time the page updates
        }
    });

    console.log("DataTable initialized successfully!");

    await waitForPageLoad();
}

// Function to apply consistent styling
function styleDataTableElements() {
    // Style search input
    $("div.dt-container .dt-search input").css({
        "border": "1px solid #aaa",
        "border-radius": "10px",
        "padding": "5px",
        "background-color": "transparent",
        "color": "inherit",
        "margin-left": "3px",
        "width": "400px",
    });

    // Style select dropdown
    $("div.dt-container select.dt-input").css({
        "border": "1px solid #aaa",
        "border-radius": "10px",
        "padding": "5px",
        "background-color": "transparent",
        "color": "inherit",
    });

    // Style pagination buttons consistently
    $("div.dt-container .dt-paging-button").css({
        "border": "1px solid #aaa",
        "border-radius": "10px",
        "padding": "10px",
        "background-color": "transparent",
        "color": "inherit",
    });

    // Ensure the current page button stands out
    $("div.dt-container .dt-paging-button.current").css({
        "border": "1px solid #aaa",
        "border-radius": "10px",
        "padding": "10px",
        "background-color": "transparent",
        "color": "inherit"
    });
}

initializeDataTable().then(r => console.log("DataTable initialized!"));

initializeDataTable().then(r => console.log("DataTable initialized!"));
