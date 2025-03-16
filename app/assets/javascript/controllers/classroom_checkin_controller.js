document.addEventListener("DOMContentLoaded", async function () {
    for (const button of document.querySelectorAll(".check-in-btn")) {
        let studentId = button.dataset.studentId;

        // Fetch initial check-in status
        let isCheckedIn = await checkIfAlreadyCheckedIn(studentId);
        button.dataset.checkedIn = isCheckedIn ? "true" : "false";
        updateButtonStyle(button);

        button.addEventListener("click", async function (event) {
            event.preventDefault();

            try {
                let response = await fetch(window.attendancesPath, {
                    method: "POST", headers: {
                        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
                        "Content-Type": "application/json"
                    }, body: JSON.stringify({student_id: studentId})
                });

                let result = await response.json();
                if (response.ok && result.status === "success") {
                    // Toggle dataset checked-in state immediately
                    button.dataset.checkedIn = button.dataset.checkedIn === "true" ? "false" : "true";
                    window.location.reload();
                } else {
                    console.error("Check-in failed:", result);
                }
            } catch (error) {
                console.error("Check-in request error:", error);
            }
            window.location.reload();
        });
    }
});

// Function to check if the student is already checked in
async function checkIfAlreadyCheckedIn(studentId) {
    try {
        let response = await fetch(`/attendances/${studentId}/check_if_checked_in`);
        let result = await response.json();
        return result.checked_in;
    } catch (error) {
        console.error("Error checking check-in status:", error);
        return false;
    }
}

// Function to update button style dynamically
function updateButtonStyle(button) {
    let isCheckedIn = button.dataset.checkedIn === "true";
    button.classList.toggle("checked-in", isCheckedIn);
    button.style.backgroundColor = isCheckedIn ? "lightgreen" : "lightgray";
    button.textContent = isCheckedIn ? "Checked In" : "Check-In";
}
