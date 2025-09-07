# RISC Zero zkVM: Technical Architecture

## Core Architecture

RISC Zero is a general-purpose zero-knowledge virtual machine that executes arbitrary code written in Rust, C++, and other languages within zero-knowledge proofs. The system uses the RISC-V rv32im architecture and implements a STARK-based proof system. The architecture centers on a multi-stage proving pipeline that handles large computations through segmentation and recursion.

## Execution Model and REM

The system generates and proves an execution trace for program verification. Guest programs are compiled to RISC-V ELF binaries and executed by risc0-zkvm. The RISC Zero Electronic Machine (REM) serves as the core component, mapping RISC-V instructions to algebraic constraints.

During execution, the REM produces a two-dimensional execution trace where each row represents a clock cycle and each column corresponds to a register or channel representing the machine state. This trace structure enables comprehensive verification of program execution.

## STARK-Based Cryptographic Foundation

RISC Zero employs a STARK proof system called "0STARK" that utilizes the DEEP-ALI protocol with batched FRI (Fast Reed-Solomon Interactive Oracle Proof of Proximity).

### Constraint System
Computational correctness is enforced through Arithmetic Intermediate Representation (AIR) constraints—polynomial equations that must hold across every row of the execution trace. The REM defines the complete constraint set for RISC-V CPU verification.

### Low-Degree Extension
The execution trace is interpreted as a polynomial and interpolated over a larger domain using FFT to create a Reed-Solomon codeword. This process adds redundancy that enables efficient probabilistic verification.

### FRI Protocol
The prover commits to trace polynomials, and the verifier challenges the prover to evaluate these polynomials at random points. FRI enables verification that polynomials maintain low degree without revealing the complete polynomial. The protocol is transparent, requiring no trusted setup, and provides post-quantum security.

### Zero-Knowledge Component
Zero-knowledge properties are achieved by blending the execution trace with random noise (ZK blinding factors) before the Low-Degree Extension. This approach conceals trace data while preserving the constraint structure necessary for verification.

## Memory Architecture and Execution Model

RISC Zero implements a three-circuit recursive proving system with a user/kernel split architecture.

### User/Kernel Split
The system maintains separation between user and machine modes, with the kernel functioning as an operating system that protects system resources. This architecture enables 3GB of user memory in R0VM 2.0, representing a 15x increase over previous versions.

### Segmented Execution
Large programs are handled through segmented execution to prevent memory explosion. Execution is divided into fixed-size segments or continuations. Individual STARK proofs are generated for each segment in parallel, then recursively aggregated into a single proof for the complete program.

## Three-Layer Receipt System

RISC Zero produces proofs called "receipts" in three formats to address different cost-performance requirements:

### Composite Receipt
A collection of individual zk-STARK proofs for each execution segment. This format generates fastest but produces the largest proofs and requires the most verification overhead.

### Succinct Receipt
A single, constant-size STARK proof created through recursive aggregation of segment proofs. This format is optimal for off-chain verification where proof size matters but gas costs are not the primary concern.

### Groth16 Receipt
An optional compression layer where a zk-SNARK proof (Groth16) demonstrates possession of a valid succinct receipt. These proofs are extremely compact (hundreds of bytes) and optimized for minimal verification cost and low blockchain gas fees.

## Key Components and Optimizations

### Receipt Structure
Proofs output as receipts contain the journal (public outputs) and the seal (the STARK proof component).

### Prover/Verifier Architecture
The codebase maintains clean separation between the computationally intensive prover and lightweight verifier. The verifier can be compiled to on-chain code including Solidity implementations.

### Bonsai Service
An external proving service that uses continuations and recursive composition to partition large proofs into manageable chunks. Bonsai operates as a decentralized network that abstracts hardware requirements, allowing developers to outsource proof generation.

### Accelerator Circuits
Specialized, hand-optimized circuits handle computationally expensive cryptographic operations such as Keccak hashing, ECDSA verification, and RSA operations. These circuits bypass standard RISC-V execution, significantly reducing proven cycles and improving prover efficiency.

### Security and Verification
RISC Zero emphasizes security through formal verification of RISC-V circuits, trusted setup ceremonies for Groth16 proofs, and regular external security audits.


