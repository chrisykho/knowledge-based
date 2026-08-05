# LLM Physical Deliverables

When you train or download an LLM, you get these files:

## Core Files

```text
model.safetensors          ← Neural network weights (GBs to TBs)
config.json                ← Architecture definition (layers, heads, hidden size)
tokenizer.json             ← Text ↔ token ID mapping
tokenizer_config.json      ← Tokenizer settings
vocab.json / merges.txt    ← Vocabulary (BPE tokenizer)
special_tokens_map.json    ← Special token definitions (<|endoftext|>, <pad>)
```

## Quantized Versions (smaller, faster)

```text
model.q4.gguf              ← llama.cpp GGUF format (4-bit quantized)
model.q8.gguf              ← 8-bit quantized
model.fp16.gguf            ← 16-bit float GGUF
```

## What each file does

| File | Purpose | Size |
|------|---------|------|
| `model.safetensors` | All the weights — the actual "brain" | ~14 GB (7B params × 2 bytes) |
| `config.json` | Tells the engine how to interpret the weights | ~1 KB |
| `tokenizer.json` | Maps words → numbers and back | ~2-50 MB |

## How they're used

```bash
from transformers import AutoModelForCausalLM, AutoTokenizer

model = AutoModelForCausalLM.from_pretrained("model_folder/")   # loads safetensors + config
tokenizer = AutoTokenizer.from_pretrained("model_folder/")      # loads tokenizer files

output = model.generate(tokenizer.encode("Hello", return_tensors="pt"))
```

## Key Point

**There is no separate "API module", "reasoning module", or "knowledge base" file.** Everything — language ability, factual knowledge, reasoning, instruction-following — is encoded in the weight matrices of `model.safetensors` alone.