//
//  ViewController.swift
//  AppleLogin
//
//  Created by 염성필 on 2023/12/28.
//

import UIKit
import AuthenticationServices // 애플 로그인하려면 import해야하는 프레임 워크

/*
 소셜 로그인 ( 페북 / 구글 / 카카오 ... )시 애플 로그인 구현 필수 ( 미 구현 시 리젝 사유 )
 ( ex. 인스타그램은 페북거니까 애플 로그인 붙이지 않아도 됌 )
 자체 로그인만 구성되어 있다면, 애플 로그인 구현이 필수는 아님
 
 => 개인 개발자 계정이 있어야 테스트 가능
 */

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGreen
    }
}




class ViewController: UIViewController {
    
    
    @IBOutlet var appleLoginButton: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonClicked), for: .touchUpInside)
        
    }
    
    @IBAction func faceIDButtonClicked(_ sender: UIButton) {
        
        if AuthenticationManager.shared.checkPolicy() {
            AuthenticationManager.shared.auth()
        } else {
            let alert = UIAlertController(title: "생체 인증을 사용할 수 없습니다.", message: "현재 디바이스는 생체 인증을 지원하지 않습니다.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "확인", style: .default)
            alert.addAction(ok)
            present(alert, animated: true)
        }
        
    }
    
    
    
    @objc func appleLoginButtonClicked() {
        // 애플 로그인 관련 제공해주는 Provider
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest() // <- 나 애플로그인 할게 요청 보내기
        request.requestedScopes = [.email, .fullName]
        
        // 아래에서 위로 뜨는 모션에 들어가는 요소
        let controller = ASAuthorizationController(authorizationRequests: [request])
        // 애플 로그인 성공 실패에 따른 Delegate 제공 <- 로직 영역
        controller.delegate = self
        // Presentation에 대한 영역 Delegate
        controller.presentationContextProvider = self
        controller.performRequests() // start
    }
    
    private func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
    func base64UrlDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    
    func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
            return nil
        }
        
        return payload
    }
    
}
extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window! // 항상 같은 UI로 띄울수 있게 설정
    }
    
    
}

extension ViewController: ASAuthorizationControllerDelegate {
    
    // 애플로 로그인 성공한 경우 -> 메인 페이지로 이동 등...
    // 처음 시도 : 계속, Email, fullName 제공 ( 사용자 성공 하면 Email name을 서버로 보내지만 실패하면 nil값 떨어짐... 어떻게 해결 할 수 있을까?
    // 토큰안에 정보가 숨어있음 !!
    // 두번째 시도 : 로그인할래요? Email, fullName nil 값으로 온다.
    // 사용자 정보를 계속 제공해주지 않는다! 최초에만 제공
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("로그인 성공")
        // 성공한 인증 로직에 의한 switch문
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            print("appleIDCredential - \(appleIDCredential)")
             
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            //            let token = appleIDCredential.identityToken
            
            guard let token = appleIDCredential.identityToken,
                  let tokenToString = String(data: token, encoding: .utf8) else {
                print("Token Error")
                return
            }
            
            print(userIdentifier)
            print(fullName ?? "NO fullName")
            print(email ?? "NO Email")
            print(tokenToString)
            
            // 이메일이 비어있다면 decoding
            if email?.isEmpty ?? true {
                let result = decode(jwtToken: tokenToString)["email"] as? String ?? ""
                print(result) // UserDefaults에 업데이트
            }
            
            // 이메일, 토큰, 이름 -> USerDefaults & API로 서버에 POST
            // 서버에 Reqeust 후 Response를 받게되면, 성공 시 화면 전환
            UserDefaults.standard.set(userIdentifier, forKey: "User")
            
            
            DispatchQueue.main.async {
                
                self.present(MainViewController(), animated: true)
                
            }
            
            
        case let passwordCredential as ASPasswordCredential:
            // iCloud 키체인에 정보를 가지고옴
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print(username, password)
            
        default: break
        }
    }
    
    // 애플로 로그인 실패한 경우
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("로그인 실패 \(error.localizedDescription)")
    }
    
}

