# SPECK32/64 Lightweight Block Cipher: Verilog RTL with ESP32 OLED Demonstrator

Verilog RTL implementation and simulation-based verification of **SPECK32/64** (32-bit block, 64-bit key, 22 rounds), plus a battery-powered ESP32 + OLED display demonstrator for IoT security.

**Paper:** *RTL Implementation and Simulation-Based Verification of the SPECK32/64 Lightweight Block Cipher with an ESP32 Display Demonstrator for IoT Security*
**DOI:** `<ZENODO DOI>`

**Authors:** Abhinaya H B, B Kirana Sindhu Shree, Bhakthi B, Likitha D V (Dept. of ECE, East West Institute of Technology, Bengaluru, India)

## Structure
```
rtl/       speck_round.v, speck_key_expansion.v, speck_top.v (encrypt), speck_decrypt.v
tb/        tb_speck.v  (self-checking: test vector + encrypt/decrypt round trip)
firmware/  ESP32 Arduino sketch (OLED display demo)
docs/      paper PDF, block diagram, waveforms
```

## Design
- Iterative architecture: one round per clock, 22 rounds per block
- `speck_key_expansion`: sequential, one 16-bit round key per `step`; key loaded on `load`
- `speck_top`: FSM IDLE → RUN (22 rounds, `busy` high) → DONE (latch ciphertext, pulse `done`)
- `speck_decrypt`: 22-cycle key generation (stored), then 22 inverse rounds

## Test vector (hex)
| Key | Plaintext | Ciphertext |
|---|---|---|
| 1918 1110 0908 0100 | 6574 694C | A868 42F2 |

## Run the simulation
**Vivado:** add `rtl/*.v` and `tb/tb_speck.v`, set `tb_speck` as top, run behavioral simulation.
**ModelSim/Questa:**
```
vlog rtl/*.v tb/tb_speck.v
vsim -c tb_speck -do "run -all; quit"
```
**Icarus Verilog:**
```
iverilog -o sim rtl/*.v tb/tb_speck.v && vvp sim
```
Expected console output:
```
Ciphertext = a86842f2 (expected a86842f2)
Decrypted  = 6574694c (expected 6574694c)
VERIFY: PASS
```

## ESP32 demonstrator
ESP32 + I2C SSD1306 OLED, LM2596 buck converter, two 18650 cells. Arduino IDE with the ESP32 Arduino Core and Adafruit SSD1306/GFX. The ESP32 **only displays** values verified in simulation; it does not run the RTL.

## Limitations
Simulation only (no FPGA/ASIC synthesis, so no area, frequency, or power results); SPECK32/64 only; small set of test vectors.

## License
Code: MIT (see `LICENSE`). Paper: CC BY 4.0.
