module combined_disaster_behavioral(
    input  [6:0] rain,      // 0–127
    input  [4:0] seismic,   // scaled 0–31
    input  [6:0] wind,      // 0–127
    input  [6:0] sea,       // 0–127
    input  mode,            // 1 = MULTI, 0 = UNIQUE
    output reg flood_led,
    output reg cyclone_led,
    output reg earthquake_led,
    output reg tsunami_led,
    output reg safe_led,
    output reg danger_led
);

    // Factor codes
    reg r1, r0, s1, s0, w1, w0, l1, l0;

    // Disaster conditions
    reg flood, cyclone, earthquake, tsunami;

    // Priority decoder output
    reg Df, Dc, De, Dt;

    always @(*) begin
        
        // --------------------------
        // RAIN (limits: 2,10,30,31)
        r1 = (rain >= 10) || (rain >= 30);
        r0 = ((rain >= 2) ^ (rain >= 10)) || (rain >= 31);

        // --------------------------
        // SEISMIC (scaled limits: 2,6,15,16)
        s1 = (seismic >= 6)  || (seismic >= 15);
        s0 = ((seismic >= 2) ^ (seismic >= 6)) || (seismic >= 16);

        // --------------------------
        // WIND (limits: 16,30,60,61)
        w1 = (wind >= 30) || (wind >= 60);
        w0 = ((wind >= 16) ^ (wind >= 30)) || (wind >= 61);

        // --------------------------
        // SEA LEVEL (limits: 6,20,50,51)
        l1 = (sea >= 20) || (sea >= 50);
        l0 = ((sea >= 6) ^ (sea >= 20)) || (sea >= 51);

        // --------------------------
        // DISASTER CONDITIONS
        earthquake = s1 || s0;
        tsunami    = (s1 && s0) || l1;
        flood      = r1 && (w1 || l1 || r0);
        cyclone    = w1 && (w0 || l1 || r1);

        // --------------------------
        // PRIORITY: Tsunami > Earthquake > Cyclone > Flood
        Df = 0; Dc = 0; De = 0; Dt = 0;

        if (tsunami) begin
            Dt = 1;
        end
        else if (earthquake) begin
            De = 1;
        end
        else if (cyclone) begin
            Dc = 1;
        end
        else if (flood) begin
            Df = 1;
        end

        // --------------------------
        // FINAL LED OUTPUTS (mode selects)
        if (mode == 1) begin
            flood_led      = flood;
            cyclone_led    = cyclone;
            earthquake_led = earthquake;
            tsunami_led    = tsunami;
        end else begin
            flood_led      = Df;
            cyclone_led    = Dc;
            earthquake_led = De;
            tsunami_led    = Dt;
        end

        // --------------------------
        // SAFE / DANGER LED
        danger_led = flood || cyclone || earthquake || tsunami;
        safe_led   = ~danger_led;
    end

endmodule
