module disaster_gate(
    input  r1, r0, s1, s0, w1, w0, l1, l0, mode,
    output flood_led, cyclone_led, earthquake_led, tsunami_led
);
    wire flood, cyclone, earthquake, tsunami;

    or  or_e1 (earthquake, s1, s0);
    and and_ts1 (ts_and, s1, s0);
    or  or_ts1  (tsunami, ts_and, l1);
    or  or_f2 (flood_or_branch, w1, l1, r0);
    and and_f1 (flood, r1, flood_or_branch);
    or  or_c1 (cyclone_or_branch, w0, l1, r1);
    and and_c1 (cyclone, w1, cyclone_or_branch);

    wire n_earthquake;
    not not_e (n_earthquake, earthquake);
    wire cyclone_and_not_e;
    and and_c_nE (cyclone_and_not_e, cyclone, n_earthquake);
    wire code1, code0;
    or  or_code1 (code1, tsunami, earthquake);
    or  or_code0 (code0, tsunami, cyclone_and_not_e);

    wire ncode1, ncode0;
    not not_c1 (ncode1, code1);
    not not_c0 (ncode0, code0);

    wire Df, Dc, De, Dt;
    and and_Df (Df, ncode1, ncode0);
    and and_Dc (Dc, ncode1, code0);
    and and_De (De, code1, ncode0);
    and and_Dt (Dt, code1, code0);

    wire nm;
    not notm (nm, mode);

    wire uf, uc, ue, ut;
    and (uf, nm, Df);
    and (uc, nm, Dc);
    and (ue, nm, De);
    and (ut, nm, Dt);

    wire mf, mc, me, mt;
    and (mf, mode, flood);
    and (mc, mode, cyclone);
    and (me, mode, earthquake);
    and (mt, mode, tsunami);

    or  or_out_f (flood_led, uf, mf);
    or  or_out_c (cyclone_led, uc, mc);
    or  or_out_e (earthquake_led, ue, me);
    or  or_out_t (tsunami_led, ut, mt);
endmodule
