# SHA-256 Hardware Accelerator with UART Interface

## 📌 Project Overview
This project implements a high-speed **SHA-256 Hashing Engine** on an FPGA, developed during my internship at **ECIL, Hyderabad**. The design features an automated padding unit and a UART interface for seamless data transmission between a host PC and the FPGA.



## 🚀 Key Features
- **Algorithm:** SHA-256 (Secure Hash Algorithm 2)
- **Clock:** 200 MHz Differential Input (optimized for high-performance Xilinx boards).
- **UART Interface:** 115,200 Baud Rate for data I/O.
- **Auto-Padding:** Automatically pads input messages up to 448 bits to fulfill the 512-bit SHA block requirement.
- **Hardware Acceleration:** Computes the 256-bit hash in 64 clock cycles after padding.

## 📂 Repository Structure
- **/rtl**: Contains the Verilog source code.
  - `top_uart_sha256.v`: Main top-level module.
  - `uart.v`: Handles serial communication.
  - `top_sha_256.v`: Integration of padding and hashing.
  - `pading_new.v`: Pre-processing logic.
  - `sha.v`: The core computation engine.
- **/sim**: Contains the testbench for verification.
- **/constraints**: `.xdc` files for pin mapping.

## 🛠 How it Works
1. **Reception:** The system waits for 56 bytes (448 bits) of raw data via the `rx_serial` pin.
2. **Padding:** The `pading_new` module appends the '1' bit and length values.
3. **Hashing:** The `sha` module executes 64 rounds of compression using logical functions (Sigma, Choice, Majority).
4. **Transmission:** The resulting 256-bit digest is sent back byte-by-byte via `tx_serial`.



## 🧪 Simulation
To verify the design:
1. Open your simulator (Vivado XSIM / ModelSim).
2. Load the files in the `/rtl` folder.
3. Run the simulation using the provided testbench in `/sim`.
4. Verify the output hash against standard SHA-256 test vectors.

## 📜 Credits
**Author:** Chitresh Sharma  
**Guidance:** Mrs. K. Madhuri (Sr. Dy. General Manager, CR&D, ECIL)  
**Institution:** Guru Nanak Institutions Technical Campus (GNITC)