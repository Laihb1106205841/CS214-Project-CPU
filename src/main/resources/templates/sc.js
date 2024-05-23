// script.js

document.addEventListener("DOMContentLoaded", function() {
    const refreshButton = document.getElementById('refreshButton');

    refreshButton.addEventListener('click', function() {
        window.location.reload();
    });
});
