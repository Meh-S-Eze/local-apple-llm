import Foundation

// Example client to demonstrate how to use the LocalLLM server
@main
struct Client {
    static func main() async throws {
        let baseURL = "http://localhost:8080"
        
        // First check if server is running
        guard let healthURL = URL(string: "\(baseURL)/health") else {
            fatalError("Invalid URL")
        }
        
        let (healthData, _) = try await URLSession.shared.data(from: healthURL)
        if let healthStatus = String(data: healthData, encoding: .utf8) {
            print("Server status:", healthStatus)
        }
        
        // Prepare the request
        guard let generateURL = URL(string: "\(baseURL)/generate") else {
            fatalError("Invalid URL")
        }
        
        let prompt = "Tell me about Swift programming language"
        let requestBody = ["prompt": prompt, "stream": false]
        let jsonData = try JSONEncoder().encode(requestBody)
        
        var request = URLRequest(url: generateURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Make the request
        let (responseData, _) = try await URLSession.shared.data(for: request)
        if let responseString = String(data: responseData, encoding: .utf8) {
            print("\nResponse:", responseString)
        }
        
        // Example of streaming request
        print("\nStreaming example:")
        var streamRequest = URLRequest(url: generateURL)
        streamRequest.httpMethod = "POST"
        streamRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        streamRequest.httpBody = try JSONEncoder().encode(["prompt": prompt, "stream": true])
        
        let (streamBytes, _) = try await URLSession.shared.bytes(for: streamRequest)
        for try await line in streamBytes.lines {
            if line.hasPrefix("data: ") {
                let content = String(line.dropFirst(6))
                if content == "[DONE]" {
                    break
                }
                print(content, terminator: "")
            }
        }
        print() // Add final newline
    }
} 