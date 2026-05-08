## CF优选IP

- **优选工具：** [xinyitang3/cfnb](https://github.com/xinyitang3/cfnb/tree/main) 
- **测试网络：** 广东电信5G 
- **订阅链接：** `https://raw.githubusercontent.com/httSlayQueen/cf/refs/heads/main/ip.txt`

---

## 订阅转换模板

支持**CloudFlare CDN分流**、**国外AI分流**、**Steam分流**（下载走直连）、**广告过滤**（其实浏览器用ADGurad插件更好），刚需`GEOIP`和`GEOSITE`数据库，请确保代理软件支持。

- **OpenClash设置方案：** [Aethersailor daddy 倾囊相授](https://github.com/Aethersailor/Custom_OpenClash_Rules/wiki)
- **模板链接：** `https://raw.githubusercontent.com/httSlayQueen/cf/refs/heads/main/OpenClash_CF.ini`


<details>

<summary>如果你想在装有OpenClash的软路由上部署优选工具，【请点击这段话】</summary>

## 以下内容仅供参考

进行以下设置可以让优选工具的流量绕过mihomo内核，否则会测出来各种类似 0.13ms 的离谱结果：

1. 在容器内部署优选工具，并固定容器IP（有许多带python3的定时任务面板，比如 [linzixuanzz/daidai-panel](https://github.com/linzixuanzz/daidai-panel)）
2. 在 `OpenClash --> 插件设置 --> 来源流量访问控制` 内新增规则，“内部地址”选择容器IP，端口填 `0-65535`，对象选择“ACCEPT”，保存设置

由于`Fake-IP 模式`下，OpenClash会将测速网站解析成Fake-IP，导致测速流量进入mihomo内核，分流不正确的话测速流量会走代理，得到错误的结果。为此还应该进行如下步骤：

3. 在 `OpenClash --> 复写设置 --> DNS设置 --> Fake-IP-Filter-Mode` 下添加黑名单 `api.090227.xyz` 和 `speed.cloudflare.com`（这俩域名是优选工具配置文件内的检验域名和测速域名）
4. 保存并应用

</details>

---

### 参考

[HandsomeMJZ/cfip](https://github.com/HandsomeMJZ/cfip)

[cmliu/ACL4SSR](https://github.com/cmliu/ACL4SSR)

[Aethersailor/Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules)
