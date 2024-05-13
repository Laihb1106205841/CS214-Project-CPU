package chip.southbridge.Web;

import chip.southbridge.DB.Druid;
import chip.southbridge.UART.Sender;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

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
public class WebAPI {

    private final Sender sender;
    private final Logger log;
    private final Druid druid;

    @Autowired
    public WebAPI(Sender sender,Logger log,Druid druid){
        this.sender = sender;
        this.log = log;
        this.druid = druid;
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

    private List<String> dataList = new ArrayList<>();

    @GetMapping("/data")
    public List<String> getData() {
        // 返回存储在后端的数据
        return dataList;
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
        // 接收到文本数据，可以在这里进行处理，比如保存到数据库或者其他操作
        log.info("Received text: " + text);
        sender.Spring2Uart(text);
        dataList.add(text);
    }
}
