# Disaster Warning Device

A lightweight digital system that detects Flood, Cyclone, Earthquake, and Tsunami from four 2-bit environmental sensors, then reports either a single prioritized disaster or all simultaneous disasters based on a selectable mode.

<!-- First Section -->
## Team Details
<details>
  <summary>Detail</summary>

  > **Semester:** 3rd Sem B. Tech. CSE  

  > **Section:** S1  

  > **Team ID:** s1-19  

  > **Member-1:** Poluri Sai Jishnu, 241CS140, saijishnup.241cs140@nitk.edu.in  

  > **Member-2:** Utkoor Venkatesh, 241CS161, utkoorvenkatesh.241cs161@nitk.edu.in  

  > **Member-3:** Vikash Patel, 241CS163, vikashpatel.241cs163@nitk.edu.in  

</details>

<!-- Second Section -->
## Abstract
<details>
  <summary>Detail</summary>
  
  **Core Background:**  
  Natural disasters such as floods, cyclones, earthquakes, and tsunamis continue to cause widespread devastation, loss of life, and infrastructure damage. Rapid detection and early warning systems play a crucial role in minimizing these effects. However, most conventional systems rely on complex sensors and microcontroller-based setups, which can be expensive and less accessible for introductory learning environments. This project aims to design a simplified, purely digital logic-based disaster detection and warning device that uses combinational and sequential circuit principles to provide a reliable and low-cost prototype for educational and demonstrative purposes.  

  **Project Working:**  
  The proposed model uses four environmental parameters — Rainfall, Seismic Activity, Wind Speed, and Sea Level — each represented as a 2-bit binary input, summing to an 8-bit total input. Each 2-bit combination represents a specific level: Low (`00`), Medium (`01`), High (`10`), or Very High (`11`). Using comparators and a combination of AND, OR, and XOR gates, the system evaluates logic expressions corresponding to each type of disaster.
  Each condition output activates a disaster indicator. A **priority encoder** assigns binary codes (00–11) based on disaster severity, and a **decoder** converts the code into a one-hot output. The **mode selector** determines whether the system displays only the highest-priority disaster (unique mode) or all concurrent disasters (multi-disaster mode).  

  **Applications & Educational Value:**  
  The system uses LEDs as output indicators, visually representing active disaster conditions. It provides a straightforward, low-cost hardware model ideal for laboratory demonstrations and foundational digital system design learning. The project highlights practical use cases of comparators, encoders, multiplexers, and sequential logic in developing real-world alert systems while fostering a strong understanding of logical design and hardware realization concepts.

</details>


## Functional Block Diagram
<details>
  <summary>Detail</summary>
  
  ![block diagram](Snapshots/block_diagram.png)

</details>

<!-- Third Section -->
# Working
<details>
  <summary>Detail</summary>
The Disaster Warning Device operates by analysing environmental conditions using simple 2-bit digital inputs. These inputs represent intensity levels of four environmental parameters — rainfall, wind speed, seismic activity, and sea level. Each 2-bit pair indicates the level:

`00` = Low, `01` = Medium, `10` = High, `11` = Very High.

---

## **Working Steps**

### 1. Input Stage

The system accepts **8 input bits** grouped as 2-bit pairs for each parameter:

- **Rainfall →** `r1 r0`  
- **Wind →** `w1 w0`  
- **Seismic Activity →** `s1 s0`  
- **Sea Level →** `l1 l0`  

These pairs act like simple digital sensor readings describing environmental intensity.

---

### 2. Condition Evaluation

Each disaster is identified by a specific logical expression built from basic gates (AND, OR):

- **Flood:** `r1 & (w1 | l1 | r0)` — high rainfall along with strong wind, high sea level, or continuous rain.  
- **Cyclone:** `w1 & (w0 | l1 | r1)` — strong wind combined with either high sea level or heavy rainfall.  
- **Earthquake:** `s1 | s0` — any non-zero seismic reading signals earthquake activity.  
- **Tsunami:** `(s1 & s0) | l1` — very high seismic activity or high sea level triggers a tsunami warning.

---

### 3. Detection Stage

Each condition block outputs a binary signal: `1` if that disaster condition is met, otherwise `0`.

These four signals are the raw detection outputs for **Flood**, **Cyclone**, **Earthquake**, and **Tsunami**.

---

### 4. Priority Encoding (Updated Order)

The detection signals feed a **priority encoder** that assigns a 2-bit code according to disaster importance.  
**Tsunami has the highest priority** and **Flood the lowest**. The mapping is:

| Disaster   | Code | Priority |
|-------------|------|-----------|
| Tsunami     | `11` | Highest |
| Earthquake  | `10` | 2nd |
| Cyclone     | `01` | 3rd |
| Flood       | `00` | Lowest |

When multiple disasters are active, the encoder outputs the code of the **highest-priority disaster** (Tsunami first, Flood last).

---

### 5. Decoding and Display

The 2-bit encoder output goes to a **decoder** that produces a one-hot signal.  
The one-hot output drives the corresponding **LED**, so a single LED lights up (in *unique mode*) indicating the prioritized disaster.

---

### 6. Mode Selection

The device includes a **mode input** that controls how outputs are displayed:

- **Mode = 0 (Unique Disaster Mode):** Only the highest-priority disaster LED (from the encoder/decoder) lights.  
- **Mode = 1 (Multi-Disaster Mode):** All LEDs corresponding to active disaster conditions light simultaneously (no priority suppression).

---

### 7. Final Output

The LED panel provides a clear visual warning:

- In **unique mode**, one LED lights up for the prioritized disaster.  
- In **multi mode**, all detected disasters are shown at once.

This design makes it easy to identify and test disaster conditions quickly and clearly.

---

## **Note**

- Priority order ensures the most critical — **Tsunami** — is shown first when multiple conditions occur.  
- Logic equations are intentionally simple, using only basic gates and comparators for hardware-friendly implementation.  
- The **Earthquake** condition (`s1 | s0`) detects any non-zero seismic activity.  
- The **mode** feature offers flexibility: single-alert view or full multi-condition awareness.


</details>

<!-- Fourth Section -->
## Logisim Circuit Diagram
<details>
  <summary>Detail</summary>
  
  ![Circuit](Logisim/disaster_warning_device.png)
</details>

<!-- Fifth Section -->
## Verilog Code
<details>
  <summary>Detail</summary>

###  Behavoiral
```verilog
module disaster_behavioral(
    input  r1, r0, s1, s0, w1, w0, l1, l0, mode,
    output reg flood_led, cyclone_led, earthquake_led, tsunami_led
);
    reg flood, cyclone, earthquake, tsunami;
    reg [1:0] code;
    reg Df, Dc, De, Dt;
    always @(*) begin
        flood      = r1 & (w1 | l1 | r0);
        cyclone    = w1 & (w0 | l1 | r1);
        earthquake = s1 | s0;
        tsunami    = (s1 & s0) | l1;

        if      (tsunami)    code = 2'b11;
        else if (earthquake) code = 2'b10;
        else if (cyclone)    code = 2'b01;
        else if (flood)      code = 2'b00;
        else                 code = 2'b00;

        case (code)
            2'b00: {Df, Dc, De, Dt} = 4'b1000;
            2'b01: {Df, Dc, De, Dt} = 4'b0100;
            2'b10: {Df, Dc, De, Dt} = 4'b0010;
            2'b11: {Df, Dc, De, Dt} = 4'b0001;
            default: {Df, Dc, De, Dt} = 4'b0000;
        endcase

        flood_led      = (~mode & Df) | (mode & flood);
        cyclone_led    = (~mode & Dc) | (mode & cyclone);
        earthquake_led = (~mode & De) | (mode & earthquake);
        tsunami_led    = (~mode & Dt) | (mode & tsunami);
    end
endmodule

```

###  Testbench
```verilog
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
    
        $finish;
    end
endmodule

````
</details>

## References
<details>
  <summary>Detail</summary>

> Mitheu, F. K. *A Model for Impact-Based Flood Early Warning and Anticipatory Actions in Uganda*. University of Reading, 2023. Accessed: 2025-10-30.  
> [(https://centaur.reading.ac.uk/112918/1/MITHEU_Thesis.pdf)](https://centaur.reading.ac.uk/112918/1/MITHEU_Thesis.pdf)  

> U.S. Fire Administration (FEMA). *Fire Service and Disaster Response Integration: Emergency Preparedness Framework*, 2024. Accessed: 2025-10-22.  
> [(https://apps.usfa.fema.gov/pdf/efop/efo34486.pdf)](https://apps.usfa.fema.gov/pdf/efop/efo34486.pdf)  

> United States Patent. *US4153881A – Early warning and control system for flood, earthquake, and other natural disasters*, 2024. Accessed: 2025-10-29.  
> [(https://patents.google.com/patent/US4153881A/en)](https://patents.google.com/patent/US4153881A/en)  

> Electronics Tutorials. *Magnitude Comparator in Digital Logic*. Accessed: 2025-11-01.  
> [(https://www.electronics-tutorials.ws/combination/comb_8.html)](https://www.electronics-tutorials.ws/combination/comb_8.html)  

> GeeksforGeeks. *Encoders and Decoders in Digital Logic*. Accessed: 2025-10-13.  
> [(https://www.geeksforgeeks.org/digital-logic/encoders-and-decoders-in-digital-logic/)](https://www.geeksforgeeks.org/digital-logic/encoders-and-decoders-in-digital-logic/)  

</details>


