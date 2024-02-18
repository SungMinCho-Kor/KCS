//
//  FetchStoreIDRepository.swift
//  KCS
//
//  Created by 조성민 on 2/18/24.
//

import RxSwift

protocol FetchStoreIDRepository {
    
    var storage: StoreIDStorage { get }
    
    func fetchStoreID() -> Int?
    
}
