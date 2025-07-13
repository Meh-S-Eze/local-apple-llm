import Foundation

public enum LocalLLMError: Error {
    case appleIntelligenceNotEnabled
    case deviceNotEligible
    case modelNotReady
    case unknown
    
    public var description: String {
        switch self {
        case .appleIntelligenceNotEnabled:
            return "Apple Intelligence is not enabled. Please enable it in Settings."
        case .deviceNotEligible:
            return "This device is not eligible for Apple Intelligence. Please use a compatible device."
        case .modelNotReady:
            return "The language model is not ready yet. Please try again later."
        case .unknown:
            return "The language model is unavailable for an unknown reason."
        }
    }
}

@available(macOS 14.0, *)
public actor LocalLLM: Sendable {
    private enum Implementation {
        case mock
        #if canImport(FoundationModels)
        case foundationModels(session: LanguageModelSession)
        #endif
    }
    
    private let implementation: Implementation
    
    public init() throws {
        #if canImport(FoundationModels)
        if #available(macOS 26.0, *) {
            do {
                // Check model availability
                switch SystemLanguageModel.default.availability {
                case .available:
                    let session = LanguageModelSession()
                    self.implementation = .foundationModels(session: session)
                    return
                case .unavailable(let reason):
                    switch reason {
                    case .appleIntelligenceNotEnabled:
                        throw LocalLLMError.appleIntelligenceNotEnabled
                    case .deviceNotEligible:
                        throw LocalLLMError.deviceNotEligible
                    case .modelNotReady:
                        throw LocalLLMError.modelNotReady
                    @unknown default:
                        throw LocalLLMError.unknown
                    }
                }
            } catch {
                print("Warning: Failed to initialize FoundationModels: \(error)")
                self.implementation = .mock
            }
        } else {
            print("Warning: FoundationModels requires macOS 26.0 or later")
            self.implementation = .mock
        }
        #else
        print("Warning: FoundationModels framework not available")
        self.implementation = .mock
        #endif
    }
    
    public func generateText(prompt: String) async throws -> String {
        switch implementation {
        case .mock:
            return "This is a mock response to: \(prompt)"
        #if canImport(FoundationModels)
        case .foundationModels(let session):
            let response = try await session.respond(to: prompt)
            return response.content
        #endif
        }
    }
    
    public nonisolated func streamText(prompt: String) -> AsyncThrowingStream<String, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                switch implementation {
                case .mock:
                    let words = "This is a mock streaming response to: \(prompt)".split(separator: " ")
                    for word in words {
                        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                        continuation.yield(String(word) + " ")
                    }
                    continuation.finish()
                #if canImport(FoundationModels)
                case .foundationModels(let session):
                    do {
                        let stream = session.streamResponse(to: prompt)
                        for try await response in stream {
                            continuation.yield(response.content)
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                #endif
                }
            }
        }
    }
} 