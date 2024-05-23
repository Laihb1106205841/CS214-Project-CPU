package chip.southbridge.Web;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class WebService {

    @GetMapping("/page")
    public String getMainPage() {
        return "index"; // 返回 index.html 页面
    }

    @GetMapping("/OJ")
    public String getOJPage() {
        return "OJ"; // 返回 OJ.html 页面
    }

    @GetMapping("/Navigate")
    public String getNavigatePage() {
        return "Navigate"; // 返回 OJ.html 页面
    }
}
