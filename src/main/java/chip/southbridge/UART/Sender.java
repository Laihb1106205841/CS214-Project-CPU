package chip.southbridge.UART;

import com.fazecast.jSerialComm.SerialPort;
import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.OutputStream;
import java.util.Arrays;


@Component
public class Sender {
    public SerialPort comPort ; // 指定COM端口
    Logger log;


    @Autowired
    public Sender(SerialPort comPort, Logger log){
        this.comPort = comPort;
        this.log = log;
    }

    public void Spring2Uart(String SendData){
        if (!comPort.openPort()) {
            log.error("Serial not open");
            return;
        }
        if(SendData==null){
            log.error("Your data is null!");
            return;
        }

        // 使用正则表达式 \\s* 匹配一个或多个空格，| 表示或，逗号会被替换为空格
        String[] sending = SendData.replaceAll("\\s*,\\s*|\\s+", " ").split("\\s+");

        log.info("Try to send to UART: " + Arrays.toString(sending));

        byte[] dataBytes = hexStringsToByteArray(sending);


        OutputStream outputStream = comPort.getOutputStream();

        try {
            outputStream.write(dataBytes); // 将数据写入串口
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

    }

    public static byte[] hexStringsToByteArray(String[] hexStrings) {
        StringBuilder concatenatedHex = new StringBuilder();
        // 将字符串数组中的所有字符串连接起来
        for (String hex : hexStrings) {
            concatenatedHex.append(hex);
        }
        // 调用现有的方法将连接后的字符串转换为字节数组
        return hexStringToByteArray(concatenatedHex.toString());
    }


    public static byte[] hexStringToByteArray(String hexString) {
        int len = hexString.length();
        byte[] byteArray = new byte[len / 2];
        for (int i = 0; i < len-1; i += 2) {
            byteArray[i / 2] = (byte) ((Character.digit(hexString.charAt(i), 16) << 4)
                    + Character.digit(hexString.charAt(i + 1), 16));
        }
        return byteArray;
    }

    public void Spring2Uart(int SendData){
        if (!comPort.openPort()) {
            log.error("not open");
            return;
        }

        byte dataBytes = intToByteArray(SendData);
        log.info("data byte:"+dataBytes);

        OutputStream outputStream = comPort.getOutputStream();

        try {
            outputStream.write(dataBytes); // 将数据写入串口
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        log.info("Try to send to UART: " + SendData);
    }


    /**
     * int到byte[] 由高位到低位
     * @param i 需要转换为byte数组的整行值。
     * @return byte数组
     * <a href="https://blog.csdn.net/alvinhuai/article/details/82790888">...</a>
     */
    public static byte intToByteArray(int i) {
        byte result = (byte) 00000000;
        if(i == 11){result = (byte) 0x99;}
        if(i == 12){result = (byte) 0xa9;}
        if(i == 13){result = (byte) 0xb9;}
        if(i == 14){result = (byte) 0xc9;}
        if(i == 15){result = (byte) 0xd9;}
        if(i == 16){result = (byte) 0xe9;}
        if(i == 17){result = (byte) 0xf9;}

        if(i == 21){result = (byte) 0x95;}
        if(i == 22){result = (byte) 0xa5;}
        if(i == 23){result = (byte) 0xb5;}
        if(i == 24){result = (byte) 0xc5;}
        if(i == 25){result = (byte) 0xd5;}
        if(i == 26){result = (byte) 0xe5;}
        if(i == 27){result = (byte) 0xf5;}

        if(i == 31){result = (byte) 0x93;}
        if(i == 32){result = (byte) 0xa3;}
        if(i == 33){result = (byte) 0xb3;}
        if(i == 34){result = (byte) 0xc3;}
        if(i == 35){result = (byte) 0xd3;}
        if(i == 36){result = (byte) 0xe3;}
        if(i == 37){result = (byte) 0xf3;}

        return result;
    }

}
