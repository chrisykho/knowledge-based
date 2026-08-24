# How to Identify Unseen Concepts in LLMs

> 記錄於 2026-08-23，從「Why new knowledge needs full fine-tune」對話延伸

## The Core Question

How do you know if a concept exists in a model's knowledge space?

This matters because:
- **LoRA** works well for redirecting existing knowledge
- **Full fine-tune** is needed for genuinely new concepts

But "seen" vs "unseen" is not binary — it's a spectrum.

## The Spectrum

```
量子糾纏遙距醫療
  ↓
Model 識「量子糾纏」✅        ← existing knowledge
Model 識「遙距醫療」✅        ← existing knowledge
Model 識「量子糾纏 + 遙距醫療」❌ ← new combination

→ LoRA can redirect two known paths
→ But cannot create the emergent property of their combination
```

"Unseen" is really: **this exact combination of concepts has never appeared in the training data context.**

## Method 1: Log-Probability Test

Feed the model text containing the concept and check its prediction confidence:

```
Input: "量子糾纏遙距醫療係一種..."
Model predict "係" probability: 0.95 → familiar concept
Model predict "係" probability: 0.12 → concept is unfamiliar

If the model needs many extra tokens before predicting confidently,
the concept likely isn't in its knowledge space.
```

## Method 2: Linear Probing

Train a simple linear classifier on hidden states:

```
hidden_state (4096-dim vector) → classifier → "Does model know this concept?"

If classifier accuracy is low → no consistent representation in hidden state
If classifier accuracy is high → concept has a stable representation
```

## Method 3: Representation Similarity

Compare hidden state cosine similarity between known and new concepts:

```
cosine(relativity, quantum_telemedicine) = 0.72 → close to known concept
cosine(relativity, random_blabla) = 0.12 → completely out-of-distribution

If the new concept's representation is far from all known concepts,
the model has likely never seen it.
```

## Method 4: Test-Time Behaviour (Most Practical)

Observe output quality directly:

| Output Type | Meaning | Action |
|-------------|---------|--------|
| Fluent, factually correct | ✅ Known concept | LoRA redirect works |
| Grammatical but vague | ⚠️ Redirecting related concepts | LoRA may work with more data |
| Hallucination (made-up facts) | ❌ Unseen, filling gaps | Full fine-tune or pre-train |
| Nonsense / off-topic | ❌ Out of distribution | Full fine-tune needed |

## Why This Matters for Fine-Tuning

```
New concept = new direction in 4096-dim weight space
LoRA update = can only move within 8-dim subspace (rank=8)

LoRA can redirect, but cannot CREATE a new 4096-dim vector.
Full fine-tune (= continual pre-training) expands the knowledge space.
```

## Practical Recommendation

| Scenario | Approach |
|----------|----------|
| Known concept, new format/style | LoRA ✅ |
| Known concepts, new combination | Try LoRA first, check output quality |
| Genuinely new concept (model hallucinates) | Full fine-tune / continual pre-training |

**The easiest test: just try it.** Ask the model about the concept. If the output shows fluent understanding, LoRA is sufficient. If it hallucinates, you need more than LoRA.

## References

1. LoRA paper: Hu et al., ICLR 2022
2. Knowledge neurons in LLMs: Dai et al., "Knowledge Neurons in Pretrained Transformers", ACL 2022
3. Probing classifiers: Belinkov, "Probing Classifiers", 2021