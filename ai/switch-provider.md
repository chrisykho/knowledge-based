# Switch Provider — Which Layers Change?

| Switch | Layers that change | Layers that stay |
|--------|-------------------|------------------|
| **OpenRouter → Ollama** | ② API Wrapper, ④ Inference Engine | ⑤ Model Weights (same Llama model) |
| **Same model, different engine** | ④ Inference Engine only | ② API Wrapper can stay same |
| **OpenRouter → Ollama** | ③⑥ Guardrails reduce (no TOS filter) | ① Client unchanged |

## Example: Your experience

```text
OpenRouter (DeepSeek V4 Flash)
  → ② API: OpenRouter server
  → ④ Engine: unknown (OpenRouter's infrastructure)
  → ③⑥ Guardrails: OpenRouter TOS filter (blocks Gemini etc.)

       ↓ switch to

Ollama (ornith:9b via Cloudflare tunnel)
  → ② API: Ollama server
  → ④ Engine: llama.cpp
  → ③⑥ Guardrails: None (local = no filter)
```

## What this means for you

- **Dialogue quality**: Same model = same quality (⑤ unchanged)
- **Speed**: Depends on ④ (llama.cpp vs OpenRouter's engine)
- **Safety**: Less guardrails with local Ollama (③⑥)
- **Context handling**: Different engines handle long contexts differently (④ matters here)