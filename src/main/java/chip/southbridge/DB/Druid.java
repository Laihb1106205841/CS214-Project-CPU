package chip.southbridge.DB;

import chip.southbridge.UART.SerialManager;
import com.alibaba.druid.pool.DruidDataSource;
import lombok.Getter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

@Getter
public class Druid {

    protected DruidDataSource dataSource;

    @Autowired
    Logger log;
    public Druid(Logger log) {
        this.log = log;
        // declare druid connection pool
        this.dataSource = new DruidDataSource();

        dataSource.setInitialSize(2);//druidConfig.getInitialSize()
        dataSource.setMinIdle(2);//druidConfig.getMinIdle()
        dataSource.setMaxActive(4);//druidConfig.getMaxActive()
        dataSource.setMaxWait(1000);//druidConfig.getMaxWait()

        /* ----------------------------Connection------------------------- */
        dataSource.setDriverClassName("org.postgresql.Driver");
        dataSource.setUsername("postgres");//
        dataSource.setPassword("123456");//
        dataSource.setUrl("jdbc:postgresql://localhost:5432/postgres");
        CreateTable();
    }

    // 插入数据到Mem_Co表
    public void insertData(int addr, int val) throws SQLException {
        Connection connection = dataSource.getConnection();
        String sql = "INSERT INTO mem (address, value) VALUES (?, ?)";

        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, addr);
            statement.setInt(2, val);

            int rowsInserted = statement.executeUpdate();
            if (rowsInserted > 0) {
                log.info("insert address "+addr+" value "+val+" into memory success");
            }
        }
    }


    public void CreateTable(){
        String createTableSQL = "CREATE TABLE IF NOT EXISTS mem ("
                + "address int ,"
                + "value int"+
                ")";
        try
        {
            Connection connection = dataSource.getConnection();
            Statement query = connection.createStatement();
            // 执行创建表的 SQL 语句
            query.executeUpdate(createTableSQL);
            log.info("fetch database success");
        } catch (SQLException e) {
            log.error("fail to fetch database table");
        }
    }






    public static void main(String[] args) throws Exception{
        Logger log = LoggerFactory.getLogger(SerialManager.class);
        Druid d = new Druid(log);
//        // declare druid connection pool
//        DruidDataSource dataSource = new DruidDataSource();
//
//        dataSource.setInitialSize(3);//druidConfig.getInitialSize()
//        dataSource.setMinIdle(3);//druidConfig.getMinIdle()
//        dataSource.setMaxActive(3);//druidConfig.getMaxActive()
//        dataSource.setMaxWait(1000);//druidConfig.getMaxWait()
//
//        /* ----------------------------Connection------------------------- */
//        // loads the jdbc driver, here we use pgsql
//        // if the db is mysql, the string will be "com.mysql.cj.jdbc.Driver", etc
//
//        dataSource.setDriverClassName("org.postgresql.Driver");
//        dataSource.setUsername("postgres");// replace "wwy" by your User name
//        dataSource.setPassword("123456");//repalce
//        dataSource.setUrl("jdbc:postgresql://localhost:5432/postgres");
//
//        // test 3: change the max pool size and initial pool size
////        /*
//        dataSource.setInitialSize(3);
//        dataSource.setMaxActive(3);
////        *
//
//
////        Connection connection = dataSource.getConnection();
////        System.out.println(connection.getClass().getName());    // Test connection statement
////        connection.close();
//        poolStatus(dataSource);
//
//        /* */
//        // inner proxy mechanism
////        Object inner= getConnectionInner(connection);
////        if (inner != null)
////            System.out.println(inner.getClass().getName());
//
//
//        // test 1: add one connection, watch the Idle/busy/all num
//        /**/
//        Connection connection1 = dataSource.getConnection();
//        System.out.println(connection1.getClass().getName());
////        System.out.println(connection==connection1);
//        poolStatus(dataSource);
//
//
//
//        // test 2: add two more connections, watch the all num
//        /**/
//        Connection connection2 = dataSource.getConnection();
////        System.out.println(connection==connection2);
//        poolStatus(dataSource);
//        Connection connection3 = dataSource.getConnection();
////        System.out.println(connection==connection3);
//        poolStatus(dataSource);
//
//
//        /* ----------------------------Get Statement------------------------- */
//        //poolStatus(dataSource);
//
//
//        /* ----------------------------Query------------------------- */
//        /**/
//        String sql_query = "insert into digital_logic_log(ip,fpga,messagetype,message,time) values ('127.0.0.1',1,'DruidTest','TestSucceed','2023/12/8')";
//        try {
//            /* statement */
//            Statement query = connection1.createStatement();
//            ResultSet result = query.executeQuery(sql_query);
//
////            /* prestatement */
////            PreparedStatement ps_query =connection.prepareStatement(sql_query);
////            ResultSet resultSet = ps_query.executeQuery();
//
////            poolStatus(dataSource);
//
//        }catch (Exception e){
//            e.printStackTrace();
//        }
//
    }

    public static Object getConnectionInner(Object connection){
        Object result = null;
        Field field = null;
        try {
            field = connection.getClass().getDeclaredField("traceEnable");
            field.setAccessible(true);
            result = field.get(connection);
        }catch (Exception e){
//            e.printStackTrace();
        }
        return result;
    }

    public static void poolStatus(DruidDataSource dataSource) {
        System.out.println("Busy Num " + dataSource.getActiveCount());
        System.out.println("Closed Num" + dataSource.getCloseCount());
        System.out.println("All Num" + dataSource.getConnectCount());
    }

}
