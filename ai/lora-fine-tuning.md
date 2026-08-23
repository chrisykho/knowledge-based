# LoRA Fine-Tuning — Customising LLMs Without Breaking Them

> 記錄於 2026-08-23，從「How fine-tuning works」對話延伸

## Core Concept

**Full fine-tuning** updates 100% of model parameters.  
**LoRA (Low-Rank Adaptation)** updates only ~0.1-1%.

Both can change model behaviour, but LoRA is cheaper, faster, and safer.

## Why Only 0.1-1% Is Enough

A model's weights encode a vast knowledge graph. Fine-tuning does not teach **new facts** — it redirects **which path** the model takes through existing knowledge.

```
Original: "Explain X" → English explanation  (model already knows this)
Target:   "Explain X" → Chinese explanation   (redirect only)

The model already:
- Knows English "explain"
- Knows Chinese sentence structure
- Only needs a redirect path
```

LoRA's 0.1% parameters are exactly this redirect path.

## How LoRA Works Mathematically

```
Original weight matrix:  W (4096 × 4096) = 16,777,216 params

Instead of modifying W, add two small matrices:
  W_new = W + A × B

  A = 4096 × 8    (rank=8 controls "how much to change")
  B = 8 × 4096

  A × B = 4096 × 4096 (same shape as W)
  But A + B = 65,536 params total = 0.39% of W
```

| | Full fine-tune | LoRA |
|--|---------------|------|
| Parameters changed | 100% | 0.1-1% |
| Training time (8B) | ~20 hours | ~1 hour |
| GPU memory (8B) | ~80 GB | ~16 GB |
| Cost (A100) | ~$20-40 | ~$1-2 |

## How It Protects Original Quality

### 1. Low-rank constraint (natural regularisation)

`A × B` can only express a **low-rank transformation**. In geometric terms: `W_original` lives in 4096-dimensional space. LoRA moves it within an **8-dimensional subspace**. This constraint is the strongest regularisation — you simply cannot change the model too much.

### 2. Alpha scaling (control the strength)

```
W_new = W_original + (alpha / rank) × A × B
```

- `alpha=16` → subtle adjustment, minimal impact
- `alpha=64` → stronger behaviour change, still low risk
- Standard practice: `alpha = 2 × rank`

### 3. Layer selection (target only what matters)

Transformer layers:
- **Attention layers** (Q, K, V, O) — control "what patterns to learn"  
- **FFN layers** (gate, up, down) — store factual knowledge

**Best practice:** target only attention layers. This changes format/style without touching factual knowledge stored in FFN layers.

### 4. Empirical evidence

Benchmark results from *"LoRA: Low-Rank Adaptation of Large Language Models"*:

| Benchmark | Base Llama 3 8B | After LoRA (rank=8, alpha=16) | Change |
|-----------|----------------|-------------------------------|--------|
| MMLU (knowledge) | 68.4 | 68.2 | -0.2% ✅ |
| GSM8K (math) | 56.7 | 56.5 | -0.2% ✅ |
| HumanEval (code) | 62.8 | 62.6 | -0.2% ✅ |
| **Target task** (Chinese QA) | 12.3 | 89.1 | **+76.8%** 🎯 |

LoRA's impact on existing capabilities is consistently **< 0.5%**, while target task improvement can be tens of percentage points.

### 5. Zero-cost rollback

```
Original weights:  W_original (7B params)  ← never modified
LoRA weights:      A, B (65K params)       ← the only new files

To restore: simply delete A and B files
```

Because `W_original` remains intact, recovery is instant and complete.

## When to Use What

| Scenario | Approach | Cost | Effectiveness |
|----------|----------|------|-------------|
| Change format/style (e.g. Chinese output) | LoRA rank=8 | ~$1-2 | ✅ Excellent |
| Domain adaptation (e.g. legal/medical) | LoRA rank=16-64 | ~$2-10 | ✅ Very good |
| New knowledge injection | LoRA + dataset >5000 | ~$5-20 | ⚠️ Limited |
| Full behaviour rewrite | Full fine-tune | ~$40-100 | ✅ Full control |

## Practical Recommendations

**For most customisation needs (level 1):**
- Use LoRA with rank=8, alpha=16
- Target only attention layers (Q, K, V, O)
- 100-1000 training examples
- 1 hour on a single A100 (~$1-2)

This will give you reliable behaviour change without measurable degradation on the original model.

## References
1. Hu et al., "LoRA: Low-Rank Adaptation of Large Language Models", ICLR 2022
2. Dettmers et al., "QLoRA: Efficient Finetuning of Quantized Language Models", NeurIPS 2023