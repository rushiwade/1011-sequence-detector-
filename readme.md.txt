
# 🔹 1011 Sequence Detector FSM (Mealy, Overlapping)

## 📌 Project Overview

This project implements and verifies a **1011 sequence detector FSM** using **SystemVerilog**.

* **FSM Type:** Mealy
* **Overlap:** Allowed (detects overlapping sequences like `1011011`)
* **Reset:** Active-high, synchronous
* **Clock:** Rising-edge triggered
* **Output:** `det` → 1-cycle pulse when pattern `1011` is detected

---

## 📁 Repository Contents

```
├── seq1011_mealy_overlap.sv    # DUT (FSM RTL code)
├── tb_seq1011_directed.sv      # Directed testbench with assertions
├── tb_seq1011_random.sv        # Randomized testbench with coverage
├── verification_report.md      # Verification report (results, coverage, waveforms)
├── run_tb.do                   # .do script for Questa automation
└── README.md                   # This file
```

---

## ⚙️ Setup Instructions

### Tool

* **Questa Intel Starter FPGA Edition 2024.3** (or any Questa/ModelSim version)

### Compile & Run (Directed TB)

```tcl
vlib work
vlog -sv seq1011_mealy_overlap.sv tb_seq1011_directed.sv
vsim -voptargs=+acc tb_seq1011_directed
add wave -r /*
run -all
```

### Compile & Run (Random TB)

```tcl
vlog -sv seq1011_mealy_overlap.sv tb_seq1011_random.sv
vsim -voptargs=+acc tb_seq1011_random +N_CYCLES=5000 +SEED=123
add wave -r /*
run -all
```

### Using `.do` Script

Instead of typing commands every time, run:

```tcl
do run_tb.do
```

---

## 📊 Verification Summary

### Directed Tests

* ✅ Detects `1011` correctly
* ✅ Handles overlaps (`1011011` → 2 detections)
* ✅ Works with leading 0s/1s
* ✅ No false positives

### Random Tests (5000 cycles)

* ✅ Coverage achieved:

  * Input bit distribution: 100%
  * All 4-bit windows: 100%
  * Detection cross coverage: 100%
* ✅ No assertion failures

---

## 🔍 Example Waveform

* Input: `1 0 1 1 0 1 1`
* `det` pulses high on **4th** and **7th** bits.

Waveforms are saved as:

* `seq1011_directed.wlf` (Questa native)
* `seq1011_random.vcd` (portable for GitHub viewers)

---

## ✅ Final Status

**FSM 1011 Sequence Detector verified successfully.**

* DUT matches specification
* Coverage closure achieved
* Assertions passed
* Repo ready for submission/documentation

