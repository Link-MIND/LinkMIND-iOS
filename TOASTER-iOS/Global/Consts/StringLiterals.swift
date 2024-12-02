//
//  StringLiterals.swift
//  TOASTER-iOS
//
//  Created by Gahyun Kim on 2024/01/01.
//

import Foundation

enum StringLiterals {
    enum Login {
        static let onboarding1 = "복사한 링크를\n손쉽게 저장하고"
        static let onboarding2 = "타이머를 설정하고\n링크를 리마인드 받아요"
        static let onboarding3 = "나의 링크 열람 현황까지\n한 눈에!"
        static let subTitle = "더 이상 링크를 태우지 마세요\n토스트 먹듯이 간편하게,"
        static let appleButton = "Apple 계정으로 시작하기"
        static let kakaoButton = "카카오 계정으로 시작하기"
    }
    
    enum Tabbar {
        static let home = "HOME"
        static let clip = "CLIP"
        static let timer = "TIMER"
        static let search = "SEARCH"
    }
    
    enum Button {
        static let okay = "확인"
        static let complete = "완료"
        static let delete = "삭제"
        static let close = "닫기"
        static let cancel = "취소"
        static let next = "다음"
        static let editTitle = "제목 편집"
    }
    
    enum Placeholder {
        static let search = "검색어를 입력해주세요"
        static let copyLink = "복사한 링크를 붙여 넣어 주세요"
        static let addClip = "새로운 클립의 이름을 입력해주세요"
    }
    
    enum ToastMessage {
        static let noticeMaxClip = "클립 추가는 15개까지 가능해요"
        static let completeAddClip = "클립 생성 완료!"
        static let completeEditClip = "클립 수정 완료!"
        static let completeDeleteClip = "클립 삭제 완료"
        static let completeDeleteLink = "링크 삭제 완료"
        static let completeReadLink = "링크 열람 완료"
        static let cancelReadLink = "링크 열람 취소"
        static let completeSetTimer = "타이머 설정 완료!"
        static let completeEditTimer = "타이머 수정 완료!"
        static let completeDeleteTimer = "타이머 삭제 완료"
        static let completeEditTitle = "제목 편집 완료"
        static let noticeSetTimer = "한 클립당 하나의 타이머만 설정 가능해요"
        static let noticeMaxTimer = "타이머는 최대 다섯 개까지 설정 가능해요"
    }
}
