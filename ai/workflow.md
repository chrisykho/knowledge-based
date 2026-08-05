# AI Chatbot Full Workflow

From typing a message to seeing the response, the complete flow:

```
你打字 "Hello"
    │
    ▼
┌──────────────────────────────────────┐
│ ① Client Layer                       │
│ Hermes Agent / ChatGPT / your script │
│ Function: 收 input → 包裝 API call    │
└──────────────┬───────────────────────┘
               │ POST /v1/chat/completions
               ▼
┌──────────────────────────────────────┐
│ ② API Wrapper Layer (Provider)       │
│ OpenAI / OpenRouter / Ollama server  │
│ Function: auth → routing → call model│
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│ ③ Input Guardrail                    │
│ Provider content moderation          │
│ e.g. harmful input → block 403       │
└──────────────┬───────────────────────┘
               │ pass ✅
               ▼
┌──────────────────────────────────────┐
│ ④ Inference Engine                   │
│ llama.cpp / vLLM / Transformers      │
│ tokenize → forward pass → sample     │
│ (matrix multiplication x billions)   │
└──────────────┬───────────────────────┘
               │ generate tokens
               ▼
┌──────────────────────────────────────┐
│ ⑤ Model Weights                      │
│ safetensors / GGUF files             │
│ 提供「智能」— 知識、推理、語言          │
│ 包含 RLHF alignment (refusal)        │
└──────────────┬───────────────────────┘
               │ output tokens
               ▼
┌──────────────────────────────────────┐
│ ⑥ Output Guardrail                   │
│ Hermes tirith / keyword filter       │
│ Check output before display          │
└──────────────┬───────────────────────┘
               │ pass ✅
               ▼
你見到 Response "Hi! 👋"
```

## What happens at each step

1. **You type** a message → Client wraps it as `{"messages": [{"role": "user", "content": "Hello"}]}`
2. **API Wrapper** verifies your API key, routes to the correct model endpoint
3. **Input Guardrail** scans for harmful content (violence, hate speech, etc.)
4. **Inference Engine** loads the weights, runs forward pass (trillions of matrix multiplications), samples next tokens
5. **Model Weights** provide the "intelligence" — the numbers that encode knowledge and reasoning
6. **Output Guardrail** checks the response before showing it to you