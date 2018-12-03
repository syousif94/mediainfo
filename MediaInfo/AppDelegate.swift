//
//  AppDelegate.swift
//  MediaInfo
//
//  Created by Sammy Yousif on 11/25/18.
//  Copyright © 2018 Sammy Yousif. All rights reserved.
//

import Cocoa
import NotificationCenter
import CoreFoundation

extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

struct Config: Codable {
    let playPause: [String]
    let mediaInfo: [String]
    let mediaIcon: [String]
    let baseURL: String
    
    init(
        playPause: [String] = ["2648263D-29F4-4002-B38C-FA241F9C5F80"],
        mediaInfo: [String] = ["B6BC03C6-54CD-4D45-9F20-10B966F28349", "6CFC1A77-735C-4247-B8A7-5B390694D2E9"],
        mediaIcon: [String] = ["BD18BFAD-7EFC-44C5-9304-DB8CA53120D7", "DE1739EC-59DD-4070-8238-C15ACB5478AC"],
        baseURL: String = "http://127.0.0.1:12345/"
    ) {
        self.playPause = playPause
        self.mediaInfo = mediaInfo
        self.mediaIcon = mediaIcon
        self.baseURL = baseURL
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    var config = Config()
    
    var playing = false {
        didSet {
            if playing != oldValue {
                let iconData = playing ? pauseIcon : playIcon
                
                for uuid in config.playPause {
                    let urlString = "\(config.baseURL)update_touch_bar_widget/?uuid=\(uuid)&text=play&icon_data=\(iconData)"
                    guard let url = URL(string: urlString) else { return }
                    
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                    }
                    task.resume()
                }
            }
        }
    }
    
    var mediaText = "" {
        didSet {
            if mediaText != oldValue {
                for uuid in config.mediaInfo {
                    let urlString = "\(config.baseURL)update_touch_bar_widget/?uuid=\(uuid)&text=\(mediaText)"
                    guard let url = URL(string: urlString) else { return }
                    
                    let task = URLSession.shared.dataTask(with: url)
                    task.resume()
                }
                
                refreshArtwork()
            }
        }
    }
    
    var appName: String?
    
    func refreshArtwork() {
        for uuid in config.mediaIcon {
            if let app = appName, app == "iTunes" {
                if self.playing {
                    let urlString = "\(config.baseURL)refresh_widget/?uuid=\(uuid)"
                    guard let url = URL(string: urlString) else { return }
                    
                    let task = URLSession.shared.dataTask(with: url)
                    task.resume()
                }
                else {
                    let urlString = "\(config.baseURL)refresh_widget/?uuid=\(uuid)"
                    guard let url = URL(string: urlString) else { return }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.8) {
                        let task = URLSession.shared.dataTask(with: url)
                        task.resume()
                    }
                }
            }
            else if let app = appName,
                let path = NSWorkspace.shared.fullPath(forApplication: app),
                let icon = NSWorkspace.shared.icon(forFile: path).base64String,
                mediaText.count > 0 {
                let text = uriEncode(string: " ")!
                let urlString = "\(config.baseURL)update_touch_bar_widget/?uuid=\(uuid)&text=\(text)&icon_data=\(icon)"
                guard let url = URL(string: urlString) else { return }

                let task = URLSession.shared.dataTask(with: url)
                task.resume()
            }
            else {
                let text = uriEncode(string: "")!
                let urlString = "\(config.baseURL)update_touch_bar_widget/?uuid=\(uuid)&text=\(text)"
                guard let url = URL(string: urlString) else { return }
                
                let task = URLSession.shared.dataTask(with: url)
                task.resume()
            }
        }
    }
    
    func uriEncode(string: String?, newline: Bool = false) -> String? {
        guard let string = string else { return nil }
        
        let line = newline ? "\n\(string)" : string
        
        return line.replacingOccurrences(of: "&", with: "and").replacingOccurrences(of: ".", with: "").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }

    @objc func onChange(_ notification: Notification) {
        guard let media = notification.object as? NowPlaying else { return }
        
        print("\n")
        print("title: ", media.title)
        print("artist: ", media.artist)
        print("playing: ", media.playing)
        print("\n")
        
        var text = ""
        
        let maxLength = 48
        
        if let title = uriEncode(string: media.title?.trunc(length: maxLength)) {
            text += title
            
            if let bundle = media.appBundleIdentifier {
                print("bundle: ", bundle)
                if let path = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundle) {
                    print("path: ", path)
                    let name = FileManager.default.displayName(atPath: path.absoluteString).replacingOccurrences(of: ".app", with: "")
                    appName = name
                }
                else {
                    switch bundle {
                    case "com.apple.WebKit.WebContent":
                        appName = "Safari"
                    default:
                        appName = nil
                        break
                    }
                }
            }
            
            if let artist = uriEncode(string: media.artist, newline: true) {
                text += artist
            }
            else if let name = uriEncode(string: appName, newline: true) {
                let urlScript = """
                    set str to "" as string
                    if ((str is equal to str) and (application "Safari" is running)) then
                        tell application "Safari"
                            repeat with w in windows
                                tell w
                                    if visible is true then
                                        repeat with t in tabs
                                            tell t
                                                if visible is true then
                                                    set tab_url to URL
                                                    return tab_url
                                                end if
                                            end tell
                                        end repeat
                                    end if
                                end tell
                            end repeat
                        end tell
                    end if
                    return str
                """
                var error: NSDictionary?
                if let scriptObject = NSAppleScript(source: urlScript) {
                    if let output: NSAppleEventDescriptor = scriptObject.executeAndReturnError(&error),
                        let urlString = output.stringValue,
                        let url = URL(string: urlString)?.host?.split(separator: ".").dropLast().last {
                        let host = String(url).lowercased()
                        if let title = media.title {
                            var splitTitle = title.split(separator: " ").filter { String($0).lowercased() != host }
                            if let last = splitTitle.last, last.count == 1 {
                                splitTitle = Array(splitTitle.dropLast())
                            }
                            if let joined = uriEncode(string: splitTitle.joined(separator: " ").trunc(length: maxLength)) {
                                text = joined
                            }
                        }
                        if let host = uriEncode(string: host.capitalized, newline: true){
                            text += host
                        }
                    } else {
                        if (error != nil) {
                            print("error: \(error)")
                        }
                        text += name
                    }
                }
            }
            
            mediaText = text
        }
        else {
            mediaText = ""
        }
        
        self.playing = media.playing
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let _ = NowPlaying.sharedInstance()
        let changeNotification = Notification.Name("NowPlayingInfo")
        NotificationCenter.default.addObserver(self, selector: #selector(onChange(_:)), name: changeNotification, object: nil)
        
        let stateNotification = Notification.Name("NowPlayingState")
        NotificationCenter.default.addObserver(self, selector: #selector(onChange(_:)), name: stateNotification, object: nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

