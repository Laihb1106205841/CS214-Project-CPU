package chip.southbridge.util;

public class DataTrans {

    public static String binaryToHex(String binaryString){
        int decimal = Integer.parseInt(binaryString, 2); // 解析为二进制数值
        return Integer.toHexString(decimal);
    }

    public static String binaryToDecimal(String binaryString){
        int decimal = Integer.parseInt(binaryString, 2);
        return String.valueOf(decimal);
    }
}
