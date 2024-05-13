package chip.southbridge.Web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class WebService {

    @GetMapping("/page")
    public String getPage() {
        return "index"; // 返回 index.html 页面
    }
}
