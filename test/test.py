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

    # Test cases with different `ui_in` and `uio_in` values
    test_cases = [
        {"ui_in": 50, "uio_in": 128},
        {"ui_in": 80, "uio_in": 100},
        {"ui_in": 100, "uio_in": 150},
        {"ui_in": 120, "uio_in": 200},
    ]

    for idx, case in enumerate(test_cases):
        # Apply inputs
        dut.ui_in.value = case["ui_in"]
        dut.uio_in.value = case["uio_in"]

        # Wait for multiple clock cycles to allow inputs to propagate
        for _ in range(10):
            await RisingEdge(dut.clk)

        # Check for unresolved values before logging
        uo_out_val = dut.uo_out.value
        uio_out_val = dut.uio_out.value

        # Verify that output values are resolved
        if 'x' in str(uo_out_val) or 'z' in str(uo_out_val):
            dut._log.warning(f"Unresolved uo_out value in test case {idx + 1}")
            uo_out_display = "Unresolved"
        else:
            uo_out_display = f"{int(uo_out_val):08b}"

        if 'x' in str(uio_out_val) or 'z' in str(uio_out_val):
            dut._log.warning(f"Unresolved uio_out value in test case {idx + 1}")
            uio_out_display = "Unresolved"
        else:
            uio_out_display = f"{int(uio_out_val):08b}"

        dut._log.info(
            f"Test case {idx + 1}: ui_in={case['ui_in']}, uio_in={case['uio_in']} -> "
            f"uo_out={uo_out_display}, uio_out={uio_out_display}"
        )

    # Final log for test completion
    dut._log.info("Completed perceptron test cases")
