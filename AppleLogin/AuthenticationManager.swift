//
//  AuthenticationManager.swift
//  AppleLogin
//
//  Created by 염성필 on 12/29/23.
//

import Foundation
import LocalAuthentication // FaceID, TouchID

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    
    private init() { }
    // p.list에서 권한 설정하기
    // 정책 설정
    var selectedPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
    
    // 인증 로직
    func auth() {
        
        let context = LAContext()
        context.localizedCancelTitle = "FaceID 인증 취소"
        context.localizedFallbackTitle = "비밀번호로 대신 인증하기"
        
        // 권한 요청 및 인증 진행 절차
        context.evaluatePolicy(selectedPolicy, localizedReason: "페이스 아이디 인증이 필요합니다.") { result, error in
            // FaceID 결과는 메인 쓰레드 보장 X, DispatchQueue.main.async 필요
            // 인증 성공, 실패
            DispatchQueue.main.async {
                if result {
                    print("인증 성공")
                } else {
                    print("인증 실패")
                }
            }
            
            
            if let error {
                let code = error._code
                let laError = LAError(LAError.Code(rawValue: code)!)
                print("인증 에러 발생", laError)
            }
        }
    }
    
    // FaceId 쓸 수 있는 상태인지 여부 확인
    func checkPolicy() -> Bool {
        
        let context = LAContext()
        let policy: LAPolicy = selectedPolicy
        return context.canEvaluatePolicy(policy, error: nil)
        
    }
    
    // FaceID 변경 상태 확인
    func isFaceIDChanged() -> Bool {
        let context = LAContext()
        context.canEvaluatePolicy(selectedPolicy, error: nil)
        let state = context.evaluatedPolicyDomainState // 생체 인증에 대한 정보
        // 생체 인증 정보를 UserDefaults에 저장
        // 기존의 저장된 DomainState와 새롭게 변경된 DomainState를 비교 =>
        print(state)
        return false // 로직 추가
    }
    
    
}
