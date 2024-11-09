# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_perceptron(dut):
    # Set up a 100 MHz clock (10 ns period)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Log test start
    dut._log.info("Starting perceptron test")

    # Reset the DUT
    dut.rst_n.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await Timer(20, units="ns")  # Allow time for reset

    # Test cases with only `ui_in`
    test_cases = [
        {"ui_in": 50},
        {"ui_in": 80},
        {"ui_in": 100},
        {"ui_in": 120},
    ]

    for idx, case in enumerate(test_cases):
        # Apply input
        dut.ui_in.value = case["ui_in"]

        # Wait for multiple clock cycles to allow inputs to propagate
        for _ in range(5):
            await RisingEdge(dut.clk)

        # Log the outputs
        uo_out_val = dut.uo_out.value
        dut._log.info(
            f"Test case {idx + 1}: ui_in={case['ui_in']} -> uo_out={uo_out_val}"
        )

    # Final log for test completion
    dut._log.info("Completed perceptron test cases")
