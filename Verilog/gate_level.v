module combined_disaster_with_comparators_or(
    input  [6:0] rain,     // 0..127
    input  [4:0] seismic,  // scaled 0..31
    input  [6:0] wind,     // 0..127
    input  [6:0] sea,      // 0..127
    input  mode,
    output flood_led, cyclone_led, earthquake_led, tsunami_led,
    output safe_led, danger_led
);

    // RAIN thresholds (2,10,30,31)
    wire GE_R2  = (rain >= 7'd2);
    wire GE_R10 = (rain >= 7'd10);
    wire GE_R30 = (rain >= 7'd30);
    wire GE_R31 = (rain >= 7'd31);

    wire r1, r0, xr;
    or  OR_r1 (r1, GE_R10, GE_R30);          
    xor X_r  (xr, GE_R2, GE_R10);
    or  OR_r0 (r0, xr, GE_R31);              

    // SEISMIC thresholds (scaled: 0.2->2, 0.6->6, 1.5->15, 1.6->16)
    wire GE_S2  = (seismic >= 5'd2);
    wire GE_S6  = (seismic >= 5'd6);
    wire GE_S15 = (seismic >= 5'd15);
    wire GE_S16 = (seismic >= 5'd16);

    wire s1, s0, xs;
    or  OR_s1 (s1, GE_S6, GE_S15);           
    xor X_s  (xs, GE_S2, GE_S6);
    or  OR_s0 (s0, xs, GE_S16);              

    // WIND thresholds (16,30,60,61)
    wire GE_W16 = (wind >= 7'd16);
    wire GE_W30 = (wind >= 7'd30);
    wire GE_W60 = (wind >= 7'd60);
    wire GE_W61 = (wind >= 7'd61);

    wire w1, w0, xw;
    or  OR_w1 (w1, GE_W30, GE_W60);          
    xor X_w  (xw, GE_W16, GE_W30);
    or  OR_w0 (w0, xw, GE_W61);              

    // SEA thresholds (6,20,50,51)
    wire GE_L6  = (sea >= 7'd6);
    wire GE_L20 = (sea >= 7'd20);
    wire GE_L50 = (sea >= 7'd50);
    wire GE_L51 = (sea >= 7'd51);

    wire l1, l0, xl;
    or  OR_l1 (l1, GE_L20, GE_L50);          
    xor X_l  (xl, GE_L6, GE_L20);
    or  OR_l0 (l0, xl, GE_L51);              

    // DISASTER LOGIC (unchanged)
    wire flood, cyclone, earthquake, tsunami;

    or  OR_eq   (earthquake, s1, s0);
    and AND_ts_and (ts_and, s1, s0);
    or  OR_ts   (tsunami, ts_and, l1);

    or  OR_fsup (flood_sup, w1, l1, r0);
    and AND_f   (flood, r1, flood_sup);

    or  OR_csup (cyclone_sup, w0, l1, r1);
    and AND_c   (cyclone, w1, cyclone_sup);

    // PRIORITY ENCODER (UNIQUE MODE)
    wire n_eq; not NOT_eq(n_eq, earthquake);
    wire c_no_eq; and AND_c_noeq(c_no_eq, cyclone, n_eq);

    wire code1, code0;
    or  OR1 (code1, tsunami, earthquake);
    or  OR0 (code0, tsunami, c_no_eq);

    wire ncode1, ncode0;
    not NC1(ncode1, code1);
    not NC0(ncode0, code0);

    wire Df, Dc, De, Dt;
    and A_df(Df, ncode1, ncode0);
    and A_dc(Dc, ncode1, code0);
    and A_de(De, code1, ncode0);
    and A_dt(Dt, code1, code0);

    // MODE SELECT
    wire nm; not NOTm(nm, mode);

    wire uf, uc, ue, ut;
    and A_uf(uf, nm, Df);
    and A_uc(uc, nm, Dc);
    and A_ue(ue, nm, De);
    and A_ut(ut, nm, Dt);

    wire mf, mc, me, mt;
    and A_mf(mf, mode, flood);
    and A_mc(mc, mode, cyclone);
    and A_me(me, mode, earthquake);
    and A_mt(mt, mode, tsunami);

    or OR_f (flood_led, uf, mf);
    or OR_c (cyclone_led, uc, mc);
    or OR_e (earthquake_led, ue, me);
    or OR_t (tsunami_led, ut, mt);

    // SAFE / DANGER
    or  OR_danger(danger_led, flood, cyclone, earthquake, tsunami);
    not NOT_safe (safe_led, danger_led);

endmodule
