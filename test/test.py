# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_multiplexed_neurons(dut):
    # Set up a 100 MHz clock (10 ns period)
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Log test start
    dut._log.info("Starting multiplexed neuron test")

    # Reset the DUT
    dut.rst_n.value = 0
    await Timer(20, units="ns")
    dut.rst_n.value = 1
    await Timer(20, units="ns")  # Allow time for reset

    # Define input currents and weights for each of the 8 neurons
    currents = [20, 40, 60, 80, 100, 120, 140, 160]
    weights = [128, 130, 135, 140, 145, 150, 155, 160]

    # Simulate time-multiplexed input for 8 neurons
    for cycle in range(8):
        # Apply input for the neuron indexed by `cycle`
        dut.ui_in.value = currents[cycle]
        dut.uio_in.value = weights[cycle]

        # Wait for a few clock cycles to let the neuron process the input
        for _ in range(3):
            await RisingEdge(dut.clk)

        # Capture and log the outputs
        uo_out_val = dut.uo_out.value
        uio_out_val = dut.uio_out.value

        # Check for unresolved values before logging
        if 'x' in str(uo_out_val) or 'z' in str(uo_out_val):
            dut._log.warning(f"Unresolved uo_out value in cycle {cycle}")
            uo_out_display = "Unresolved"
        else:
            uo_out_display = f"{int(uo_out_val):08b}"

        if 'x' in str(uio_out_val) or 'z' in str(uio_out_val):
            dut._log.warning(f"Unresolved uio_out value in cycle {cycle}")
            uio_out_display = "Unresolved"
        else:
            uio_out_display = f"{int(uio_out_val):08b}"

        dut._log.info(
            f"Cycle {cycle + 1}: ui_in={currents[cycle]}, uio_in={weights[cycle]} -> "
            f"uo_out={uo_out_display}, uio_out={uio_out_display}"
        )

    # Final log for test completion
    dut._log.info("Completed multiplexed neuron test")
