import Vapor
@preconcurrency import LocalLLM

// Configure the server
let app = try await Application.make(.detect())

// Create LLM instance
let llm: LocalLLM
do {
    llm = try LocalLLM()
} catch let error as LocalLLMError {
    print("Failed to initialize LocalLLM: \(error.description)")
    print("Running in mock mode...")
    llm = try LocalLLM() // This will fall back to mock mode
} catch {
    print("Unexpected error: \(error)")
    throw error
}

// Configure routes
app.post("generate") { req -> Response in
    struct GenerateRequest: Content {
        let prompt: String
        let stream: Bool?
    }
    
    struct GenerateResponse: Content {
        let success: Bool
        let text: String?
        let error: String?
    }
    
    let generateRequest = try req.content.decode(GenerateRequest.self)
    
    // If streaming is requested
    if generateRequest.stream == true {
        return try await streamingResponse(llm, prompt: generateRequest.prompt)
    }
    
    // Otherwise, return complete response
    do {
        let text = try await llm.generateText(prompt: generateRequest.prompt)
        let response = Response(status: .ok)
        try response.content.encode(GenerateResponse(success: true, text: text, error: nil))
        return response
    } catch {
        let response = Response(status: .internalServerError)
        try response.content.encode(GenerateResponse(success: false, text: nil, error: error.localizedDescription))
        return response
    }
}

func streamingResponse(_ llm: LocalLLM, prompt: String) async throws -> Response {
    let response = Response(status: .ok)
    response.headers.add(name: .contentType, value: "text/event-stream")
    response.headers.add(name: .connection, value: "keep-alive")
    response.headers.add(name: .cacheControl, value: "no-cache")
    
    response.body = Response.Body(asyncStream: { writer in
        do {
            for try await text in llm.streamText(prompt: prompt) {
                let data = "data: \(text)\n\n"
                _ = try await writer.write(.buffer(.init(string: data)))
            }
            _ = try await writer.write(.buffer(.init(string: "data: [DONE]\n\n")))
        } catch {
            let errorData = "data: {\"error\": \"\(error.localizedDescription)\"}\n\n"
            _ = try await writer.write(.buffer(.init(string: errorData)))
        }
    })
    
    return response
}

// Start the server
try await app.execute() 