document.addEventListener("DOMContentLoaded", async function () {
    for (const button of document.querySelectorAll(".check-in-btn")) {
        let studentId = button.dataset.studentId;

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
