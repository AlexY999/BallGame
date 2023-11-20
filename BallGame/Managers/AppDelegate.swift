//
//  AppDelegate.swift
//  BallGame
//
//  Created by Алексей on 18.11.2023.
//

import UIKit

import UIKit
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let url = URL(string: "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod") else {
            print("Invalid URL")
            return true
        }

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                    if let winnerURLString = json?["winner"], let winnerURL = URL(string: winnerURLString) {
                        UserDefaultsManager.saveWinnerURL(winnerURL)
                    }
                    if let loserURLString = json?["loser"], let loserURL = URL(string: loserURLString) {
                        UserDefaultsManager.saveLoserURL(loserURL)
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
            }
        }.resume()

        return true
    }
}
