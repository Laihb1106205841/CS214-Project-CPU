package chip.southbridge.DB;

import org.slf4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.RestController;

@Configuration
@RestController
public class DruidController {
    Druid druid;
    Logger log;

    @Autowired
    public DruidController(Logger log){
        this.log = log;
        druid = new Druid(log);
    }

    @Bean
    public Druid getDruid(){
        return druid;
    }
}
