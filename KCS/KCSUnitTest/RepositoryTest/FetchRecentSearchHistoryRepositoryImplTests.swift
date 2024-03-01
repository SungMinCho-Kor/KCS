//
//  FetchRecentSearchHistoryRepositoryImplTests.swift
//  KCSUnitTest
//
//  Created by 김영현 on 2/29/24.
//

import XCTest
@testable import KCS
import RxSwift
import RxBlocking

struct FetchRecentSearchHistoryRepositoryImplTestsConstant {
    
    let key = "recentSearchKeywords"
    let emptyRecentHistory: [String] = []
    let RecentHistory: [String] = ["검색어1", "검색어2", "검색어3"]
    
}

final class FetchRecentSearchHistoryRepositoryImplTests: XCTestCase {
    
    private var fetchRecentSearchHistoryRepository: FetchRecentSearchHistoryRepository!
    private var userDefaults: FakeUserDefaults!
    private var fetchRecentSearchHistoryRepositoryImplTestsEntity: FetchRecentSearchHistoryRepositoryImplTestsConstant!

    override func setUp() {
        userDefaults = FakeUserDefaults()
        fetchRecentSearchHistoryRepositoryImplTestsEntity = FetchRecentSearchHistoryRepositoryImplTestsConstant()
        fetchRecentSearchHistoryRepository = FetchRecentSearchHistoryRepositoryImpl(
            userDefaults: userDefaults
        )
    }
    
    func test_userDefaults에서_빈_배열값을_가져오는_경우() {
        // Given initial state
        // When
        let result = fetchRecentSearchHistoryRepository.fetchRecentSearchHistory().toBlocking()
        
        do {
            let resultArray = try result.first()
            
            // Then
            XCTAssertEqual(resultArray, fetchRecentSearchHistoryRepositoryImplTestsEntity.emptyRecentHistory)
        } catch {
            XCTFail("빈 배열 불러오기 실패")
        }
    }
    
    func test_userDefaults에서_문자열_배열값을_가져오는_경우() {
        // Given
        let key = fetchRecentSearchHistoryRepositoryImplTestsEntity.key
        userDefaults.set(fetchRecentSearchHistoryRepositoryImplTestsEntity.RecentHistory, forKey: key)
        
        // When
        let result = fetchRecentSearchHistoryRepository.fetchRecentSearchHistory().toBlocking()
        
        do {
            let resultArray = try result.first()
            
            // Then
            XCTAssertEqual(resultArray, userDefaults.array(forKey: key) as? [String])
        } catch {
            XCTFail("문자열 배열 불러오기 실패")
        }
    }

}
