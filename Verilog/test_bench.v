`timescale 1ns/1ps
module tb_disaster_all;
    reg  r1, r0, s1, s0, w1, w0, l1, l0, mode;
    wire flood_led_g, cyclone_led_g, earthquake_led_g, tsunami_led_g;
    wire flood_led_d, cyclone_led_d, earthquake_led_d, tsunami_led_d;
    wire flood_led_b, cyclone_led_b, earthquake_led_b, tsunami_led_b;

    disaster_gate       U_GATE (.r1(r1), .r0(r0), .s1(s1), .s0(s0), .w1(w1), .w0(w0), .l1(l1), .l0(l0), .mode(mode),
                                .flood_led(flood_led_g), .cyclone_led(cyclone_led_g), .earthquake_led(earthquake_led_g), .tsunami_led(tsunami_led_g));
    disaster_dataflow   U_DATA (.r1(r1), .r0(r0), .s1(s1), .s0(s0), .w1(w1), .w0(w0), .l1(l1), .l0(l0), .mode(mode),
                                .flood_led(flood_led_d), .cyclone_led(cyclone_led_d), .earthquake_led(earthquake_led_d), .tsunami_led(tsunami_led_d));
    disaster_behavioral U_BEH  (.r1(r1), .r0(r0), .s1(s1), .s0(s0), .w1(w1), .w0(w0), .l1(l1), .l0(l0), .mode(mode),
                                .flood_led(flood_led_b), .cyclone_led(cyclone_led_b), .earthquake_led(earthquake_led_b), .tsunami_led(tsunami_led_b));

    initial begin
        $dumpfile("disaster.vcd");
        $dumpvars(0, tb_disaster_all);
    end

    integer i, m, sno, curr_active, max_active;
    reg [7:0] max_active_vector;
    reg [8*256:1] outstr;

    initial begin
        sno = 0;
        max_active = 0;
        max_active_vector = 8'hFF;
        $display("Sno | Mode | R1R0 | S1S0 | W1W0 | L1L0 | Output (Flood, Cyclone, Earthquake, Tsunami)");
        $display("----+------+-------+-------+-------+-------+--------------------------------------------------------------");
        for (m = 0; m <= 1; m = m + 1) begin
            mode = m;
            for (i = 0; i < 256; i = i + 1) begin
                {r1,r0,s1,s0,w1,w0,l1,l0} = i[7:0];
                #1;
                sno = sno + 1;
                outstr = "";
                if (mode == 0) begin
                    if (flood_led_g)      outstr = "flood";
                    else if (cyclone_led_g) outstr = "cyclone";
                    else if (earthquake_led_g) outstr = "earthquake";
                    else if (tsunami_led_g) outstr = "tsunami";
                    else outstr = "none";
                end else begin
                    if (flood_led_g)      $sformat(outstr, "%s%s", outstr, (outstr=="" ? "flood" : ", flood"));
                    if (cyclone_led_g)    $sformat(outstr, "%s%s", outstr, (outstr=="" ? "cyclone" : ", cyclone"));
                    if (earthquake_led_g) $sformat(outstr, "%s%s", outstr, (outstr=="" ? "earthquake" : ", earthquake"));
                    if (tsunami_led_g)    $sformat(outstr, "%s%s", outstr, (outstr=="" ? "tsunami" : ", tsunami"));
                    if (outstr == "") outstr = "none";
                end
                curr_active = flood_led_g + cyclone_led_g + earthquake_led_g + tsunami_led_g;
                if (curr_active > max_active) begin
                    max_active = curr_active;
                    max_active_vector = i[7:0];
                end
                $display("%4d |  %b    |  %b%b   |  %b%b   |  %b%b   |  %b%b   | %-60s",
                         sno, mode, r1, r0, s1, s0, w1, w0, l1, l0, outstr);
            end
        end
        #5;
        $display("");
        $display("=== SUMMARY ===");
        $display("Total vectors printed : %0d", sno);
        $display("Maximum simultaneous disasters observed : %0d", max_active);
        if (max_active_vector != 8'hFF)
            $display("First vector with max disasters: i=%0d  (r1r0=%b, s1s0=%b, w1w0=%b, l1l0=%b)",
                     max_active_vector,
                     max_active_vector[7], max_active_vector[6],
                     max_active_vector[5], max_active_vector[4],
                     max_active_vector[3], max_active_vector[2],
                     max_active_vector[1], max_active_vector[0]);
        $finish;
    end
endmodule
