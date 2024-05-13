package chip.southbridge.util;

import chip.southbridge.UART.SerialManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class logger {
    private static final Logger log = LoggerFactory.getLogger(SerialManager.class);

    public logger(){}

    @Bean
    public Logger getLog() {
        return log;
    }
}
