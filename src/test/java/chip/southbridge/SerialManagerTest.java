package chip.southbridge;

import chip.southbridge.DB.Druid;
import chip.southbridge.UART.SerialManager;
import com.fazecast.jSerialComm.SerialPort;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.slf4j.Logger;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.util.Queue;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.*;

@ExtendWith(SpringExtension.class)
@SpringBootTest
public class SerialManagerTest {

    @MockBean
    private Logger log;

    @MockBean
    private Queue<String> uartQueue;

    @MockBean
    private SerialPort serialPort;

    private SerialManager serialManager;

    @BeforeEach
    public void setUp() {
        serialManager = new SerialManager(log, uartQueue,new Druid(log));
    }

    @AfterEach
    public void tearDown() {
        serialManager.ClosePort(serialPort);
    }

    @Test
    public void testOpenSerialPort() {
        assertNotNull(serialManager.OpenSerialPort());
    }



    @Test
    public void testSerialManagerInitialization() {
        assertNotNull(serialManager.comPort);
        verify(log, atLeastOnce()).info("Available Ports:");
        verify(log, atLeastOnce()).info(anyString());
//        verify(serialPort, atLeastOnce()).openPort();
//        verify(serialPort, atLeastOnce()).setBaudRate(anyInt());
//        verify(serialPort, atLeastOnce()).setNumDataBits(anyInt());
//        verify(serialPort, atLeastOnce()).setNumStopBits(anyInt());
//        verify(serialPort, atLeastOnce()).setParity(anyInt());
//        verify(serialPort, atLeastOnce()).setComPortTimeouts(anyInt(), anyInt(), anyInt());
    }

    @Test
    public void testMainMethod() {
        assertDoesNotThrow(() -> SerialManager.main(new String[]{}));
    }
}


