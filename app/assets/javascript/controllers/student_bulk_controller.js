function openBulkStudentModal() {
    document.getElementById("bulk-student-modal").classList.remove("hidden");
    document.getElementById("bulk-student-modal").classList.add("flex");
}

function closeBulkStudentModal() {
    document.getElementById("bulk-student-modal").classList.add("hidden");
    document.getElementById("bulk-student-modal").classList.remove("flex");
}
