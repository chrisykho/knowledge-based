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

---

# Inside the Transformer — Internal Layer Functions

> While the 6-layer architecture above describes the *deployment* pipeline, this section describes the *internal* structure of layer ⑤ (Model Weights).

A transformer LLM (e.g. Llama 3 8B) consists of **32 stacked transformer blocks**. Each block has the same structure:

```
Input tokens → [Embedding]
  → Layer 1  (Attention → FFN)
  → Layer 2  (Attention → FFN)
  → ...
  → Layer 32 (Attention → FFN)
  → [LM Head] → Output tokens
```

Each block contains two sub-layers:
- **Attention (Q/K/V/O projections)** — decides *what to pay attention to*
- **FFN (Feed-Forward Network)** — stores *factual knowledge*

## Functional Hierarchy

Research (e.g. *"What Does BERT Look At?"*, Clark et al. 2019; *"Transformer Layers as Paintings"*, 2023) shows clear specialisation:

```
Layer 1-8   │  Bottom layers     │ Syntax & surface patterns
────────────┼────────────────────┼───────────────────────────
Layer 9-16  │  Lower-middle      │ Basic semantics & POS
Layer 17-24 │  Upper-middle      │ Entity relationships
Layer 25-32 │  Top layers        │ Task-specific & planning
```

### Bottom Layers (1-8) — Syntax

- Learn word order patterns (subject-verb-object)
- POS tagging (which token is a noun, verb, etc.)
- Short-range dependencies (adjacent tokens)
- Example: These layers activate strongly on "the" → expecting a noun

### Middle Layers (9-24) — Semantics & Entities

- Build meaningful representations of phrases
- Entity recognition: "Einstein" → scientist, "Paris" → city
- Long-range dependencies: connect "The cat... ran" across 20 tokens
- These layers produce the most **transferable** features — useful for all downstream tasks

### Top Layers (25-32) — Task-Specific

- Closest to the output head, most specialised for next-token prediction
- Control style, tone, format (e.g. follow instruction format)
- Higher-level reasoning and planning across the response
- These layers change the most during fine-tuning

## Why This Matters for LoRA

Recall that LoRA can target **only attention layers** (Q/K/V/O projections) while leaving FFN layers untouched.

| Sub-layer | Function | LoRA target? |
|-----------|----------|-------------|
| Attention (Q/K/V/O) | Controls *what patterns to notice* | ✅ Default (changes behaviour) |
| FFN (gate/up/down) | Stores *factual knowledge* | ❌ Skip (preserves knowledge) |

Why? Because:
- **Attention layers** in any level (bottom/middle/top) control *behaviour* — what the model pays attention to
- **FFN layers** store the actual *knowledge* — modifying them risks forgetting facts

This functional specialisation is why LoRA-First works so well: you change behaviour by targeting attention, while the FFN layers keep the original knowledge intact.

## Visual Summary

```
Deployment Layers (6 layers):          Internal Layers (32 blocks):
─────────────────────────────          ──────────────────────────
① Client                               [Bottom 1-8]
② API Wrapper    ← plumbing →           Syntax & surface patterns
③ Input Guardrail                       [Middle 9-24]
④ Inference Engine                      Semantics & entities
⑤ Model Weights  ← the brain →         [Top 25-32]
⑥ Output Guardrail                      Task-specific & planning
                                       Each block: Attention + FFN
```

## References

1. Clark et al., "What Does BERT Look At? An Analysis of BERT's Attention", ACL 2019
2. Tenney et al., "BERT Rediscovers the Classical NLP Pipeline", ACL 2019
3. Rogers et al., "A Primer in BERTology: What We Know About How BERT Works", TACL 2020
4. Hu et al., "LoRA: Low-Rank Adaptation of Large Language Models", ICLR 2022