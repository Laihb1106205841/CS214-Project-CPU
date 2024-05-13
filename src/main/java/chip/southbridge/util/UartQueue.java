package chip.southbridge.util;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Queue;
import java.util.concurrent.LinkedBlockingQueue;

@Configuration
public class UartQueue {
    Queue<String> uartQueue;

    public UartQueue(){
        uartQueue = new LinkedBlockingQueue<>();
    }

    @Bean
    public Queue<String> getUartQueue() {
        return uartQueue;
    }
}
