# Contributors — Who Does What

| Contributor | Role | Responsible For |
|------------|------|-----------------|
| **You** | User | Providing input, choosing provider, reviewing output |
| **OpenAI / OpenRouter** | Provider | API wrapper, guardrails, inference hosting infrastructure |
| **Ollama / llama.cpp** | Engine | Local inference engine (runs matrix math on your hardware) |
| **Meta / Mistral / DeepSeek** | Model Creator | Training model weights + tokenizer, releasing open-source |
| **Hermes Agent** | Client | Wrapping your input, tool calling, output guardrail (tirith), session management |

## Data Flow

```
你 (input)
  → Hermes Agent (client layer, tool calling)
    → OpenRouter / Ollama (API wrapper + inference engine)
      → Llama / Mistral / DeepSeek (model weights)
    → Hermes Agent (output guardrail)
  → 你 (sees response)
```

## Who provides what layer

| Layer | Typically Provided By |
|-------|---------------------|
| ① Client | You (Hermes Agent / custom app) |
| ② API Wrapper | Provider (OpenAI, OpenRouter, Ollama) |
| ③ Input Guardrail | Provider (OpenAI moderation, OpenRouter TOS) |
| ④ Inference Engine | Provider (vLLM) or local (llama.cpp) |
| ⑤ Model Weights | Model creators (Meta, Mistral, DeepSeek) |
| ⑥ Output Guardrail | You (Hermes tirith, custom filter) |