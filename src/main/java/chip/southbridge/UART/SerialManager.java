package chip.southbridge.UART;

import chip.southbridge.DB.Druid;
import com.fazecast.jSerialComm.SerialPort;
import com.fazecast.jSerialComm.SerialPortDataListener;
import com.fazecast.jSerialComm.SerialPortEvent;
import lombok.Getter;
import org.slf4j.Logger;
import org.springframework.amqp.core.AmqpTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.Arrays;
import java.util.Queue;


/**<h2>Class: Serial Communication Manager</h2>
 * <b>Class Description:</b>
 * <p>This class helps java to get interactive with your FPGA</p>
 * <p></p>
 *
 *
 *@version 1.2
 *@since 1.1
 *@author Haibin Lai
 * Date 2023-11-9
 **/
@RestController
@Configuration
@Component
public class SerialManager {

    String COM = "COM4";
    final int BaudRate = 9600;
    final int NumDataBits = 8;
    final int steNumStopBits = 1;
    public SerialPort comPort ; // 指定COM端口

    @Autowired
    private AmqpTemplate amqpTemplate;

    Druid druid;

    @Bean
    public SerialPort OpenSerialPort() {
        return comPort;
    }

    @Autowired
    public SerialManager(Logger log, Queue<String> uartQueue,Druid druid){
        this.druid = druid;
        PortInit(log);
        Listener listener = new Listener(comPort, log, uartQueue);
        Thread t = new Thread(listener);
        t.start();
    }

    class Listener extends Thread{
        public SerialPort comPort ; // 指定COM端口

        @Getter
//        public final Queue<String> uartQueue;
        Logger log;


        public Listener(SerialPort comPort, Logger log, Queue<String> uartQueue){
            this.comPort = comPort;
//        this.uartQueue = uartQueue;
            this.log = log;
//            this.uartQueue = uartQueue;
        }

        @Override
        public void run(){
            Receive();
        }

        public void Receive(){
            if (comPort.openPort()) {
                log.info("Start listening");
                // 添加数据接收事件监听器
                comPort.addDataListener(new SerialPortDataListener() {
                    @Override
                    public int getListeningEvents() {
                        return SerialPort.LISTENING_EVENT_DATA_AVAILABLE;
                    }

                    @Override
                    public void serialEvent(SerialPortEvent event) {

                        if (event.getEventType() == SerialPort.LISTENING_EVENT_DATA_AVAILABLE) {

                            byte[] newData = new byte[comPort.bytesAvailable()];
                            comPort.readBytes(newData, newData.length);
                            System.out.println(Arrays.toString(newData));
                            String receivedData = BytePrintAsString(newData);

                            // 处理接收到的数据
                            log.info("UART Receive data: " + receivedData);
                            amqpTemplate.convertAndSend("h",receivedData);
                        }
                    }
                });
                // 进入一个无限循环以持续监听串口 类似渲染主线程的守护线程
                while (true){
                }
            }
            else {
                log.error("程序无法打开串口:"+comPort.getSystemPortName());
            }

        }

        public String BytePrintAsString(byte [] byteArray) {
            StringBuilder hex = new StringBuilder();
            for (byte b : byteArray) {
                hex.insert(0, Integer.toHexString(b & 0xFF));
                if (hex.length() == 1) {
                    hex.insert(0, '0');
                }
            }
            return hex.toString();
        }
        public static String byteArrayToBinaryString(byte[] newData) {
            StringBuilder binaryStringBuilder = new StringBuilder();
            // 遍历字节数组中的每个字节
            for (byte b : newData) {
                // 将每个字节转换为无符号整数以保留前导零
                int unsignedInt = b & 0xFF;
                // 使用Integer.toBinaryString()将整数转换为二进制字符串
                String binaryByte = Integer.toBinaryString(unsignedInt);
                // 如果字符串长度不足8位，则在前面添加零，使其达到8位长度
                while (binaryByte.length() < 8) {
                    binaryByte = "0" + binaryByte;
                }
                // 拼接每个字节的二进制字符串
                binaryStringBuilder.append(binaryByte);
            }
            return binaryStringBuilder.toString();
        }

        public void exe(){
            Process process;
            try {
                process = Runtime.getRuntime().exec("cmd");
                process.wait();
            } catch (IOException | InterruptedException e) {
                throw new RuntimeException(e);
            }
//        第一行的“cmd”是要执行的命令，Runtime.getRuntime() 返回当前应用程序的Runtime对象，该对象的 exec() 方法指示Java虚拟机创建一个子进程执行指定的可执行程序，并返回与该子进程对应的Process对象实例。通过Process可以控制该子进程的执行或获取该子进程的信息。
//        第二条语句的目的等待子进程完成再往下执行。
        }
    }


    public static void receive(SerialPort comPort, Logger log, Queue<String> uartQueue) {
        if (comPort.openPort()) {
            log.info("Start listening");
            comPort.addDataListener(new SerialPortDataListener() {
                @Override
                public int getListeningEvents() {
                    return SerialPort.LISTENING_EVENT_DATA_AVAILABLE;
                }

                @Override
                public void serialEvent(SerialPortEvent event) {
                    if (event.getEventType() == SerialPort.LISTENING_EVENT_DATA_AVAILABLE) {
                        byte[] newData = new byte[comPort.bytesAvailable()];
                        comPort.readBytes(newData, newData.length);
                        String receivedData = bytePrintAsString(newData);
                        log.info("Received data: " + receivedData);
                        uartQueue.add(receivedData);
                    }
                }
            });

            // 进入一个无限循环以持续监听串口，类似渲染主线程的守护线程
            while (true) {
                // 可以添加一些逻辑以退出循环，例如通过标志位控制
            }
        } else {
            log.error("Failed to open the serial port: " + comPort.getSystemPortName());
        }
    }

    public static String bytePrintAsString(byte [] byteArray) {
        StringBuilder hex = new StringBuilder();
        for (byte b : byteArray) {
            hex.insert(0, Integer.toHexString(b & 0xFF));
            if (hex.length() == 1) {
                hex.insert(0, '0');
            }
        }
        return hex.toString();
    }

    public void PortInit(Logger log){
        // 获取所有可用串口
        SerialPort[] ports = SerialPort.getCommPorts();
        // 打印所有可用串口的信息
        log.info("Available Ports:");
        for (SerialPort port : ports) {
            log.info(port.getSystemPortName());
        }

        try {
//            COM = "COM1";
            comPort = SerialPort.getCommPort(COM);
            comPort.openPort();
            if(comPort.isOpen()){
                log.info(COM+" is open");
            }else {
                log.error(COM+" is not open");
            }
        }catch (Exception e) {
            log.warn(COM+" open failed.Now try to open COM2");
            COM = "COM2";
            comPort = SerialPort.getCommPort(COM);
        }

        // 设置串口参数，如波特率、数据位、停止位和校验位
        comPort.setBaudRate(BaudRate);
        comPort.setNumDataBits(NumDataBits);
        comPort.setNumStopBits(steNumStopBits);
        comPort.setParity(SerialPort.NO_PARITY);
        // 设置串口的读取超时时间
        comPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_BLOCKING, 1000, 1000);

    }

    // 关闭串口
    public void ClosePort(SerialPort comPort){
        if(comPort.isOpen()){
            comPort.closePort();
        }
    }

//    public static void main(String[] args) {
//        Logger log = LoggerFactory.getLogger(SerialManager.class);
//        Druid druid = new Druid(log);
//        Queue<String> uartQueue = new LinkedBlockingQueue<>();
//        SerialManager Manager = new SerialManager(log,uartQueue,druid);
//        Sender sender = new Sender(Manager.comPort,log);
//        sender.Spring2Uart("hey");
//    }
}


