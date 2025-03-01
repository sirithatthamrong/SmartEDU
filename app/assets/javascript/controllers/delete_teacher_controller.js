document.addEventListener("DOMContentLoaded", function () {
    window.confirmDelete = function(teacherId, teacherEmail) {
        console.log("Opening delete modal for", teacherEmail);
        document.getElementById("teacherEmail").innerText = teacherEmail;
        document.getElementById("deleteForm").action = `/teachers/${teacherId}`;
        document.getElementById("deleteModal").style.display = "flex";
    };

    window.closeModal = function() {
        document.getElementById("deleteModal").style.display = "none";
    };
});
