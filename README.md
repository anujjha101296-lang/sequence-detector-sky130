# 1011 sequence detector (Moore, overlapping) - verification + Sky130 synthesis
Files: `seq_det.v`, `tb.v` (self-checking: directed, exhaustive 12-bit streams, 200k random cycles with random resets), `synth_sky130.ys`, `seq_det_gate.v`, `sky130_stat.txt`.
- RTL sim (Icarus): 253,293 checks, 14,025 detections, 0 errors.
- Mutation test: 5/5 injected bugs fail the testbench.
- Gate-level netlist (Yosys/ABC) passes the same bench; bounded SAT miter vs RTL: proven for 24 cycles from reset (Yosys re-encodes the FSM, so register-level `equiv_induct` does not apply).
- Sky130 HD tt_025C_1v80 mapping (Yosys + ABC): 12 cells (5 dfxtp_1), 143.9 um^2.
Limits: no place-and-route, DRC/LVS or fabrication here; this is NOT the efabless MPW8 tape-out. The 1011 pattern is an example, not the taped-out RTL.
