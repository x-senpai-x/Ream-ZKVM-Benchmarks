# SP1 zkVM: Technical Architecture

## Core Architecture

SP1 is a STARK-based RISC-V zero-knowledge virtual machine optimized for performance and Ethereum integration. The system is designed for blockchain workloads and maintains full open-source availability.

## Cryptographic Foundation: Plonky3 STARKs

SP1 is built on Plonky3, a high-performance open-source STARK framework developed by Polygon Labs and written in Rust. Unlike RISC Zero's custom STARK implementation, SP1 leverages this established framework for its proving system.

### Performance Architecture
Plonky3 implements extensive SIMD (Single Instruction, Multiple Data) parallelism and optimized field arithmetic. The framework is designed with recursive proof composition as a core capability, enabling complex proving pipelines to scale effectively.

### Arithmetization System
SP1 uses AIR-based arithmetization, capturing virtual machine execution in traces verified through polynomial constraints. The system employs the Poseidon2 hash function over the 31-bit BabyBear finite field and uses the FRI protocol for low-degree verification.

### STARK-to-SNARK Compression
For on-chain verification, SP1 compresses STARK proofs into compact zk-SNARKs using either Groth16 or PLONK over the BN254 elliptic curve.

## Specialized Precompile System

SP1's precompile architecture addresses the performance challenges of executing cryptographic primitives within RISC-V virtual machines.

### Problem and Solution
Complex cryptographic operations such as Keccak256 and Secp256k1 operations generate massive execution traces when executed opcode-by-opcode in RISC-V. SP1 addresses this through precompiled functions that guest programs access via ecall instructions.

### Implementation Architecture
Precompile calls are handled outside main VM execution by the host prover, often using optimized circuits written in specialized frameworks like gnark ZK-DSL. Each precompile generates its own proof (typically a Groth16 SNARK), which is embedded and verified within the larger SP1 STARK proof. The STARK proof verifies the precompile's proof rather than the entire computation, reducing proven cycles for cryptography-heavy programs by 5-10x.

### Precompile Coverage
SP1 provides precompiles for cryptographic hash functions (Keccak256, SHA256), elliptic curve operations (secp256k1, ed25519, bn254, bls12-381), and blockchain-optimized cryptographic primitives. These are implemented as independent STARK tables ("chips") connected to the CPU table through cross-table lookups.

## Memory Management and Sharding

SP1 handles large computations through sharding, breaking long executions into smaller pieces with individual proofs combined recursively.

### Two-Phase Prover
The system implements a two-phase prover for efficient read-write memory using a single challenge from the verifier, avoiding merkelized memory overhead.

### Cross-Table Lookup System
The architecture models interconnected components as "chips" (CPU, ALU, memory, precompiles) with efficient cross-table lookup arguments enabling communication. This design allows different tables to reference common data without duplication. SP1 employs "Multi-table FRI" to avoid wasted proof effort on idle tables by committing values only for active chips.

## SP1 Hypercube Architecture

The SP1 Hypercube represents an architectural evolution to multilinear polynomials, achieving up to 5x performance improvements for compute-intensive workloads. This redesign targets real-time proving of Ethereum mainnet blocks within 12-second block times.

### Technical Implementation
The architecture utilizes a polynomial commitment scheme called "Jagged PCS" and an optimized sum-check protocol implementation via LogUp GKR. Performance benchmarks show proving capabilities for over 93% of Ethereum mainnet blocks in under 12 seconds, averaging 10.3 seconds on GPU clusters.

