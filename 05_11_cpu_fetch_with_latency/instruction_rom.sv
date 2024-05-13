//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024 by Yuri Panchul & Mike Kuskov
//  for systemverilog-homework project.
//

module instruction_rom
#(
    parameter SIZE = 64
)
(
    input               clk,
    input        [31:0] a,
    output logic [31:0] rd
);
    reg [31:0] rom [0:SIZE - 1];

    // We intentionally introduce latency here

    always_ff @ (posedge clk)
        rd <= rom [a];

    initial $readmemh ("program.hex", rom);

endmodule
