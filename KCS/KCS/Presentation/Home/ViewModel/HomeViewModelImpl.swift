//
//  HomeViewModelImpl.swift
//  KCS
//
//  Created by 조성민 on 1/15/24.
//

import RxRelay
import RxSwift
import CoreLocation
import NMapsMap

final class HomeViewModelImpl: HomeViewModel {
    
    var getStoresUseCase: GetStoresUseCase
    var getRefreshStoresUseCase: GetRefreshStoresUseCase
    var getStoreInformationUseCase: GetStoreInformationUseCase
    var getSearchStoresUseCase: GetSearchStoresUseCase
    
    let getStoreInformationOutput = PublishRelay<Store>()
    let refreshDoneOutput = PublishRelay<Bool>()
    let locationButtonOutput = PublishRelay<NMFMyPositionMode>()
    let locationButtonImageNameOutput = PublishRelay<String>()
    let setMarkerOutput = PublishRelay<MarkerContents>()
    let locationAuthorizationStatusDeniedOutput = PublishRelay<Void>()
    let locationStatusNotDeterminedOutput = PublishRelay<Void>()
    let locationStatusAuthorizedWhenInUseOutput = PublishRelay<Void>()
    let requestLocationAuthorizationOutput = PublishRelay<Void>()
    let errorAlertOutput = PublishRelay<ErrorAlertMessage>()
    let filteredStoresOutput = PublishRelay<[FilteredStores]>()
    let fetchCountOutput = PublishRelay<FetchCountContent>()
    let noMoreStoresOutput = PublishRelay<Void>()
    let dimViewTapGestureEndedOutput = PublishRelay<Void>()
    let searchStoresOutput = PublishRelay<[Store]>()
    let searchOneStoreOutput = PublishRelay<Store>()
    let moreStoreButtonHiddenOutput = PublishRelay<Void>()
    
    var dependency: HomeDependency
    
    init(
        dependency: HomeDependency,
        getStoresUseCase: GetStoresUseCase,
        getRefreshStoresUseCase: GetRefreshStoresUseCase,
        getStoreInformationUseCase: GetStoreInformationUseCase,
        getSearchStoresUseCase: GetSearchStoresUseCase
    ) {
        self.dependency = dependency
        self.getStoresUseCase = getStoresUseCase
        self.getRefreshStoresUseCase = getRefreshStoresUseCase
        self.getStoreInformationUseCase = getStoreInformationUseCase
        self.getSearchStoresUseCase = getSearchStoresUseCase
    }
    
    func action(input: HomeViewModelInputCase) {
        switch input {
        case .refresh(let requestLocation, let isEntire):
            refresh(requestLocation: requestLocation, isEntire: isEntire)
        case .moreStoreButtonTapped:
            moreStoreButtonTapped()
        case .filterButtonTapped(let filter):
            filterButtonTapped(filter: filter)
        case .markerTapped(let tag):
            markerTapped(tag: tag)
        case .locationButtonTapped(let locationAuthorizationStatus, let positionMode):
            locationButtonTapped(locationAuthorizationStatus: locationAuthorizationStatus, positionMode: positionMode)
        case .dimViewTapGestureEnded:
            dimViewTapGestureEnded()
        case .setMarker(let store, let certificationType):
            setMarker(store: store, certificationType: certificationType)
        case .checkLocationAuthorization(let status):
            checkLocationAuthorization(status: status)
        case .checkLocationAuthorizationWhenCameraDidChange(let status):
            checkLocationAuthorizationWhenCameraDidChange(status: status)
        case .search(let location, let keyword):
            search(location: location, keyword: keyword)
        case .resetFilters:
            resetFilters()
        case .compareCameraPosition(let refreshCameraPosition, let endMoveCameraPosition, let refreshCameraPoint, let endMoveCameraPoint):
            compareCameraPosition(
                refreshCameraPosition: refreshCameraPosition,
                endMoveCameraPosition: endMoveCameraPosition,
                refreshCameraPoint: refreshCameraPoint,
                endMoveCameraPoint: endMoveCameraPoint
            )
        }
    }
    
}

private extension HomeViewModelImpl {
    
    func refresh(
        requestLocation: RequestLocation,
        isEntire: Bool
    ) {
        getStoresUseCase.execute(
            requestLocation: requestLocation,
            isEntire: isEntire
        )
        .subscribe(
            onNext: { [weak self] refreshContent in
                guard let self = self else { return }
                dependency.resetFetchCount()
                dependency.maxFetchCount = refreshContent.fetchCountContent.maxFetchCount
                applyFilters(stores: refreshContent.stores, filters: getActivatedTypes())
                fetchCountOutput.accept(FetchCountContent(maxFetchCount: dependency.maxFetchCount))
                refreshDoneOutput.accept(isEntire)
                checkLastFetch()
            },
            onError: { [weak self] error in
                if error is StoreRepositoryError {
                    self?.errorAlertOutput.accept(.client)
                } else {
                    guard let error = error as? ErrorAlertMessage else { return }
                    self?.errorAlertOutput.accept(error)
                    self?.refreshDoneOutput.accept(true)
                }
            }
        )
        .disposed(by: dependency.disposeBag)
    }
    
    func moreStoreButtonTapped() {
        if dependency.fetchCount < dependency.maxFetchCount {
            dependency.fetchCount += 1
            applyFilters(stores: getRefreshStoresUseCase.execute(fetchCount: dependency.fetchCount), filters: getActivatedTypes())
            fetchCountOutput.accept(FetchCountContent(maxFetchCount: dependency.maxFetchCount, fetchCount: dependency.fetchCount))
        }
        checkLastFetch()
    }
    
    func checkLastFetch() {
        if dependency.fetchCount == dependency.maxFetchCount {
            noMoreStoresOutput.accept(())
        }
    }
    
    func filterButtonTapped(filter: CertificationType) {
        if let lastIndex = dependency.activatedFilter.lastIndex(of: filter) {
            dependency.activatedFilter.remove(at: lastIndex)
        } else {
            dependency.activatedFilter.append(filter)
        }
        applyFilters(stores: getRefreshStoresUseCase.execute(fetchCount: dependency.fetchCount), filters: getActivatedTypes())
    }
    
    func getActivatedTypes() -> [CertificationType] {
        if dependency.activatedFilter.isEmpty {
            return [.safe, .exemplary, .goodPrice]
        }
        
        return dependency.activatedFilter
    }
    
    func applyFilters(stores: [Store], filters: [CertificationType]) {
        var goodPriceStores = FilteredStores(
            type: .goodPrice,
            stores: []
        )
        var exemplaryStores = FilteredStores(
            type: .exemplary,
            stores: []
        )
        var safeStores = FilteredStores(
            type: .safe,
            stores: []
        )
        
        stores.forEach { store in
            var type: CertificationType?
            filters.forEach { filter in
                if store.certificationTypes.contains(filter) {
                    type = filter
                }
            }
            if let checkedType = type {
                switch checkedType {
                case .goodPrice:
                    goodPriceStores.stores.append(store)
                case .exemplary:
                    exemplaryStores.stores.append(store)
                case .safe:
                    safeStores.stores.append(store)
                }
            }
        }
        filteredStoresOutput.accept([goodPriceStores, exemplaryStores, safeStores])
    }
    
    func markerTapped(tag: UInt) {
        do {
            getStoreInformationOutput.accept(
                try getStoreInformationUseCase.execute(tag: tag)
            )
        } catch {
            errorAlertOutput.accept(.client)
        }
    }
    
    func setMarker(store: Store, certificationType: CertificationType) {
        switch certificationType {
        case .goodPrice:
            setMarkerOutput.accept(
                MarkerContents(
                    tag: store.id,
                    location: store.location,
                    deselectImageName: "MarkerGoodPriceNormal",
                    selectImageName: "MarkerGoodPriceSelected"
                )
            )
        case .exemplary:
            setMarkerOutput.accept(
                MarkerContents(
                    tag: store.id,
                    location: store.location,
                    deselectImageName: "MarkerExemplaryNormal",
                    selectImageName: "MarkerExemplarySelected"
                )
            )
        case .safe:
            setMarkerOutput.accept(
                MarkerContents(
                    tag: store.id,
                    location: store.location,
                    deselectImageName: "MarkerSafeNormal",
                    selectImageName: "MarkerSafeSelected"
                )
            )
        }
    }
    
    func locationButtonTapped(locationAuthorizationStatus: CLAuthorizationStatus, positionMode: NMFMyPositionMode) {
        if locationAuthorizationStatus == .denied {
            requestLocationAuthorizationOutput.accept(())
        }
        switch positionMode {
        case .direction:
            locationButtonOutput.accept(.compass)
        case .compass, .normal:
            locationButtonOutput.accept(.direction)
        default:
            break
        }
    }
    
    func dimViewTapGestureEnded() {
        dimViewTapGestureEndedOutput.accept(())
    }
    
    func checkLocationAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationStatusNotDeterminedOutput.accept(())
        case .authorizedWhenInUse:
            locationStatusAuthorizedWhenInUseOutput.accept(())
        default:
            locationAuthorizationStatusDeniedOutput.accept(())
        }
    }
    
    func checkLocationAuthorizationWhenCameraDidChange(status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted, .notDetermined:
            locationButtonImageNameOutput.accept("LocationButtonNone")
        case .authorizedWhenInUse:
            locationButtonImageNameOutput.accept("LocationButtonNormal")
        default:
            break
        }
    }
    
    func search(location: Location, keyword: String) {
        getSearchStoresUseCase.execute(location: location, keyword: keyword)
            .subscribe(onNext: { [weak self] stores in
                guard let self = self else { return }
                dependency.resetFetchCount()
                dependency.maxFetchCount = 1
                if stores.count == 1 {
                    guard let oneStore = stores.first else { return }
                    searchOneStoreOutput.accept(oneStore)
                } else {
                    searchStoresOutput.accept(stores)
                }
            })
            .disposed(by: dependency.disposeBag)
    }
    
    func resetFilters() {
        dependency.activatedFilter = []
    }
    
    func compareCameraPosition(
        refreshCameraPosition: NMFCameraPosition,
        endMoveCameraPosition: NMFCameraPosition,
        refreshCameraPoint: CGPoint,
        endMoveCameraPoint: CGPoint
    ) {
        let zoomDifference = abs(refreshCameraPosition.zoom - endMoveCameraPosition.zoom)
        let pointDifference = sqrt(
            pow(refreshCameraPoint.x - endMoveCameraPoint.x, 2) +
            pow(refreshCameraPoint.y - endMoveCameraPoint.y, 2)
        )
        if zoomDifference > 0.5 || pointDifference > 50 {
            moreStoreButtonHiddenOutput.accept(())
        }
    }
    
}
