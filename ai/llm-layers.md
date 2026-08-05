# AI Architecture

## The 6 Layers (User Input → Response)

```text
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

## Layer Descriptions

| Layer | What it does | Example |
|-------|-------------|---------|
| ① Client | Wraps your input into API call | Hermes Agent, ChatGPT UI |
| ② API Wrapper | Auth, routing, model selection | OpenRouter, Ollama server |
| ③ Input Guardrail | Blocks harmful content before inference | OpenAI moderation API |
| ④ Inference Engine | Matrix math to generate tokens | llama.cpp, vLLM, Transformers |
| ⑤ Model Weights | The "brain" — knowledge + reasoning | safetensors, GGUF files |
| ⑥ Output Guardrail | Filters output before user sees it | Hermes tirith security scan |

## Key Insight

**The Model Weights (⑤) are ALL the intelligence.** The other layers are just plumbing — they don't add or change the model's knowledge or reasoning ability. They only handle input/output and safety.