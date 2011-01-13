package com.msp.procrun;

import com.msp.jsvc.JRubyDaemon;

public class JRubyService {

    private static JRubyDaemon daemon = new JRubyDaemon();

    public static void start(String[] arguments) {
        try {
            System.out.println("Daemon arguments: " + java.util.Arrays.asList(arguments).toString());
            daemon.init(arguments);
            daemon.start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void stop(String[] arguments) {
        try {
            daemon.stop();
            daemon.destroy();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
