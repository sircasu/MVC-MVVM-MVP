//
//  SceneDelegate.swift
//  mvc-mvvm-mvp
//
//  Created by Matteo Casu on 07/12/25.
//

import UIKit
import MVC
import MVVM

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let vc = MVC.TestVC()
        
        
        window?.rootViewController = vc
        
        
        window?.makeKeyAndVisible()
    }




}

