# Apple Local LLM

A Swift server that provides access to Apple's Foundation Models framework through a simple REST API. This project allows you to use Apple's on-device language models via HTTP requests.

## Requirements

- macOS 14.0 or later
- Apple Silicon Mac
- macOS 26.0 (Tahoe) or later for Foundation Models support
- Apple Intelligence enabled in System Settings

## Features

- REST API endpoint for text generation
- Support for both streaming and non-streaming responses
- Automatic fallback to mock responses when Foundation Models is not available
- Built with Swift and Vapor framework

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/apple-local-llm.git
cd apple-local-llm
```

2. Build and run the server:
```bash
swift build
swift run LocalLLMServer
```

The server will start on `http://127.0.0.1:8080`.

## Usage

The server provides a single endpoint at `/generate` that accepts POST requests with JSON data.

### Example with curl

Non-streaming request:
```bash
curl -X POST http://127.0.0.1:8080/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Tell me a joke", "stream": false}'
```

Streaming request:
```bash
curl -X POST http://127.0.0.1:8080/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Tell me a story", "stream": true}'
```

## Project Structure

- `Sources/LocalLLM/`: Core LLM functionality using Foundation Models
- `Sources/LocalLLMServer/`: Vapor server implementation
- `Examples/`: Example client implementations
- `Tests/`: Unit tests

## License

MIT License. See [LICENSE](LICENSE) for details. 