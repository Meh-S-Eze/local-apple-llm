import XCTest
@testable import LocalLLM

final class LocalLLMTests: XCTestCase {
    func testMockResponse() async throws {
        let llm = LocalLLM()
        let response = try await llm.generateText(prompt: "Test prompt")
        XCTAssertFalse(response.isEmpty, "Response should not be empty")
    }
    
    func testStreamResponse() async throws {
        let llm = LocalLLM()
        var accumulated = ""
        
        for try await text in llm.streamText(prompt: "Test prompt") {
            accumulated += text
        }
        
        XCTAssertFalse(accumulated.isEmpty, "Streamed response should not be empty")
    }
} 