// script.js
var dataListElement = document.getElementById("dataList");
var dataListElement2 = document.getElementById("dataList2");
var textInput = document.getElementById("textInput");
var addButton = document.getElementById("addButton");
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
                // 清空文本框
                textInput.value = "";
            } else {
                console.error('Failed to add text');
            }
        })
        .catch(error => console.error('Error adding text:', error));
})


addButton.addEventListener("click", function() {
    var text = textInput.value.trim(); // 获取输入的文本并去除两端的空白字符
    if (text !== "") {
        // 发送 POST 请求到后端的 /addText 端点，并将文本作为请求体发送
        fetch('/addText', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ text: text }) // 将文本转换为 JSON 格式发送
        })
            .then(response => {
                if (response.ok) {
                    // 每次添加成功后重新加载数据
                    fetchDataReceived();
                    // 清空文本框
                    textInput.value = "";
                } else {
                    console.error('Failed to add text');
                }
            })
            .catch(error => console.error('Error adding text:', error));

        // fetchDataReceived();
        fetchData();
    }
});

function fetchData() {
    fetch('/data') // 发送 GET 请求到后端的 /data 端点
        .then(response => response.json())
        .then(data => {
            // 清空列表
            dataListElement.innerHTML = '';
            console.log(data)
            // 将获取到的数据添加到列表中
            data.forEach(item => {
                var li = document.createElement("li");
                li.textContent = item;
                dataListElement.appendChild(li);
            });
        })
        .catch(error => console.error('Error fetching data:', error));
}

// 页面加载完成后立即获取数据
document.addEventListener('DOMContentLoaded', fetchData);
document.addEventListener('DOMContentLoaded', fetchDataReceived);


document.addEventListener("DOMContentLoaded", function() {
    const refreshButton = document.getElementById('refreshButton');
    const addButton = document.getElementById('addButton');
    const clearButton = document.getElementById('clearButton');

    refreshButton.addEventListener('click', function() {
        // window.location.reload();
        fetchData();
    });

    addButton.addEventListener('click',function (){
        fetchDataReceived()
    })

    clearButton.addEventListener('click', function() {
        ClearDataReceived();
    })
});


function fetchDataReceived() {
    fetch('/dataReceived') // 发送 GET 请求到后端的 /dataReceived 端点
        .then(response => response.json())
        .then(data => {
            // 清空列表
            dataListElement2.innerHTML = '';
            // 将获取到的数据添加到列表中
            data.forEach(item => {
                var li = document.createElement("li");
                li.textContent = item;
                dataListElement2.appendChild(li);
            });
        })
        .catch(error => console.error('Error fetching data:', error));
}

function ClearDataReceived() {
    fetch('/Clear') // 发送 GET 请求到后端的 /dataReceived 端点
        .then(response => response.json())
        .then(data => {
            // 清空列表
            dataListElement2.innerHTML = '';
            // 将获取到的数据添加到列表中
            data.forEach(item => {
                var li = document.createElement("li");
                li.textContent = item;
                dataListElement2.appendChild(li);
            });
        })
        .catch(error => console.error('Error fetching data:', error));
}
