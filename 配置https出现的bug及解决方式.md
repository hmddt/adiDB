HTTPS 部署后常见 Bug 及解决方案总结
一、文档说明
本文档总结了 HTTPS 部署后（从 HTTP 迁移至 HTTPS）遇到的核心问题、报错信息、根因分析及完整解决方案，覆盖 Nginx 配置、跨域、资源加载、接口代理等关键场景，适用于前后端分离架构（前端 Vue + 后端接口 + Nginx 代理）。
二、核心 Bug 及解决方案
1. Bug 1：HTTPS 页面加载 HTTP 资源（混合内容错误）
1.1 报错现象
页面部署为 HTTPS 后，浏览器控制台提示：
Mixed Content: The page at 'https://xxx.com' was loaded over HTTPS, but requested an insecure resource 'http://xxx.com/pic/adi/xxx.webp'
图片、JS/CSS 等资源加载失败，页面样式错乱或功能失效。
1.2 根因分析
现代浏览器安全策略：禁止 HTTPS 页面加载 HTTP 资源（“混合内容”），直接拦截 HTTP 资源请求；
路径配置遗漏：原 HTTP 部署时的资源路径（http://xxx.com/pic/...）未同步改为 HTTPS 或相对路径。
1.3 解决方案
通过 Nginx 配置 location ^~ /pic/adi/，同时实现资源 HTTPS 访问、MIME 类型定义与跨域许可，配置如下：
location ^~ /pic/adi/ {
    alias /shujupan/PicStorage/adi/;  # 资源本地存储路径（固定为实际路径）
    expires 1y;  # 静态资源缓存 1 年，优化加载速度
    
    # 配置资源 MIME 类型，确保浏览器正确识别文件格式
    types {
        image/jpeg jpg jpeg;
        image/png png;
        image/webp webp;  
        image/gif gif;
        application/json json;  # 支持 JSON 文件访问
    }

    # 跨域配置，允许前端域名（https://www.tmliang.cn）访问资源
    add_header Access-Control-Allow-Origin https://www.tmliang.cn always;
    add_header Access-Control-Allow-Methods "GET, OPTIONS" always;  # 只允许 GET 和 OPTIONS 方法（JSON/图片资源常用）
    add_header Access-Control-Allow-Headers "Content-Type" always;  # 允许必要的请求头，适配前端请求格式
}

说明：此配置需放在 Nginx 的 HTTPS 服务器块（listen 443 ssl; 对应的 server 节点）内，确保资源通过 HTTPS 协议返回，同时解决跨域拦截问题。
2. Bug 2：后端接口无数据返回（前端请求 http://IP:端口 导致跨域 / CORS 错误）
2.1 报错现象
前端直接请求 http://IP:端口 形式的后端接口（如 http://121.37.88.191:8090/adi/gene）时，浏览器控制台提示：
Access to XMLHttpRequest at 'http://121.37.88.191:8090/adi/gene' from origin 'https://www.tmliang.cn' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.

接口状态码可能显示 200（后端已返回数据），但浏览器拦截响应导致前端无数据；或直接报 ERR_FAILED（混合内容 + 跨域双重拦截）。
2.2 根因分析
协议 + 地址双重跨域：前端页面为 HTTPS 协议（https://www.tmliang.cn），而接口为 HTTP 协议 + IP: 端口形式（http://121.37.88.191:8090），“协议不同 + 域名 / IP 不同 + 端口不同”，完全违反浏览器同源策略；
混合内容拦截：HTTPS 页面请求 HTTP 接口，浏览器先触发 “混合内容安全拦截”，即使后端配置跨域头，也可能因协议不安全被阻断。
2.3 解决方案（核心：Nginx 反向代理绕开 IP: 端口请求）
通过 Nginx 配置反向代理，将前端对 “代理路径 /adiapi/” 的请求转发至 http://121.37.88.191:8090/ 接口，让前端请求伪装成 “同域名 HTTPS 请求”，彻底解决跨域与混合内容问题：
步骤 1：Nginx 代理配置（放在 HTTPS 服务器块内）
# 代理 /adiapi/ 路径至后端 http://121.37.88.191:8090/ 接口
location /adiapi/ {
    # 转发目标：后端接口的 IP + 端口（固定为你的实际后端地址）
    proxy_pass http://121.37.88.191:8090/;
    
    # 传递真实请求信息，确保后端能正确识别请求来源
    proxy_set_header Host $host;  # 传递前端访问的域名（如 https://www.tmliang.cn）
    proxy_set_header X-Real-IP $remote_addr;  # 传递前端真实 IP 地址
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  # 传递代理链路 IP 列表
    proxy_set_header X-Forwarded-Proto $scheme;  # 传递请求协议（https），告知后端当前为 HTTPS 环境
    
    # 可选：配置代理超时，避免后端响应慢导致请求失败
    proxy_connect_timeout 5s;  # 连接后端超时时间
    proxy_send_timeout 10s;    # 发送请求到后端超时时间
    proxy_read_timeout 10s;    # 读取后端响应超时时间
}

步骤 2：修改前端请求路径
将前端代码中直接请求 http://121.37.88.191:8090/xxx 的路径，改为请求 Nginx 代理路径 /adiapi/xxx（与上述配置的 location /adiapi/ 对应），路径映射关系如下：
原错误请求路径（触发跨域）
修改后正确请求路径（同域名代理）
http://121.37.88.191:8090/adi/gene
/adiapi/adi/gene
http://121.37.88.191:8090/adi/json/list
/adiapi/adi/json/list

（可选优化）若前端需频繁请求该接口，可配置请求工具（如 Axios）的基础路径，简化后续请求写法（无需重复写 /adiapi/ 前缀）。
步骤 3：验证代理有效性
重启 Nginx 使配置生效：
sudo nginx -t  # 测试配置语法（无报错再继续）
sudo systemctl restart nginx  # 重启 Nginx（CentOS/Ubuntu）
# 或 sudo service nginx restart（旧系统）

前端触发接口请求，打开浏览器 “开发者工具→Network”：
查看请求的 Request URL 为 https://www.tmliang.cn/adiapi/adi/gene（同域名 HTTPS 协议，无混合内容风险）；
查看 Response 面板能正常显示后端返回数据，控制台无 CORS 报错或混合内容拦截提示，即代理配置成功。
3. Bug 3：JSON 筛选功能失效（本质为 JSON 资源跨域导致数据加载失败）
3.1 报错现象
前端请求 JSON 文件（如 /pic/adi/json/miRTarBase_SE_WR.json）时，控制台先报跨域错误：
Access to XMLHttpRequest at 'https://tmliang.cn/pic/adi/json/miRTarBase_SE_WR.json' from origin 'https://www.tmliang.cn' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.

跨域导致 JSON 数据加载失败（data 为 undefined），后续执行筛选功能时，控制台报数据未定义错误：
TypeError: Cannot read properties of undefined (reading 'filter')

3.2 根因分析
核心原因：JSON 资源跨域配置缺失
JSON 文件存储路径 https://tmliang.cn/pic/adi/json/ 与前端域名 https://www.tmliang.cn 属于子域名不同的跨域场景；
Nginx 未给 pic/adi/ 路径配置 Access-Control-Allow-Origin 等跨域响应头，浏览器拦截 JSON 资源请求，导致数据加载失败（data = undefined）；
筛选功能失效是跨域的直接连锁反应：因 JSON 数据未成功加载，前端执行 jsonData.filter() 时操作 undefined 数据，触发报错。
（注：前端 JS 筛选逻辑本身无问题，报错仅因跨域导致数据未加载，解决跨域后筛选功能可正常运行。）
3.3 解决方案（仅需配置 JSON 资源跨域）
通过 Nginx 为 pic/adi/ 路径配置跨域头，确保 JSON 数据能正常加载，跨域问题解决后，筛选功能即可恢复正常：
location ^~ /pic/adi/ {
    alias /shujupan/PicStorage/adi/;  # JSON 文件所在的本地存储目录
    expires 1y;  # 静态资源缓存优化，减少重复请求
    
    # 配置 JSON 类型识别，避免浏览器误判文件格式
    types {
        application/json json;  # 关键：确保 .json 后缀文件被识别为 JSON 类型
        image/jpeg jpg jpeg;    # 保留图片等其他资源的类型配置
        image/png png;
        image/webp webp;
        image/gif gif;
    }

    # 核心跨域配置：允许前端域名访问 JSON 资源
    add_header Access-Control-Allow-Origin https://www.tmliang.cn always;  # 明确前端域名，避免通配符
    add_header Access-Control-Allow-Methods "GET, OPTIONS" always;  # JSON 资源仅需 GET/OPTIONS 方法
    add_header Access-Control-Allow-Headers "Content-Type" always;  # 适配前端请求头格式
}

配置验证步骤
重启 Nginx 使配置生效：
sudo nginx -t  # 测试配置语法是否正确（无报错再执行重启）
sudo systemctl restart nginx  # 重启 Nginx 服务

前端重新请求 JSON 文件：
打开浏览器 “开发者工具→Network”，查看 JSON 请求的 Request URL 为 HTTPS 协议；
查看 Response 面板能正常显示 JSON 数据，控制台无 CORS 报错；
此时执行筛选功能，因数据已成功加载，filter 方法可正常调用，筛选功能恢复。
三、HTTPS 部署关键注意事项
SSL 证书有效性：
必须使用可信机构颁发的证书（如 Let's Encrypt 免费证书），避免浏览器提示 “不安全”；自签证书仅适用于测试环境，生产环境禁用（会导致用户访问时触发安全警告）。
全链路 HTTPS 检查：
部署后通过浏览器「开发者工具 → Network → Protocol」筛选，确保所有资源（接口、图片、CDN 静态资源）的 Protocol 为 h2 或 https，无 http 资源残留（避免混合内容错误）。
跨域头配置规范：
避免使用 Access-Control-Allow-Origin: *：HTTPS 环境下，若前端请求携带 Cookie 或自定义头（如 Token），浏览器不支持通配符 *，需指定具体前端域名（如 https://www.tmliang.cn）；
多前端域名场景：可通过 Nginx 变量动态返回 Origin（配置示例：add_header Access-Control-Allow-Origin $http_origin always;），但需配合 Access-Control-Allow-Credentials: true 启用凭证传递。
Nginx 配置测试优先：
修改 Nginx 配置后，先执行 sudo nginx -t 测试语法正确性（避免配置错误导致服务不可用），无报错再重启服务：
sudo nginx -t  # 测试配置
sudo systemctl restart nginx  # 重启 Nginx（CentOS/Ubuntu）
# 或 sudo service nginx restart（旧系统）

浏览器缓存清除：
HTTPS 部署后，需提醒用户强制刷新页面（快捷键 Ctrl + Shift + R）清除 HTTP 缓存；若资源仍异常，可引导用户清理浏览器「历史记录 → 缓存数据」（避免旧缓存干扰新资源加载）。
四、总结
HTTPS 部署后的核心问题集中在 跨域（CORS）、资源路径（混合内容） 两大类，其中跨域是底层关键诱因（如 Bug 3 筛选失效本质为 JSON 资源跨域导致数据加载失败）。解决思路遵循 “先解决环境配置问题，再验证功能”：
混合内容问题：通过 Nginx 配置指定路径 HTTPS 访问或改用相对路径，确保所有资源通过 HTTPS 协议加载；
跨域问题：通过 Nginx 为资源路径（如 pic/adi/）或接口代理路径（如 adiapi/）配置 Access-Control-Allow-Origin 等头，或使用反向代理绕开跨域场景；
功能验证：环境配置完成后，仅需验证数据是否正常加载，无需修改前端业务逻辑（如筛选 JS 代码），数据加载正常后功能即可恢复。
通过本文档的方案，可高效解决 HTTPS 迁移中的高频问题，配置示例与操作步骤可直接复用至实际项目，降低部署难度与调试成本。
