package chip.southbridge.UART;

import chip.southbridge.DB.Druid;
import com.fazecast.jSerialComm.SerialPort;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RestController;

import java.util.Queue;
import java.util.concurrent.LinkedBlockingQueue;


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
public class SerialManager {

    String COM;
    final int BaudRate = 9600;
    final int NumDataBits = 8;
    final int steNumStopBits = 1;
    public SerialPort comPort ; // 指定COM端口

    Druid druid;

    @Bean
    public SerialPort OpenSerialPort() {
        return comPort;
    }

    @Autowired
    public SerialManager(Logger log, Queue<String> uartQueue,Druid druid){
        this.druid = druid;
        PortInit(log);
        Listener listener = new Listener(comPort,uartQueue,log);
        Thread t = new Thread(listener);
        t.start();

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
            COM = "COM1";
            comPort = SerialPort.getCommPort(COM);
            comPort.openPort();
            if(comPort.isOpen()){
                log.info("COM1 is open");
            }else {
                log.error("COM1 is not open");
            }
        }catch (Exception e) {
            log.warn("COM3 open failed.Now try to open COM2");
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

    public static void main(String[] args) {
        Logger log = LoggerFactory.getLogger(SerialManager.class);
        Druid druid = new Druid(log);
        Queue<String> uartQueue = new LinkedBlockingQueue<>();
        SerialManager Manager = new SerialManager(log,uartQueue,druid);
        Sender sender = new Sender(Manager.comPort,log);
        sender.Spring2Uart("hey");
    }
}


