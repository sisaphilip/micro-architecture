#!/bin/sh

rm -rf log.txt
rm -f lint.txt

#-----------------------------------------------------------------------------

assembly ()
{
    rars_jar=rars1_6.jar

    #  nc                              - Copyright notice will not be displayed
    #  a                               - assembly only, do not simulate
    #  ae<n>                           - terminate RARS with integer exit code if an assemble error occurs
    #  dump .text HexText program.hex  - dump segment .text to program.hex file in HexText format

    rars_args="nc a ae1 dump .text HexText program.hex"

    if command -v rars >/dev/null 2>&1
    then
        rars_cmd=rars
    else
        if ! command -v java >/dev/null 2>&1
        then
            echo "ERROR: java is not in the path or cannot be run."  \
                 "java is needed to run RARS,"                       \
                 "a RISC-V instruction set simulator."               \
                 "You can install it using"                          \
                 "'sudo apt-get install default-jre'"                \
                 2>&1

            echo "Press enter"
            read enter
            exit 1
        fi

        rars_cmd="java -jar ../../bin/$rars_jar"
    fi

    if ! $rars_cmd $rars_args program.s >> log.txt 2>&1
    then
        echo "ERROR: assembly failed. See log.txt." 2>&1
        grep Error log.txt
        echo "Press enter"
        read enter
        exit 1
    fi
}

#-----------------------------------------------------------------------------

simulate_rtl ()
{
    if ! command -v iverilog >/dev/null 2>&1
    then
        echo "ERROR: Icarus Verilog (iverilog) is not in the path"  \
             "or cannot be run."                                    \
             "See README.md file in the package directory"          \
             "for the instructions how to install Icarus."          \
              2>&1

        echo "Press enter"
        read enter
        exit 1
    fi

    rm -rf dump.vcd

       iverilog -g2005-sv *.sv >> log.txt 2>&1  \
    && vvp a.out               >> log.txt 2>&1

    if [ -f dump.vcd ] ; then
        gtkwave dump.vcd --script gtkwave.tcl
    fi
}

#-----------------------------------------------------------------------------

lint_code ()
{
    if [ "$1" = "--lint" ]
    then

        if command -v verilator > /dev/null 2>&1
        then
            run_lint=true
        else
        echo "ERROR [--lint]: Verilator is not in the path"                      \
             "or cannot be run."                                                 \
             "See README.md file in the package directory for the instructions"  \
             "how to install Verilator."                                         \
              2>&1

            echo "Press enter"
            read enter
            exit 1
        fi

    else
        run_lint=false
    fi

    for f in *.sv
    do
        if [ $run_lint = true ]
        then
            printf "==============================================\n\n" >> lint.txt
            printf "File: $f\n\n" >> lint.txt
            printf "==============================================\n\n" >> lint.txt

            verilator --lint-only -Wall --timing -Wno-MULTITOP \
            -Wno-DECLFILENAME -Wno-INITIALDLY $f >> lint.txt 2>&1

            sed -i '/- Verilator:/d' lint.txt
            sed -i '/- V e r i l a t i o n/d' lint.txt
        fi
    done
}

#-----------------------------------------------------------------------------

if [ -f program.s ] ; then
    assembly
fi

simulate_rtl
lint_code $1

# rm -f program.hex
  rm -f a.out

grep -m1 -e PASS -e FAIL -e ERROR -e Error -e error -e Timeout log.txt
