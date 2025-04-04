document.addEventListener("DOMContentLoaded", function () {
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
            searchPlaceholder: "Search by name...",
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

function styleDataTableElements() {
    // Style search input
    $("div.dt-container .dt-search input").css({
        "border": "1px solid #aaa",
        "border-radius": "100px",
        "padding": "8px",
        "background-color": "transparent",
        "color": "inherit",
        "margin-left": "3px",
        "width": "300px",
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
        "padding": "8px",
        "background-color": "transparent",
        "color": "inherit",
    });

    // Ensure the current page button stands out
    $("div.dt-container .dt-paging-button.current").css({
        "border": "1px solid #aaa",
        "border-radius": "10px",
        "padding": "8px",
        "background-color": "transparent",
        "color": "inherit"
    });

    // ** Center-align column headers **
    $("div.dt-container table.dataTable thead th").css({
        "text-align": "left",
        "padding": "12px",  // Adds better spacing
        "white-space": "nowrap"  // Prevents header text from wrapping
    });

    // ** Left-align all table cell text (body) **
    $("div.dt-container table.dataTable tbody td").css({
        "text-align": "left",  // Center-aligns text
        "padding": "10px",  // More balanced spacing
        "white-space": "nowrap"  // Prevents text wrapping in cells
    });

    // Adjust overall table spacing
    $("div.dt-container table.dataTable").css({
        "width": "100%",  // Ensures the table takes up full width
        "border-collapse": "collapse"  // Reduces unnecessary spacing
    });
}


initializeDataTable().then(r => console.log("DataTable initialized!"));
