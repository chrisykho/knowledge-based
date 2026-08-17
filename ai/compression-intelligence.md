# Compression = Intelligence = World Model

> 記錄於 2026-08-14，與 Hermes Agent（Paper Boy）討論 compression 同 AGI 關係

## 核心命題

**Intelligence = Compression = World Modelling = Prediction**

呢四樣嘢唔係 analogies，而係數學上等價嘅概念。

## Shannon 嘅極限 — Compression 嘅物理限制

無損壓縮有個理論極限：**entropy（熵）**，單位係 bits/symbol。

```
H = -Σ p(i) × log₂(p(i))
```

entropy 代表「呢段數據最少要用幾多 bit 先可以無損表示」。低 entropy = 高 redundancy = 可高度壓縮。random data 嘅 entropy = 8 bits/byte → 壓縮唔到。

## DeepMind 嘅 breakthrough — "Language Modeling is Compression"

**論文：** *Language Modeling is Compression* (2023)
📄 [arxiv.org/abs/2309.10668](https://arxiv.org/abs/2309.10668)

**發現：** LLM（Chinchilla 7B-70B）直接用下一個 token prediction 嘅 probability distribution feed 入 arithmetic coder，結果：

| Method | enwik8 壓縮後 | 壓縮比 |
|--------|--------------|--------|
| gzip -9 | ~36 MB | ~2.8x |
| bzip2 | ~26 MB | ~3.8x |
| LZMA (7z) | ~20 MB | ~5x |
| PAQ8 | ~16 MB | ~6.25x |
| **Chinchilla 70B** | **~11.5 MB** | **~8.7x** |
| Theoretical limit | ~12 MB | ~8x |

Chinchilla 首次超越所有傳統通用 compressor，接近 Shannon limit。

**核心 insight：** Test loss（cross-entropy）同 compressed size 係完美正相關。即係 **compression 同 prediction 本質上係同一件事。**

## Brain as a Mini-Nature（大腦作為微型自然）

直覺（記錄自對話）：

> 大腦係微型自然，係完美世界嘅縮影。因為佢反映咗世界嘅 structure，所以可以俾到 perfect prediction。

呢個直覺同 DeepMind 嘅結論係 mirror image — 只係表達語言唔同。

## Free Energy Principle（Karl Friston, 2005-現在）

大腦係一個 **generative model of the world**，不斷 minimises prediction error（surprise）。成功 minimising surprise = 成功 modelling reality = maximising compression。

## Thousand Brains Theory（Jeff Hawkins, 2021）

大腦皮層由大量 cortical columns 組成，每個 column 學習物體嘅 reference frame。大腦係一個 **distributed compressed representation of reality**。

## 結論

> A model that achieves the best possible compression on all data would be a perfect world model, and thus would be generally intelligent.
>
> — DeepMind, 2023

Compression 唔係 engineering problem，而係 **intelligence 嘅本質**。

---

## References

1. Delétang et al., "Language Modeling is Compression", DeepMind 2023
2. Shannon, "A Mathematical Theory of Communication", 1948
3. Friston, "The Free-Energy Principle: A Unified Brain Theory?", 2010
4. Hawkins, "A Thousand Brains: A New Theory of Intelligence", 2021