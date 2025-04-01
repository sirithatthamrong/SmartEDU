document.addEventListener("DOMContentLoaded", function () {
    const gradeSelect = document.getElementById("grade-select");
    const classroomSelect = document.getElementById("classroom-select");

    if (!gradeSelect || !classroomSelect) return;

    gradeSelect.addEventListener("change", function () {
        const grade = this.value;
        classroomSelect.innerHTML = "<option value=''>Loading...</option>";

        fetch(`${classroomsByGradeUrl}?grade=${grade}`)
            .then(response => response.json())
            .then(data => {
                classroomSelect.innerHTML = '<option value="">Select Classroom</option>';
                data.forEach(classroom => {
                    const option = document.createElement("option");
                    option.value = classroom.id;
                    option.textContent = classroom.class_id;
                    classroomSelect.appendChild(option);
                });
            })
            .catch(error => {
                console.error("Failed to load classrooms:", error);
                classroomSelect.innerHTML = '<option value="">Error loading classrooms</option>';
            });
    });
});
