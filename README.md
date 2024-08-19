# debouncer_ip
Debouncer ip FPGA verilog/systemverilog

## Debouncing a Switch

## Introduction

Using mechanical buttons is one of the most common ways to interact with electronic devices. It's surprising to think that something as simple as pressing a button can involve so many issues when reading that signal. From a mechanical standpoint, a button is nothing more than two metal plates that come together to form an electrical connection when pressed. However, when these plates come together, they often bounce before reaching a stable state. This becomes problematic when working with very fast clock signals, in the order of MHz in the case of FPGAs, as these bounces cause the read signal to register multiple presses instead of just one.


## References

[1] “Debounce Logic Circuit (Verilog) - Semiconductor / Logic Design,” Electronic Component and Engineering Solution Forum - TechForum │ DigiKey. Accessed: May 25, 2024. [Online]. Available: https://forum.digikey.com/t/debounce-logic-circuit-verilog/13196

[2] “Debounce Logic Circuit (VHDL) - Semiconductor / Logic Design,” Electronic Component and Engineering Solution Forum - TechForum │ DigiKey. Accessed: May 25, 2024. [Online]. Available: https://forum.digikey.com/t/debounce-logic-circuit-vhdl/12573

[3] *Debounce a Switch*, (Sep. 26, 2018). Accessed: May 25, 2024. [Online Video]. Available: https://www.youtube.com/watch?v=e1-kc04jSE4
