# SHA-256 Hardware Accelerator with UART Interface
**Internship Project | Electronics Corporation of India Limited (ECIL), Hyderabad**

## 📌 Project Overview
This repository contains the hardware implementation of a high-speed **SHA-256 Hashing Engine** developed during my internship at **ECIL**. The system is designed to perform cryptographic hashing on an FPGA, featuring an automated hardware padding unit and a UART interface for seamless communication with a host PC.



## 🚀 Key Features
- **Algorithm:** Full SHA-256 implementation (Secure Hash Algorithm 2).
- **Clock:** 200 MHz Differential Input (utilizing `IBUFDS` buffers for Xilinx Artix-7/AC701).
- **UART Interface:** 115,200 Baud Rate for real-time data I/O.
- **Auto-Padding:** Custom hardware logic to append the '1' bit and 64-bit length value to messages up to 448 bits.
- **Performance:** Computes the 256-bit digest in exactly 64 clock cycles post-padding.

## 📂 Repository Structure
- **/rtl**: Core Verilog source files.
  - `top_uart_sha256.v`: Main top-level integration.
  - `uart.v`: RS-232 serial communication module.
  - `top_sha_256.v`: Integration layer for padding and hashing cores.
  - `pading_new.v`: Pre-processing unit for message padding.
  - `sha.v`: The 64-round compression engine.
- **/sim**: Testbench files for functional verification.
- **/constraints**: `.xdc` files for Artix-7 physical pin mapping.
- **/docs**: Contains the [Full Internship Report](./docs/Final_report_chitresh_31-10.pdf) detailing the architecture and results.

## 🛠 Functional Workflow
1. **Reception:** The system captures 56 bytes (448 bits) of raw data via the `rx_serial` pin.
2. **Padding:** The `pading_new` module automatically prepares the 512-bit block required by the NIST standard.
3. **Hashing:** The `sha` engine executes 64 compression rounds using Sigma, Choice, and Majority functions.
4. **Transmission:** The final 256-bit hash is transmitted back to the host PC byte-by-byte via `tx_serial`.

## 🧪 Simulation & Verification
The design was verified using **Xilinx Vivado XSIM** against standard SHA-256 test vectors. 



To verify the logic:
1. Load the files in the `/rtl` folder into Vivado.
2. Run the testbench located in `/sim`.
3. Observe the `hash` output register upon the `complete` signal assertion.

## 📜 Credits
- **Author:** Chitresh Sharma (Roll No: 22WJ8A0409)
- **Guidance:** Mrs. K. Madhuri (Sr. Dy. General Manager, CR&D, ECIL)
- **Institution:** Guru Nanak Institutions Technical Campus (GNITC)
