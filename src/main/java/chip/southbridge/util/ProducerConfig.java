package chip.southbridge.util;

import org.slf4j.Logger;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ProducerConfig {

    @Autowired
    private RabbitTemplate rabbitTemplate;

    @Autowired
    private Logger log;

    @Bean
    public Queue queue() {
        return new Queue("h");
    }

    @Bean
    public CommandLineRunner send() {
        return args -> {
            rabbitTemplate.convertAndSend("hello", "Hello from RabbitMQ!");
            log.info("Message sent from RabbitMQ successfully.");
        };
    }
}

