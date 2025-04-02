document.addEventListener("DOMContentLoaded", function () {
    console.log("JavaScript Loaded");

    window.openDeleteModal = function(classroomId) {
        console.log("Opening delete modal for classroom:", classroomId);
        let modal = document.getElementById("deleteModal");
        let deleteForm = document.getElementById("deleteForm");

        if (modal && deleteForm) {
            deleteForm.action = `/classrooms/${classroomId}`; // Set form action dynamically

            // Ensure visibility
            modal.classList.remove("hidden");
            modal.style.display = "flex"; // Ensure flex display for visibility

            console.log("Modal Opened");
        } else {
            console.error("Modal or deleteForm not found");
        }
    };

    window.closeDeleteModal = function() {
        let modal = document.getElementById("deleteModal");
        if (modal) {
            modal.classList.add("hidden");  // Reapply hidden class
            modal.style.display = "none";   // Ensure it disappears
            console.log("Modal Closed");
        } else {
            console.error("Modal not found");
        }
    };

    // Add direct event listener to the cancel button
    const cancelButton = document.querySelector("#deleteModal button.entity-btn-secondary");
    if (cancelButton) {
        console.log("Cancel button found, adding event listener");
        cancelButton.addEventListener("click", function() {
            window.closeDeleteModal();
        });
    } else {
        console.error("Cancel button not found");
    }
});
