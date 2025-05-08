import XCTest
@testable import Phmora

final class OpenFDAServiceTests: XCTestCase {
    var mockService: MockOpenFDAService!
    
    override func setUp() {
        super.setUp()
        mockService = MockOpenFDAService()
    }
    
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }
    
    func testSearchDrugsSuccess() async throws {
        let response = try await mockService.searchDrugs(query: "aspirin")
        
        XCTAssertTrue(response.success)
        XCTAssertGreaterThan(response.drugs.count, 0)
        XCTAssertEqual(response.total, response.drugs.count)
    }
    
    func testSearchDrugsFailure() async {
        mockService.shouldFail = true
        
        do {
            _ = try await mockService.searchDrugs(query: "aspirin")
            XCTFail("Expected error but got success")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    func testGetDrugDetailsSuccess() async throws {
        let response = try await mockService.getDrugDetails(drugId: "ANDA040445")
        
        XCTAssertTrue(response.success)
        XCTAssertEqual(response.drug.id, "ANDA040445")
        XCTAssertEqual(response.drug.brandName, "ASPIRIN")
    }
    
    func testGetDrugDetailsFailure() async {
        mockService.shouldFail = true
        
        do {
            _ = try await mockService.getDrugDetails(drugId: "ANDA040445")
            XCTFail("Expected error but got success")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    func testGetAdverseEventsSuccess() async throws {
        let response = try await mockService.getAdverseEvents(drug: "aspirin")
        
        XCTAssertTrue(response.success)
        XCTAssertGreaterThan(response.events.count, 0)
        XCTAssertEqual(response.total, response.events.count)
    }
    
    func testGetAdverseEventsFailure() async {
        mockService.shouldFail = true
        
        do {
            _ = try await mockService.getAdverseEvents(drug: "aspirin")
            XCTFail("Expected error but got success")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    func testGetDrugRecallsSuccess() async throws {
        let response = try await mockService.getDrugRecalls(drug: "aspirin")
        
        XCTAssertTrue(response.success)
        XCTAssertGreaterThan(response.recalls.count, 0)
        XCTAssertEqual(response.total, response.recalls.count)
    }
    
    func testGetDrugRecallsFailure() async {
        mockService.shouldFail = true
        
        do {
            _ = try await mockService.getDrugRecalls(drug: "aspirin")
            XCTFail("Expected error but got success")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
} 