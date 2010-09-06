/*
 *  Copyright 2010 Media Service Provider Ltd
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License./*
 *
 */
package com.msp.jsvc;

import org.apache.commons.daemon.Daemon;
import org.apache.commons.daemon.DaemonContext;
import org.apache.commons.daemon.DaemonController;
import org.apache.commons.daemon.support.DaemonLoader;
import org.jruby.Ruby;
import org.jruby.RubyInstanceConfig;
import org.jruby.RubyModule;
import org.jruby.exceptions.MainExitException;
import org.jruby.exceptions.RaiseException;
import org.jruby.javasupport.JavaEmbedUtils;

/**
 * Implements commons Daemon to bootstrap a jruby instance, initialize your
 * application, and then tell the application to start doing whatever it does.
 * @author Nick Griffiths <nicobrevin@gmail.com>
 */
public class JRubyDaemon implements Daemon {

  private static final String PROP_MODULE_NAME = "jruby.daemon.module.name";
  private static final String DAEMON = "Daemon";
  private Ruby runtime;
  private Thread thread;
  private RubyModule appModule;
  private boolean debug;
  private RubyModule daemon;
  private String appModuleName;
  private RubyInstanceConfig rubyConfig;
  private DaemonController controller;

  /**
   */
  public void init(DaemonContext arguments) throws Exception {
    this.controller = arguments.getController();

    try {
      initParams();
      initJRuby(arguments);

      loadScript();
      checkDaemon();
    } catch (Exception e) {
      // TODO the fail method should be supported in the next jsvc
      // version
      this.controller.fail("Some kind of error", e);
      throw e;
    }

  }

  private void loadScript() {
    if (debug) log("Executing script from: " + rubyConfig.getScriptFileName());

    // boot her up. The script should yield control back to us so we
    // can give control back to jsvc once
    try {
      runtime.runFromMain(rubyConfig.getScriptSource(), rubyConfig.getScriptFileName());
    } catch (RaiseException e) {
      log("Script failed to execute: " + e.getException());
      throw e;
    } catch (RuntimeException e) {
      log("Error executing script: " + e);
      throw e;
    }

    appModule = runtime.getModule(appModuleName);
    if (appModule == null) { throw new RuntimeException("Couldn't get module '" + appModuleName + "' from JRuby runtime"); }
    daemon = (RubyModule) appModule.getConstantAt(DAEMON);
    if (daemon == null) { throw new RuntimeException("Couldn't get " + DAEMON + " module from " + appModuleName); }
  }

  private void initJRuby(DaemonContext arguments) {
 // mimicking startup from org.jruby.Main
    this.rubyConfig = new RubyInstanceConfig();
    rubyConfig.processArguments(arguments.getArguments());
    runtime = Ruby.newInstance(rubyConfig);
    Thread.currentThread().setContextClassLoader(runtime.getJRubyClassLoader());
  }

  private void initParams() throws Exception {
    this.debug = "true".equals(System.getProperty("JRubyDaemon.debug"));
    this.appModuleName = System.getProperty(PROP_MODULE_NAME);
    if (appModuleName == null) {
      throw new Exception("Property " + PROP_MODULE_NAME + " must be set");
    }
  }

  private String daemonName() {
    return this.appModuleName + "::" + DAEMON;
  }

  public void start() throws Exception {
    // do it in a separate thread, because jsvc expects this method to return.
    thread = new Thread("jsvc-daemon-main") {
      @Override
      public void run() {
        if (debug) log("thread " + thread + " starting daemon...");
        daemon.callMethod("start");
      }
    };
    thread.setDaemon(false);
    thread.setContextClassLoader(runtime.getJRubyClassLoader());
    thread.start();
  }

  public void stop() throws Exception {
    if (debug) log("Stopping...");
    try {
      daemon.callMethod("stop");
    } catch (MainExitException e) {
    }
    if (debug)
      log("Stopped");
  }

  public void destroy() {
    runtime.tearDown();
  }

  private void checkDaemon() {
 // check it has come up OK
    Boolean wasSetup =
      (Boolean) JavaEmbedUtils.rubyToJava(runtime, daemon.callMethod("setup?"), Boolean.class);

    if (!wasSetup.booleanValue()) {
      throw new RuntimeException("Script did not call " + daemonName() + ".setup");
    }

  }

  private void log(String msg) {
    System.err.println("JRubyDaemon: " + msg);
  }

}
