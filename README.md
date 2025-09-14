# CI’d SystemVerilog Adder (Icarus + Perl + Jenkins)

Minimal, resume-ready verification flow:
- **DUT**: `adder4.sv` (clocked 4-bit adder → 5-bit sum)
- **TB**: `tb_adder4.sv` (self-checking: directed + random vectors, VCD dump)
- **Sim**: Icarus Verilog (`iverilog` / `vvp`)
- **Reports**: Perl parser → `junit.xml` (CI), `results.csv`, `report.html`
- **CI**: Jenkins pipeline compiles → runs → parses → archives artifacts; build fails on test failures

## Repo Layout
.
├─ adder4.sv # DUT (sequential adder with clk)
├─ tb_adder4.sv # self-checking testbench (prints RESULT/SUMMARY)
├─ parse_results.pl # Perl: sim.log -> junit.xml, results.csv, report.html (nonzero exit on failures)
└─ Jenkinsfile # pipeline: compile → run → parse → publish

## Prerequisites
- Icarus Verilog (`iverilog`, `vvp`)
- Perl (Strawberry Perl on Windows; system Perl on Linux/macOS)
- (Optional) GTKWave for viewing VCD waveforms
- Git; Jenkins if running CI
- Docker Desktop (optional) if you want Jenkins in a container


