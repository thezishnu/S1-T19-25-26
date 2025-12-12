`timescale 1ns/1ps

module tb;

    reg  [6:0] rain;
    reg  [4:0] seismic;
    reg  [6:0] wind;
    reg  [6:0] sea;
    reg        mode;

    wire flood_led, cyclone_led, earthquake_led, tsunami_led;
    wire safe_led, danger_led;

    // DUT
    combined_disaster_behavioral dut (
        .rain(rain),
        .seismic(seismic),
        .wind(wind),
        .sea(sea),
        .mode(mode),
        .flood_led(flood_led),
        .cyclone_led(cyclone_led),
        .earthquake_led(earthquake_led),
        .tsunami_led(tsunami_led),
        .safe_led(safe_led),
        .danger_led(danger_led)
    );

    initial begin
        // VCD dump
        $dumpfile("disaster_system.vcd");
        $dumpvars(0, tb);

        $display("time  |  rain seismic wind sea |  mode  | F C E T | safe danger");
        $display("--------------------------------------------------------------");

        // -------------------------
        // Testcase 1: Safe
        rain=1; seismic=0; wind=5; sea=2; mode=1;
        #10 $display("%0t | %3d   %2d      %3d  %3d |   %b   |  %b %b %b %b |   %b     %b",
                     $time, rain, seismic, wind, sea, mode,
                     flood_led, cyclone_led, earthquake_led, tsunami_led,
                     safe_led, danger_led);

        // -------------------------
        // Testcase 2: Flood
        rain=35; seismic=0; wind=20; sea=10; mode=1;
        #10 $display("%0t | %3d   %2d      %3d  %3d |   %b   |  %b %b %b %b |   %b     %b",
                     $time, rain, seismic, wind, sea, mode,
                     flood_led, cyclone_led, earthquake_led, tsunami_led,
                     safe_led, danger_led);

        // -------------------------
        // Testcase 3: Cyclone
        rain=8; seismic=0; wind=55; sea=25; mode=1;
        #10 $display("%0t | %3d   %2d      %3d  %3d |   %b   |  %b %b %b %b |   %b     %b",
                     $time, rain, seismic, wind, sea, mode,
                     flood_led, cyclone_led, earthquake_led, tsunami_led,
                     safe_led, danger_led);

        // -------------------------
        // Testcase 4: Tsunami due to Sea Level
        rain=0; seismic=2; wind=5; sea=60; mode=1;
        #10 $display("%0t | %3d   %2d      %3d  %3d |   %b   |  %b %b %b %b |   %b     %b",
                     $time, rain, seismic, wind, sea, mode,
                     flood_led, cyclone_led, earthquake_led, tsunami_led,
                     safe_led, danger_led);

        // -------------------------
        // Testcase 5: Earthquake only
        rain=1; seismic=6; wind=10; sea=2; mode=0; // UNIQUE -> earthquake shown
        #10 $display("%0t | %3d   %2d      %3d  %3d |   %b   |  %b %b %b %b |   %b     %b",
                     $time, rain, seismic, wind, sea, mode,
                     flood_led, cyclone_led, earthquake_led, tsunami_led,
                     safe_led, danger_led);

        // -------------------------
        // Testcase 6: Everything ON (ALL hazards)
        rain=127; seismic=31; wind=127; sea=127; mode=1;
        #10 $display("%0t | %3d   %2d      %3d  %3d |   %b   |  %b %b %b %b |   %b     %b",
                     $time, rain, seismic, wind, sea, mode,
                     flood_led, cyclone_led, earthquake_led, tsunami_led,
                     safe_led, danger_led);

        #10 $finish;
    end

endmodule
