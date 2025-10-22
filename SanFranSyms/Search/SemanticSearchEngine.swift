//
//  SemanticSearchEngine.swift
//  SanFranSyms
//
//  Created by Vadim Zhuk on 22/10/2025.
//

import Foundation
import NaturalLanguage

public struct SearchResult {
    public let symbol: SFSymbol
    public let score: Double
}

public final class SFSymbolSemanticSearchEngine {
    static let shared = SFSymbolSemanticSearchEngine()
    // MARK: - Configuration
    public struct Config {
        public var stopWords: Set<String> = []
        public var lowercase: Bool = true
        public var minTokenLength: Int = 1
        public init() {}
    }

    private let config: Config
    private let queue = DispatchQueue(label: "com.sfsem.searchengine", attributes: .concurrent)

    // Primary storage
    private var symbols: [String: SFSymbol] = [:] // id -> symbol

    // If embedding engine available we use it (preferred). Otherwise use TF-IDF fallback.
    private var embeddingAvailable: Bool = false

    // TF-IDF fallback storage (only used if embeddings not available)
    private var vocabulary: [String] = []
    private var termIndex: [String: Int] = [:] // term -> index
    private var idf: [Double] = []
    private var tfidfVectors: [String: [Double]] = [:] // id -> vector

    // MARK: - Init
    public init(config: Config = Config()) {
        self.config = config
        prepareEmbeddingAvailability()
    }

    private func prepareEmbeddingAvailability() {
        #if canImport(NaturalLanguage)
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            if NLEmbedding.sentenceEmbedding(for: .english) != nil {
                self.embeddingAvailable = true
                return
            }
        }
        #endif
        self.embeddingAvailable = false
    }

    // MARK: - Public API

    /// Index a collection of SFSymbols. This replaces any previously indexed set.
    /// For embeddings, uses the precomputed lazy token. For TF-IDF fallback, computes from text.
    public func index(symbols: [SFSymbol], completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            // reset
            self.symbols.removeAll()
            self.vocabulary.removeAll()
            self.termIndex.removeAll()
            self.idf.removeAll()
            self.tfidfVectors.removeAll()

            for s in symbols {
                self.symbols[s.id] = s
            }

            if self.embeddingAvailable {
                // Vectors are precomputed in lazy token; no additional work needed
                DispatchQueue.main.async { completion?() }
                return
            }

            // Otherwise fallback to TF-IDF from text
            self.computeTFIDFIndex()
            DispatchQueue.main.async { completion?() }
        }
    }

    /// Search with a query string: compute its embedding (or TF-IDF vector) and find closest matches by cosine similarity.
    /// Returns up to `topK` results ordered by score (higher is better).
    public func search(_ query: String, topK: Int = 10) -> [SearchResult] {
        var results: [SearchResult] = []
        queue.sync {
            if self.symbols.isEmpty { return }

            if self.embeddingAvailable {
                guard let qVec = self.embeddingVector(for: query) else { return }
                results = self.symbols.values.compactMap { sym in
                    let v = sym.token // precomputed
                    if v.isEmpty { return nil }
                    let score = self.cosineSimilarity(qVec, v)
                    return SearchResult(symbol: sym, score: score)
                }.sorted(by: { $0.score > $1.score })
            } else {
                let qVec = self.tfidfVector(for: query)
                results = self.symbols.values.compactMap { sym in
                    guard let v = self.tfidfVectors[sym.id] else { return nil }
                    let score = self.cosineSimilarity(qVec, v)
                    return SearchResult(symbol: sym, score: score)
                }.sorted(by: { $0.score > $1.score })
            }
        }
        return Array(results.prefix(topK))
    }

    public func search(_ query: String, in symbols: [SFSymbol], topK: Int = 10) -> [SearchResult] {
        var results: [SearchResult] = []

        queue.sync {
            if symbols.isEmpty { return }

            if self.embeddingAvailable {
                guard let qVec = self.embeddingVector(for: query) else { return }
                results = symbols.compactMap { sym in
                    let v = sym.token // precomputed
                    if v.isEmpty { return nil }
                    let score = self.cosineSimilarity(qVec, v)
                    return SearchResult(symbol: sym, score: score)
                }.sorted(by: { $0.score > $1.score })
            } else {
                let qVec = self.tfidfVector(for: query)
                results = symbols.compactMap { sym in
                    guard let v = self.tfidfVectors[sym.id] else { return nil }
                    let score = self.cosineSimilarity(qVec, v)
                    return SearchResult(symbol: sym, score: score)
                }.sorted(by: { $0.score > $1.score })
            }
        }
        return Array(results.prefix(topK))
    }

    /// Add or update a symbol in the index
    public func upsert(symbol: SFSymbol, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            self.symbols[symbol.id] = symbol
            if !self.embeddingAvailable {
                // rebuild TF-IDF for simplicity
                self.computeTFIDFIndex()
            }
            DispatchQueue.main.async { completion?() }
        }
    }

    /// Remove a symbol from the index
    public func remove(id: String, completion: (() -> Void)? = nil) {
        queue.async(flags: .barrier) {
            self.symbols[id] = nil
            self.tfidfVectors[id] = nil
            DispatchQueue.main.async { completion?() }
        }
    }

    // MARK: - Helpers

    private func embeddingVector(for text: String) -> [Double]? {
        #if canImport(NaturalLanguage)
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            if let emb = NLEmbedding.sentenceEmbedding(for: .english),
               let vec = emb.vector(for: text) {
                return vec.map { Double($0) }
            }
        }
        #endif
        return nil
    }

    // MARK: - TF-IDF fallback (from text)

    private func computeTFIDFIndex() {
        // Build corpus tokens from text
        var docsTokens: [[String]] = []
        var docIds: [String] = []
        for s in symbols.values {
            let tokens = tokenize(s.text)
            docsTokens.append(tokens)
            docIds.append(s.id)
        }
        // Build vocabulary
        var vocabSet: Set<String> = []
        for tokens in docsTokens {
            for t in tokens { vocabSet.insert(t) }
        }
        vocabulary = Array(vocabSet).sorted()
        termIndex = [:]
        for (i, term) in vocabulary.enumerated() { termIndex[term] = i }
        let nDocs = Double(docsTokens.count)
        // compute document frequencies
        var df = Array(repeating: 0.0, count: vocabulary.count)
        for tokens in docsTokens {
            let uniq = Set(tokens)
            for t in uniq {
                if let idx = termIndex[t] {
                    df[idx] += 1.0
                }
            }
        }
        idf = df.map { dfVal in
            if dfVal <= 0 { return 0.0 }
            return log((1.0 + nDocs) / (1.0 + dfVal)) + 1.0
        }
        // compute TF-IDF vectors
        for (index, tokens) in docsTokens.enumerated() {
            var vec = Array(repeating: 0.0, count: vocabulary.count)
            var tfCounts: [String: Int] = [:]
            for t in tokens { tfCounts[t, default: 0] += 1 }
            let maxTf = tfCounts.values.max() ?? 1
            for (t, count) in tfCounts {
                if let idx = termIndex[t] {
                    let tf = Double(count) / Double(maxTf)
                    vec[idx] = tf * idf[idx]
                }
            }
            // normalize vector length
            let norm = sqrt(vec.reduce(0.0) { $0 + $1*$1 })
            if norm > 0 {
                vec = vec.map { $0 / norm }
            }
            tfidfVectors[docIds[index]] = vec
        }
    }

    private func tfidfVector(for query: String) -> [Double] {
        let tokens = tokenize(query)
        var vec = Array(repeating: 0.0, count: vocabulary.count)
        guard !vocabulary.isEmpty else { return vec }
        var tfCounts: [String: Int] = [:]
        for t in tokens { tfCounts[t, default: 0] += 1 }
        let maxTf = tfCounts.values.max() ?? 1
        for (t, count) in tfCounts {
            if let idx = termIndex[t] {
                let tf = Double(count) / Double(maxTf)
                vec[idx] = tf * idf[idx]
            }
        }
        let norm = sqrt(vec.reduce(0.0) { $0 + $1*$1 })
        if norm > 0 {
            vec = vec.map { $0 / norm }
        }
        return vec
    }

    // MARK: - Tokenization (for TF-IDF)

    private func tokenize(_ text: String) -> [String] {
        let t = config.lowercase ? text.lowercased() : text
        let tokenizer = NLTokenizer(unit: .sentence)
        tokenizer.string = t
        var tokens: [String] = []
        tokenizer.enumerateTokens(in: t.startIndex..<t.endIndex) { tokenRange, _ in
            let token = String(t[tokenRange])
            let trimmed = token.trimmingCharacters(in: .punctuationCharacters.union(.whitespacesAndNewlines))
            if trimmed.count >= self.config.minTokenLength {
                if self.config.stopWords.contains(trimmed) == false {
                    let digitsAndSymbols = CharacterSet.decimalDigits.union(.punctuationCharacters).union(.symbols)
                    if trimmed.rangeOfCharacter(from: digitsAndSymbols.inverted) != nil {
                        tokens.append(trimmed)
                    }
                }
            }
            return true
        }
        return tokens
    }

    // MARK: - Utilities: cosine similarity
    private func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count else {
            let minCount = min(a.count, b.count)
            var dot = 0.0, norma = 0.0, normb = 0.0
            for i in 0..<minCount {
                dot += a[i] * b[i]
                norma += a[i] * a[i]
                normb += b[i] * b[i]
            }
            let denom = sqrt(norma) * sqrt(normb)
            if denom == 0 { return 0 }
            return dot / denom
        }
        var dot = 0.0, norma = 0.0, normb = 0.0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            norma += a[i] * a[i]
            normb += b[i] * b[i]
        }
        let denom = sqrt(norma) * sqrt(normb)
        if denom == 0 { return 0 }
        return dot / denom
    }
}

    /// Minimal model for an SF Symbol entry used for on-device semantic search.
    /// Contains an `id` (e.g. "square.and.arrow.up") and a lazily computed `token` as [Double] (embedding vector).
public struct SFSymbol: Identifiable, Hashable, Codable {
    public let id: String     // unique id, use the SF Symbol name like "square.and.arrow.up"
    public var token: [Double] = []
    public var text: String { id.split(separator: ".").joined(separator: " ") }

    public init(id: String, tokenize: Bool = false) {
        self.id = id

        if tokenize {
            self.tokenize()
        }
    }

    public mutating func tokenize() {
        self.token = tokenize(text: text)
    }

        /// Lazily computed embedding vector for the text.
        /// Uses NLEmbedding if available, otherwise returns empty array (fallback handled in search engine).
    func tokenize(text: String) -> [Double] {
#if canImport(NaturalLanguage)
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            if let emb = NLEmbedding.sentenceEmbedding(for: .english),
               let vec = emb.vector(for: text) {
                return vec.map { Double($0) }
            }
        }
#endif
        return [] // empty if embedding not available; search engine will handle TF-IDF fallback
    }
}
