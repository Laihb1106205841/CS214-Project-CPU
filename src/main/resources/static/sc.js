// script.js
var dataListElement = document.getElementById("dataList");
var dataListElement2 = document.getElementById("dataList2");
var textInput = document.getElementById("textInput");
// var addButton = document.getElementById("addButton");
var clearButton = document.getElementById("clearButton");

clearButton.addEventListener('click',function (){
    // 发送 POST 请求到后端的 /addText 端点，并将文本作为请求体发送
    fetch('/Clear', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        // body: JSON.stringify({ text: text }) // 将文本转换为 JSON 格式发送
    })
        .then(response => {
            if (response.ok) {
                // 每次添加成功后重新加载数据
                fetchDataReceived();
                fetchData();
                // 清空文本框
                textInput.value = "";
            } else {
                console.error('Failed to add text');
            }
        })
        .catch(error => console.error('Error adding text:', error));
})








// 页面加载完成后立即获取数据
document.addEventListener('DOMContentLoaded', fetchData);
document.addEventListener('DOMContentLoaded', fetchDataReceived);


document.addEventListener("DOMContentLoaded", function() {
    // const refreshButton = document.getElementById('refreshButton');
    // const addButton = document.getElementById('addButton');
    const clearButton = document.getElementById('clearButton');


    clearButton.addEventListener('click', function() {
        ClearDataReceived();
    })
});





