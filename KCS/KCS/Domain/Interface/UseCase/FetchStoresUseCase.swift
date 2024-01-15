//
//  FetchStoresUseCase.swift
//  KCS
//
//  Created by 조성민 on 1/15/24.
//

import RxSwift

protocol FetchStoresUseCase {
    
    var repository: StoreRepository { get }
    
    init(repository: StoreRepository)
    
    func execute(
        northWestLocation: Location,
        southEastLocation: Location
    ) -> Observable<Void>

}
