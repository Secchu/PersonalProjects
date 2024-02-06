function copyClipBoard(id, buttonId) {
    var copied = document.getElementById(id);
    navigator.clipboard.writeText(copied.innerText);

    var button = document.getElementById(buttonId);
    button.innerText = "Copied";
}

function mouseOut(id) {
    var button = document.getElementById(id);
    button.innerText = "Copy";
}