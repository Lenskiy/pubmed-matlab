# Abstract Clustering Pipeline for PubMed and PMC Literature

This repository provides a fully automated MATLAB pipeline for retrieving, embedding, clustering, and analyzing biomedical literature from **PubMed** and **PubMed Central (PMC)**. It allows researchers to extract meaningful insights from scientific abstracts using transformer-based embeddings and topic modeling.

## Features

- Customizable keyword-based queries with support for Boolean operators (AND, OR, NOT)
- Retrieval of publication metadata and abstracts from **PubMed** and **PMC** using the **NCBI Entrez API**
- Merging and deduplication of articles from both databases
- Abstract preprocessing (tokenization, lemmatization, stopword removal)
- Embedding generation using:
  - [MiniLM](https://arxiv.org/abs/2401.01943) (`all-MiniLM-L12-v2`)
  - Local LLMs (e.g., `qwen2.5:0.5b`) via Ollama REST API
-  Clustering via K-means or hierarchical linkage
-  Visualizations: dendrograms, t-SNE plots, word clouds
- Topic modeling using **Latent Dirichlet Allocation (LDA)** with multiple solvers (`cvb0`, `savb`, `avb`, `cgs`)

## Example Use Case: Gas Sensors + Machine Learning
While this project was tested on gas sensing research involving metal oxide sensors and AI techniques, it is **fully generalizable** to any biomedical or scientific domain, for example:

* Cancer research
* Infectious diseases
* Drug repurposing
* Medical imaging

Any biomedical topic with NLP-based abstract analysis

---

## Folder Structure

```text
.
├── main_script.m              # Entry point for the pipeline
├── PubMedAccess/             # Folder containing all supporting scripts
│   ├── requestIDs.m
│   ├── requestArticles.m
│   ├── parsePMCXML.m
│   ├── parsePubMedXML.m
│   ├── mergeParagraph.m
│   ├── makeStructFromNode.m
│   ├── parseAttributes.m
│   └── preprocessText.m
```

---

## Quick Start

### 1. Prerequisites
- MATLAB R2023a or later with the following toolboxes:
  - Text Analytics Toolbox
  - Statistics and Machine Learning Toolbox
- [Ollama](https://ollama.com) installed locally for LLM embeddings (optional)
- Internet access to fetch articles via Entrez API

### 2. Modify the `mainScript.mlx`
Customize the `query`, `startYear`, and `endYear` to suit your search domain:
```matlab
startYear = 2015;
endYear   = 2024;
query = ['("gas sensing"[ab/ti] OR "gas sensor"[ab/ti]) AND ("machine learning"[ab/ti])'];
```

### 3. Run the Script
```matlab
>> mainScript.mlx
```

This will:
- Fetch and merge metadata from PubMed and PMC
- Generate embeddings for abstracts
- Cluster and visualize abstracts
- Apply topic modeling and generate word clouds

---

## API Usage
The pipeline uses the following endpoints via MATLAB:
- Entrez E-utilities for article ID and abstract retrieval
- `http://localhost:11434/api/embeddings` (LLM embedding via Ollama)
- `http://localhost:11434/api/generate` (optional LLM response generation)

You can switch the LLM model in the script (e.g., `qwen2.5:0.5b`, `llama3.2:1b`, etc.).

---

## Output Examples
- Bar plots of paper counts by year
- Dendrograms showing cluster hierarchies
- t-SNE 2D embeddings with cluster coloring
- Word clouds per cluster/topic
- Perplexity comparisons of LDA solvers

---

## High-Level Pipeline Overview: Medical Literature Retrieval and Clustering

```mermaid
flowchart TD
    A["Search Criteria Construction (Keywords + Years)"] --> B["Query Execution on PubMed and PMC"]
    B --> C["Article ID Retrieval (requestIDs.m)"]
    C --> D["Article Download & XML Parsing (requestArticles.m, parsePMCXML.m, parsePubMedXML.m)"]
    D --> E["Abstract Extraction and Cleaning (mergeParagraph.m, preprocessText.m)"]
    E --> F["Embedding Generation via MiniLM & LLM (e.g., 'qwen2.5:0.5b')"]
    F --> G["Clustering (k-means, linkage)"]
    G --> H["Visualization (t-SNE, dendrogram)"]
    G --> I["Topic Modeling with LDA (word-level & n-gram)"] --> J["Word Clouds"]
```


---

## Acknowledgments
- HuggingFace `MiniLM` for efficient embeddings
- Ollama project for local LLM inference
- NCBI for providing the Entrez API

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Contact
Maintained by **Artem Lensky**  
Email: `a.a.lensky@gmail.com`



