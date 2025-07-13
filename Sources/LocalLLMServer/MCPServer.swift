import Foundation
import LocalLLM

struct MCPTool: Codable {
    let name: String
    let description: String
    let inputSchema: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case inputSchema
    }
}

struct MCPToolCall: Codable {
    let name: String
    let input: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case name
        case input
    }
}

struct MCPResponse: Codable {
    let type: String
    let data: [String: String]
    
    enum CodingKeys: String, CodingKey {
        case type
        case data
    }
}

struct MCPServer {
    static var llm: LocalLLM = {
        do {
            return try LocalLLM()
        } catch {
            print("Failed to initialize LocalLLM: \(error)")
            print("Running in mock mode...")
            return try! LocalLLM() // This will fall back to mock mode
        }
    }()
    
    static func start() {
        let standardInput = FileHandle.standardInput
        let standardOutput = FileHandle.standardOutput
        
        Task {
            do {
                for try await line in standardInput.bytes.lines {
                    let decoder = JSONDecoder()
                    let encoder = JSONEncoder()
                    
                    if let command = try? decoder.decode(MCPToolCall.self, from: line.data(using: .utf8)!) {
                        switch command.name {
                        case "generate_text":
                            if let prompt = command.input["prompt"] {
                                let text = try await llm.generateText(prompt: prompt)
                                let response = MCPResponse(type: "success", data: ["text": text])
                                let responseData = try encoder.encode(response)
                                try await standardOutput.write(contentsOf: responseData)
                                try await standardOutput.write(contentsOf: "\n".data(using: .utf8)!)
                            }
                        default:
                            let response = MCPResponse(type: "error", data: ["message": "Unknown command"])
                            let responseData = try encoder.encode(response)
                            try await standardOutput.write(contentsOf: responseData)
                            try await standardOutput.write(contentsOf: "\n".data(using: .utf8)!)
                        }
                    }
                }
            } catch {
                let response = MCPResponse(type: "error", data: ["message": error.localizedDescription])
                let encoder = JSONEncoder()
                if let responseData = try? encoder.encode(response) {
                    try? await standardOutput.write(contentsOf: responseData)
                    try? await standardOutput.write(contentsOf: "\n".data(using: .utf8)!)
                }
            }
        }
    }
} 