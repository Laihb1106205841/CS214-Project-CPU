package chip.southbridge.UART;

import com.fazecast.jSerialComm.SerialPort;
import com.fazecast.jSerialComm.SerialPortDataListener;
import com.fazecast.jSerialComm.SerialPortEvent;
import org.slf4j.Logger;

import java.io.IOException;
import java.util.Queue;

public class Listener extends Thread{
    public SerialPort comPort ; // 指定COM端口

    private Queue<String> uartQueue;
    Logger log;


    public Listener(SerialPort comPort, Queue<String> uartQueue, Logger log){
        this.comPort = comPort;
        this.uartQueue = uartQueue;
        this.log = log;
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
                        String receivedData = BytePrintAsString(newData);
                        // 处理接收到的数据
                        log.info("接收到数据: " + receivedData);

                        // 在这里可以根据接收到的数据执行相应的逻辑
                        uartQueue.add(receivedData);

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

    public void exe(){
        Process process;
        try {
            process = Runtime.getRuntime().exec("cmd");
            process.wait();
        } catch (IOException | InterruptedException e) {
            throw new RuntimeException(e);
        }


//        第一行的“cmd”是要执行的命令，Runtime.getRuntime() 返回当前应用程序的Runtime对象，该对象的 exec() 方法指示Java虚拟机创建一个子进程执行指定的可执行程序，并返回与该子进程对应的Process对象实例。通过Process可以控制该子进程的执行或获取该子进程的信息。
//
//        第二条语句的目的等待子进程完成再往下执行。

    }
}
