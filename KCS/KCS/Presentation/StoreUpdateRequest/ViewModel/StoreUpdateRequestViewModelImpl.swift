//
//  StoreUpdateRequestViewModelImpl.swift
//  KCS
//
//  Created by 조성민 on 2/17/24.
//

import RxRelay

final class StoreUpdateRequestViewModelImpl: StoreUpdateRequestViewModel {
    
    let typeWarningOutput = PublishRelay<Void>()
    let typeEditEndOutput = PublishRelay<Void>()
    let contentWarningOutput = PublishRelay<Void>()
    let contentEditEndOutput = PublishRelay<Void>()
    let contentErasePlaceHolder = PublishRelay<Void>()
    let contentFillPlaceHolder = PublishRelay<Void>()
    
    func action(input: StoreUpdateRequestViewModelInputCase) {
        switch input {
        case .typeInput(let text):
            typeInput(text: text)
        case .contentEndEditing(let text):
            contentEndEditing(text: text)
        case .contentWhileEditing(text: let text):
            contentWhileEditing(text: text)
        }
    }
    
}

private extension StoreUpdateRequestViewModelImpl {
    
    func typeInput(text: String) {
        if text.isEmpty {
            typeWarningOutput.accept(())
        } else {
            typeEditEndOutput.accept(())
        }
    }
    
    func contentEndEditing(text: String) {
        if text.isEmpty {
            contentWarningOutput.accept(())
        } else {
            contentEditEndOutput.accept(())
        }
    }
    
    func contentWhileEditing(text: String) {
        if text.isEmpty {
            contentFillPlaceHolder.accept(())
        } else {
            contentErasePlaceHolder.accept(())
        }
    }
    
}
