//
//  StoreUpdateRequestRepository.swift
//  KCS
//
//  Created by 조성민 on 2/18/24.
//

import RxSwift

protocol StoreUpdateRequestRepository {
    
    func storeUpdateReqeust(
        type: StoreUpdateRequestType,
        storeID: Int,
        content: String
    ) -> Observable<Void>
    
}
