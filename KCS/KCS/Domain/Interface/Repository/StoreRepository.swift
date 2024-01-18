//
//  StoreRepository.swift
//  KCS
//
//  Created by 조성민 on 1/11/24.
//

import RxSwift

protocol StoreRepository {
    
    func fetchStores(
        northWestLocation: Location,
        southEastLocation: Location
    ) -> Observable<Void>
    
    func getStores(
        types: [CertificationType]
    ) -> [Store]
    
    func getStoreInfo(
        tag: UInt
    ) throws -> Store
    
}
