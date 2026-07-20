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

public protocol WindowProtocol: AnyObject {
    var rootViewController: UIViewController? { get set }
    func makeKeyAndVisible()
}

extension UIWindow: WindowProtocol {}


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    convenience init(httpClient: HTTPClient) {
        self.init()
        self.httpClient = httpClient
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
                
        configureWindow(window: window)
        
        self.window = window
    }
    
    
    func configureWindow(window: WindowProtocol) {
 
//        window = UIWindow(windowScene: windowScene)
//        
//        let url = URL(string: "https://fakestoreapi.com/products")!
//        
//        let session = URLSession(configuration: .ephemeral)
//        let client = URLSessionHTTPClient(session: session)
//        
//        let productsLoader = RemoteProductsLoader(url: url, client: client)
//        let imageLoader = RemoteProductImageDataLoader(client: client)
//        
//        // MVP
//        let mvpVC = MVP.ProductsUIComposer.makeProductsUI(
//            productsLoader: productsLoader,
//            imageLoader: imageLoader
//        )
//        let mvpNC = UINavigationController(rootViewController: mvpVC)
//        mvpNC.tabBarItem = UITabBarItem(title: "MVP", image: nil, tag: 0)
//            
//        
//        // MVVM
//        let mvvmVC = MVVM.ProductsUIComposer.makeProductsUI(
//            productsLoader: productsLoader,
//            imageLoader: imageLoader
//        )
//        let mvvmNC = UINavigationController(rootViewController: mvvmVC)
//        mvvmNC.tabBarItem = UITabBarItem(title: "MVVM", image: nil, tag: 1)
//        
//                        
//        // MVC
//        let mvcVC = MVC.ProductsUIComposer.makeProductsUI(
//            productsLoader: productsLoader,
//            imageLoader: imageLoader
//        )
//        let mvcNC = UINavigationController(rootViewController: mvcVC)
//        mvcNC.tabBarItem = UITabBarItem(title: "MVC", image: nil, tag: 2)
//        
//        
//        let tb = UITabBarController()
//        
//        tb.viewControllers = [mvpNC, mvvmNC, mvcNC]
//        
//        window?.rootViewController = tb
//        
//        
//        window?.makeKeyAndVisible()

        
        let url = URL(string: "https://fakestoreapi.com/products")!
        

        let remoteClient = makeRemoteClient()
        let productsLoader = RemoteProductsLoader(url: url, client: remoteClient)
        let imageLoader = RemoteProductImageDataLoader(client: remoteClient)
        
        // MVP
        let mvpVC = ProductsUIComposer.makeProductsUI(
            productsLoader: productsLoader,
            imageLoader: imageLoader
        )
        
        let tb = UITabBarController()
        let mvpNC = UINavigationController(rootViewController: mvpVC)
        mvpNC.tabBarItem = UITabBarItem(title: "MVP", image: nil, tag: 0)
        
        tb.viewControllers = [mvpNC]
        
        window.rootViewController = tb


        window.makeKeyAndVisible()
    }


    func makeRemoteClient() -> HTTPClient {

        return httpClient
    }

}



