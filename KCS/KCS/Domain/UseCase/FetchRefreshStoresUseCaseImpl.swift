//
//  FetchRefreshStoresUseCaseImpl.swift
//  KCS
//
//  Created by 조성민 on 1/15/24.
//

import RxSwift

struct FetchRefreshStoresUseCaseImpl: FetchRefreshStoresUseCase {
    
    let repository: StoreRepository
    
    func execute(
        requestLocation: RequestLocation,
        isEntire: Bool
    ) -> Observable<FetchStores> {
        return repository.fetchRefreshStores(requestLocation: requestLocation, isEntire: isEntire)
    }
    
}
