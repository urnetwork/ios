//
//  AppDelegate.swift
//  URnetwork
//
//  Created by Stuart Kuentzel on 2024/12/30.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import URnetworkSdk

#if os(iOS)
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    override init() {
        SdkSetMemoryLimit(64 * 1024 * 1024)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        SdkFreeMemory()
    }
}

#elseif os(macOS)

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem?
    var window: NSWindow?
    private var isWindowVisible = true
    
    override init() {
        SdkSetMemoryLimit(64 * 1024 * 1024)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // macOS specific initialization
        setupMenuBar()
        setupStatusBar()
        
        setupCommandQHandler()
    }
    
    func applicationDidReceiveMemoryWarning(_ notification: Notification) {
        SdkFreeMemory()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.title = "URnetwork"
            // todo: use icon
            // button.image = NSImage(named: "StatusBarIcon")
        }
        
        let statusMenu = NSMenu()
        statusMenu.addItem(NSMenuItem(title: "Show", action: #selector(showWindow), keyEquivalent: ""))
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        statusItem?.menu = statusMenu
    }
    
    @objc private func showWindow() {
        NSApp.setActivationPolicy(.regular)
        window?.makeKeyAndOrderFront(nil)
        isWindowVisible = true
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showAboutPanel() {
        NSApplication.shared.orderFrontStandardAboutPanel(nil)
    }
    
    private func setupCommandQHandler() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self = self,
                  self.isWindowVisible,  // Only handle Command+Q when window is visible
                  event.modifierFlags.contains(.command),
                  event.charactersIgnoringModifiers == "q" else {
                return event
            }
            self.hideApp()
            return nil
        }
    }
    
    private func hideApp() {
        window?.orderOut(nil)
        isWindowVisible = false
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupMenuBar() {
        let mainMenu = NSMenu()
        
//        let appMenuItem = NSMenuItem()
//        mainMenu.addItem(appMenuItem)
//        
//        let appMenu = NSMenu()
//        appMenuItem.submenu = appMenu
//        
//        appMenu.addItem(withTitle: "About", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
//        appMenu.addItem(NSMenuItem.separator())
//        // Use a different key equivalent to avoid conflict with Command+Q
//        appMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "x")
//        
        NSApplication.shared.mainMenu = mainMenu
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // handle cleanup here
        // full VPN disconnect
    }
}

#endif

//func mainImmediateBlocking(callback: ()->Void) {
//    if Thread.isMainThread {
//        callback()
//    } else {
//        DispatchQueue.main.sync {
//            callback()
//        }
//    }
//}
