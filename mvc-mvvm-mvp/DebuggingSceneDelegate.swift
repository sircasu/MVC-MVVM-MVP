//
//  DebuggingSceneDelegate.swift
//  mvc-mvvm-mvp
//
//  Created by Matteo Casu on 16/07/2026.
//
#if DEBUG
import UIKit
import Core
import MVP

class DebuggingSceneDelegate: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _ = (scene as? UIWindowScene) else { return }

        // Any Debugging/Test configuration
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }


    override func makeRemoteClient() -> HTTPClient {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return AlwaysFailingHTTPClient()
        }
    
        return super.makeRemoteClient()
    }
}

private class AlwaysFailingHTTPClient: HTTPClient {
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
    
    func perform(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) ->  HTTPClientTask {
        completion(.failure(NSError(domain: "test", code: 0)))
        return Task()
    }
    
    
}
#endif
