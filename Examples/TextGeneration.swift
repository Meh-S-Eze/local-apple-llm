import Foundation
import LocalLLM

@main
struct TextGeneration {
    static func main() async throws {
        let llm = LocalLLM()
        let prompt = "Tell me about Swift programming language"
        
        // Regular text generation
        print("Regular text generation:")
        do {
            let generatedText = try await llm.generateText(prompt: prompt)
            print("Complete response: \(generatedText)")
        } catch {
            print("Error generating text: \(error.localizedDescription)")
        }
        
        // Streaming text generation
        print("\nStreaming text generation:")
        do {
            for try await text in llm.streamText(prompt: prompt) {
                print(text, terminator: "") // Print without newline to show streaming effect
            }
            print() // Add final newline
        } catch {
            print("Error in streaming: \(error.localizedDescription)")
        }
    }
} 