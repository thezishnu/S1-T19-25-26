// Dataflow (continuous assign) implementation
module combined_disaster_dataflow(
    input  [6:0] rain,     // 0..127
    input  [4:0] seismic,  // scaled 0..31
    input  [6:0] wind,     // 0..127
    input  [6:0] sea,      // 0..127
    input  mode,           // 1 = MULTI (raw), 0 = UNIQUE (priority)
    output flood_led,
    output cyclone_led,
    output earthquake_led,
    output tsunami_led,
    output safe_led,
    output danger_led
);

    // ---------------------------
    // Comparators -> GE signals
    // Rain thresholds (2,10,30,31)
    wire GE_R2  = (rain >= 7'd2);
    wire GE_R10 = (rain >= 7'd10);
    wire GE_R30 = (rain >= 7'd30);
    wire GE_R31 = (rain >= 7'd31);

    // Seismic thresholds (scaled: 0.2->2, 0.6->6, 1.5->15, 1.6->16)
    wire GE_S2  = (seismic >= 5'd2);
    wire GE_S6  = (seismic >= 5'd6);
    wire GE_S15 = (seismic >= 5'd15);
    wire GE_S16 = (seismic >= 5'd16);

    // Wind thresholds (16,30,60,61)
    wire GE_W16 = (wind >= 7'd16);
    wire GE_W30 = (wind >= 7'd30);
    wire GE_W60 = (wind >= 7'd60);
    wire GE_W61 = (wind >= 7'd61);

    // Sea thresholds (6,20,50,51)
    wire GE_L6  = (sea >= 7'd6);
    wire GE_L20 = (sea >= 7'd20);
    wire GE_L50 = (sea >= 7'd50);
    wire GE_L51 = (sea >= 7'd51);

    // ---------------------------
    // Encoders (dataflow, using OR/XOR)
    wire r1, r0, s1, s0, w1, w0, l1, l0;

    assign r1 = GE_R10 | GE_R30;
    assign r0 = (GE_R2 ^ GE_R10) | GE_R31;

    assign s1 = GE_S6 | GE_S15;
    assign s0 = (GE_S2 ^ GE_S6) | GE_S16;

    assign w1 = GE_W30 | GE_W60;
    assign w0 = (GE_W16 ^ GE_W30) | GE_W61;

    assign l1 = GE_L20 | GE_L50;
    assign l0 = (GE_L6 ^ GE_L20) | GE_L51;

    // ---------------------------
    // Disaster condition logic (dataflow)
    wire earthquake, tsunami, flood, cyclone;

    assign earthquake = s1 | s0;
    assign tsunami   = (s1 & s0) | l1;
    assign flood     = r1 & (w1 | l1 | r0);
    assign cyclone   = w1 & (w0 | l1 | r1);

    // ---------------------------
    // Priority encoder (unique mode) - dataflow
    wire cyclone_and_not_e;
    assign cyclone_and_not_e = cyclone & (~earthquake);

    wire code1, code0;
    assign code1 = tsunami | earthquake;
    assign code0 = tsunami | cyclone_and_not_e;

    wire ncode1, ncode0;
    assign ncode1 = ~code1;
    assign ncode0 = ~code0;

    wire Df, Dc, De, Dt;
    assign Df = ncode1 & ncode0;
    assign Dc = ncode1 & code0;
    assign De = code1 & ncode0;
    assign Dt = code1 & code0;

    // ---------------------------
    // Final outputs depending on mode
    // mode = 1 -> raw conditions (MULTI)
    // mode = 0 -> unique decoded (UNIQUE)
    assign flood_led      = (mode & flood)  | ((~mode) & Df);
    assign cyclone_led    = (mode & cyclone)| ((~mode) & Dc);
    assign earthquake_led = (mode & earthquake)| ((~mode) & De);
    assign tsunami_led    = (mode & tsunami) | ((~mode) & Dt);

    // ---------------------------
    // Safe / Danger (based on raw conditions)
    assign danger_led = flood | cyclone | earthquake | tsunami;
    assign safe_led   = ~danger_led;

endmodule
