# Compression Demo — How Huffman Coding Works

> 記錄於 2026-08-19，從「Compression = Intelligence」對話延伸

## Core Concept

**Compression = Prediction = Understanding**

愈好嘅 prediction model → 愈低嘅 conditional entropy → 愈短嘅 compressed output → 愈接近 AGI。

## Concrete Example: "THE RAIN IN SPAIN"

### Original
```
17 characters × 8 bits = 136 bits = 17 bytes
```

### Huffman Code Table

Prefix codes — 冇一個 code 係另一個嘅 prefix，所以唔需要 separator。

| Char | Freq | Code | Bits |
|------|------|------|------|
| 'N'  | 3    | 00   | 2    |
| ' '  | 3    | 110  | 3    |
| 'A'  | 2    | 010  | 3    |
| 'I'  | 3    | 111  | 3    |
| 'E'  | 1    | 0110 | 4    |
| 'H'  | 1    | 0111 | 4    |
| 'P'  | 1    | 1000 | 4    |
| 'R'  | 1    | 1001 | 4    |
| 'S'  | 1    | 1010 | 4    |
| 'T'  | 1    | 1011 | 4    |

Common chars get short codes (N=2 bits), rare chars get long codes (T=4 bits).

### Compressed Bitstream

```
ASCII:      T  H  E     R  A  I  N     I  N     S  P  A  I  N
原始 bits:  8  8  8  8  8  8  8  8  8  8  8  8  8  8  8  8  8  = 136 bits
壓縮 bits:  4  4  4  3  4  3  3  2  3  3  2  3  4  4  3  3  2  =  54 bits
            ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓  ↓
Code:     1011 0111 0110 110 1001 010 111 00 110 111 00 110 1010 1000 010 111 00
```

**54 bits = 6.8 bytes — 2.5x compression ratio**

### How Decoder Works (No Separator Needed)

Prefix property: no code is the prefix of another code.

```
收到 bitstream: 101101110110...
1 →  waiting (no code is just "1")
10 → waiting
101 → waiting
1011 → 'T' ✅ match! reset...
0 → waiting
01 → waiting
011 → waiting
0111 → 'H' ✅ match! reset...
```

The code tree is self-terminating — the decoder knows exactly when one code ends and the next begins without any separator.

### Byte Storage

Padded to byte boundary (+2 bits):

```
10110111 01101101 00101011 10011011 10011010 10100001 01110000
   183     109      43       155      154      161      112
   b7      6d       2b       9b       9a       a1       70
```

## What Happens with a Typo?

A typo is **unexpected** — the model assigns it low probability. In compression, low probability = more bits needed.

| Sentence | Result |
|----------|--------|
| "THE RAIN IN SPAIN" | 54 bits (baseline) |
| "THE RAIN IN SPAN" (missing I) | 51 bits (slightly different) |
| "THE RAIN IN SPAIN?" (extra ?) | ❌ '?' not in code table |
| "THE RAIN IN SPAINX" (wrong X) | ❌ 'X' not in code table |

With an LLM-level predictor:
- Given "THE RAIN IN SPAI___", LLM predicts "N" with ~99.9% confidence
- If actual char is "N" → ~0.001 bits to confirm
- If actual char is "X" → ~10 bits to encode the surprise

**Typo is expensive in compression terms** — it carries far more information than a normal character.

## Practical Applications

- **Spell check** — misspelled text has lower compression ratio
- **Authorship attribution** — each person's writing pattern has different compressibility
- **AI text detection** — AI-generated text tends to be more predictable (higher compression ratio)
- **Anomaly detection** — anything unexpected sticks out as needing more bits

## Hierarchy of Compression

```
Level 1: Characters    → "T" "H" "E" ...          17 codes
Level 2: Bigrams       → "TH" "E " "RA" ...        fewer codes
Level 3: Words         → "THE" "RAIN" ...          7 codes
Level 4: Phrases       → "THE RAIN" ...            5 codes
Level 5: Whole sentence→ "THE RAIN IN SPAIN"       1 code
```

Each level captures one more layer of structure. Structure = pattern = predictability = compressibility = understanding.

## The Limit

| Model | bits/char | enwik8 size |
|-------|-----------|-------------|
| Random guess | 8.00 | 100 MB |
| Char frequency | 4.45 | ~56 MB |
| Bigram | 1.39 | ~17 MB |
| Chinchilla 70B (LLM) | ~1.0 | 11.5 MB |
| Perfect predictor | 0 | 0 (infinite compression) |

A perfect LLM = perfect predictor = perfect compressor = AGI.

## References

1. Delétang et al., "Language Modeling is Compression", DeepMind 2023
2. Shannon, "A Mathematical Theory of Communication", 1948
3. Huffman, "A Method for the Construction of Minimum-Redundancy Codes", 1952