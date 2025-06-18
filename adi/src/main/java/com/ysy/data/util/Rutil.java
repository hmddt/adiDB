package com.ysy.data.util;

import cn.hutool.log.StaticLog;
import org.rosuda.REngine.Rserve.RConnection;

public class Rutil {



    public static void runRScript(String rScript, String cmd) {
        StaticLog.info("R script = {}", rScript);
        StaticLog.info("cmd = {}", cmd);
        RConnection conn = null;
        try {
            // 获取连接
            conn = new RConnection();
            // 加载R文件
            conn.assign("rScript", rScript);//将r的路径添加
            conn.eval("source(rScript)");//根据路径加载R文件
            StaticLog.info("加载文件成功!");
            conn.eval(cmd);
            StaticLog.info("执行成功!");
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            assert conn != null;
            conn.close();
        }
    }
}
