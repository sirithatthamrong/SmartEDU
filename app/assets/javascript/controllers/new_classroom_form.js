document.addEventListener('DOMContentLoaded', function() {
    const gradeSelect = document.getElementById('classroom_grade_level');
    const sectionInput = document.getElementById('classroom_section_name');
    const hiddenClassIdField = document.getElementById('classroom_full_class_id');

    function updateClassId() {
        if (gradeSelect.value && sectionInput.value) {
            hiddenClassIdField.value = gradeSelect.value + sectionInput.value;
        }
    }

    gradeSelect.addEventListener('change', updateClassId);
    sectionInput.addEventListener('input', updateClassId);

    updateClassId();
});
