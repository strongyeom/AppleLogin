//
//  SceneDelegate.swift
//  AppleLogin
//
//  Created by 염성필 on 2023/12/28.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        
        guard let user = UserDefaults.standard.string(forKey: "User") else {
            print("NO User")
            return
        }
        
        // UD에 저장한 데이터를 애플에 물어보기
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        // 인증이 유효한 사용자인지 판별
        appleIDProvider.getCredentialState(forUserID: user) { credentialState, error in
            switch credentialState {
            case .revoked: // 탈퇴
                print("Revoked")
            case .authorized: // 인증된 사용자일 경우에만 Main으로
                DispatchQueue.main.async { // getCredentialState: 백그라운드에서 동장하기 때문에 Main쓰레드에서 동작해야함
                    let window = UIWindow(windowScene: windowScene)
                    window.rootViewController = MainViewController()
                    self.window = window
                    window.makeKeyAndVisible()
                }
            default : print("NOT FOUND")
            }
        }
        
        
        
        
        
        
        
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

