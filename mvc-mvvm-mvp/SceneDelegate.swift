//
//  SceneDelegate.swift
//  mvc-mvvm-mvp
//
//  Created by Matteo Casu on 07/12/25.
//

import UIKit
import Core
import MVC
import MVVM
import MVP

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let url = URL(string: "https://fakestoreapi.com/products")!
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        
        let productsLoader = RemoteProductsLoader(url: url, client: client)
        let imageLoader = RemoteProductImageDataLoader(client: client)
        let vc = MVP.ProductsUIComposer.makeProductsUI(
            productsLoader: productsLoader,
            imageLoader: imageLoader
        )
        
        
        window?.rootViewController = vc
        
        
        window?.makeKeyAndVisible()
    }




}

