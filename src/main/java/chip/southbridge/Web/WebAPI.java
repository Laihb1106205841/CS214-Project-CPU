package chip.southbridge.Web;

import chip.southbridge.DB.Druid;
import chip.southbridge.UART.Sender;
import lombok.Getter;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.springframework.amqp.core.AmqpTemplate;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.Queue;

import static chip.southbridge.util.DataTrans.binaryToHex;

@RestController
@CrossOrigin(origins = {
        "http://localhost:8082",
        "http://localhost:8999",
        "http://102.168.124.50",
        "http://10.27.96.19:8082",
        "http://10.27.96.19:8999",
        "http://10.32.61.211:8082",
        "http://10.32.61.211:8085",
        "http://10.32.61.211:8999",
        "http://10.12.80.214:8082",
        "http://10.12.80.214:8999"})
@Component
public class WebAPI {

    private final Sender sender;
    private final Logger log;
    @Getter
    private final Druid druid;

    private final List<String> dataList = new ArrayList<>();

    private final List<String> dataFromWeb = new ArrayList<>();
    final Queue<String> uartQueue;

    @Autowired
    private AmqpTemplate amqpTemplate;

    @Autowired
    public WebAPI(Sender sender, Logger log, Druid druid, Queue<String> uartQueue){
        this.sender = sender;
        this.log = log;
        this.druid = druid;
        this.uartQueue = uartQueue;
    }

    @RabbitListener(queues = "h")
    public void receiveMessage(String message) {
        log.info("Received message from MQ, add to Web: " + message);
        dataList.add(message);
    }


    @PostMapping("/processTextData")
    public String processTextData(@RequestBody String textData) {
        // 拆分文本数据为行
        String[] lines = textData.split("\\r?\\n");

        // 对每一行调用 setbb() 方法处理
        for (String data : lines) {
            setbb(data); // 假设 setbb() 方法已经定义并可用
        }

        return "Data processed successfully";
    }

    private void setbb(String data) {
        // 这里是你的处理逻辑
        log.info("Processing data: " + data);
    }



    @GetMapping("/data")
    public List<String> getData() {
        // 返回存储在后端的数据
        log.info("get Data");
        return dataList;
    }

    @GetMapping("/dataReceived")
    public List<String> getData2() {
        log.info("Data Receive from Web");
        // 返回存储在后端的数据
        return dataFromWeb;
    }

    // 在其他地方更新数据，这里只是一个示例
    public void updateData(List<String> newData) {
        dataList.clear();
        dataList.addAll(newData);
    }

//    private int number = 0; // 初始数字为 0

    @PostMapping("/addNumber")
    public void addNumber() {
        // 每次请求增加数字1
        dataList.add("1");
    }

    @PostMapping("/addText")
    public void addText(@RequestBody String text) {
        // 接收到文本数据
        text = extractText(text);
        log.info("Received text from web: " + text);
        dataFromWeb.add(text);

//        String decimal = binaryToHex(text);

        sender.Spring2Uart(text);
//        dataList.add(text);
    }

    @PostMapping("/clearDataList")
    public void refresh() {
        log.info("Clear Message!");
        dataList.clear();   // FPGA -> 电脑数据
        dataFromWeb.clear(); // Ins数据
    }

    public static String extractText(String jsonString) {
        try {
            // 将 JSON 字符串解析为 JSONObject
            JSONObject jsonObject = new JSONObject(jsonString);
            // 从 JSONObject 中提取 "text" 字段的值
            String text = jsonObject.getString("text");
            return text;
        } catch (Exception e) {
            // 捕获异常并打印错误消息
            System.out.println("JSON 解析错误: " + e.getMessage());
            return null;
        }
    }

}
