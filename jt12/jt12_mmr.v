/*  This file is part of JT12.

    JT12 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    JT12 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with JT12.  If not, see <http://www.gnu.org/licenses/>.

    Author: Jose Tejada Gomez. Twitter: @topapate
    Version: 1.0
    Date: 14-2-2017
    */

`timescale 1ns / 1ps

module jt12_mmr(
    input           rst,
    input           clk,
    input           cen,
    output          clk_en,
    output          clk_en_ssg,
    input   [7:0]   din,
    input           write,
    input   [1:0]   addr,
    output  reg     busy,
    output          ch6op,
    // LFO
    output  reg [2:0]   lfo_freq,
    output  reg         lfo_en,
    // Timers
    output  reg [9:0]   value_A,
    output  reg [7:0]   value_B,
    output  reg         load_A,
    output  reg         load_B,
    output  reg         enable_irq_A,
    output  reg         enable_irq_B,
    output  reg         clr_flag_A,
    output  reg         clr_flag_B,
    output  reg         fast_timers,
    input               flag_A,
    input               overflow_A, 
    // PCM
    output  reg [8:0]   pcm,
    output  reg         pcm_en,
    // Operator
    output          use_prevprev1,
    output          use_internal_x,
    output          use_internal_y,
    output          use_prev2,
    output          use_prev1,
    // PG
    output  [10:0]  fnum_I,
    output  [ 2:0]  block_I,
    output  reg     pg_stop,
    // REG
    output  [ 1:0]  rl,
    output  [ 2:0]  fb_II,
    output  [ 2:0]  alg_I,
    output  [ 2:0]  pms_I,
    output  [ 1:0]  ams_IV,
    output          amsen_IV,
    output  [ 2:0]  dt1_I,
    output  [ 3:0]  mul_II,
    output  [ 6:0]  tl_IV,
    output  reg     eg_stop,

    output  [ 4:0]  ar_I,
    output  [ 4:0]  d1r_I,
    output  [ 4:0]  d2r_I,
    output  [ 3:0]  rr_I,
    output  [ 3:0]  sl_I,
    output  [ 1:0]  ks_II,
    // SSG operation
    output          ssg_en_I,
    output  [2:0]   ssg_eg_I,

    output          keyon_I,

//  output  [ 1:0]  cur_op,
    // Operator
    output          zero,
    output          s1_enters,
    output          s2_enters,
    output          s3_enters,
    output          s4_enters,

    // PSG interace
    output  [3:0]   psg_addr,
    output  [7:0]   psg_data,
    output  reg     psg_wr_n
);

parameter use_ssg=0, num_ch=6, use_pcm=1;

`ifdef SIMULATION
    initial begin
        cen_cnt = 3'd0;
    end
    `include "jt12_mmr_sim.vh"
`endif

reg [1:0] div_setting;


jt12_div #(.use_ssg(use_ssg)) u_div (
    .rst            ( rst           ),
    .clk            ( clk           ),
    .cen            ( cen           ),
    .div_setting    ( div_setting   ),
    .clk_en         ( clk_en        ),
    .clk_en_ssg     ( clk_en_ssg    )
);

reg [7:0]   selected_register;

//reg       sch; // 0 => CH1~CH3 only available. 1=>CH4~CH6
/*
reg     irq_zero_en, irq_brdy_en, irq_eos_en,
        irq_tb_en, irq_ta_en;
        */
reg [6:0] up_opreg; // hot-one encoding. tells which operator register gets updated next
reg [2:0] up_chreg; // hot-one encoding. tells which channel register gets updated next
reg up_keyon;

wire            busy_reg;

parameter   REG_TESTYM  =   8'h21,
            REG_LFO     =   8'h22,
            REG_CLKA1   =   8'h24,
            REG_CLKA2   =   8'h25,
            REG_CLKB    =   8'h26,
            REG_TIMER   =   8'h27,
            REG_KON     =   8'h28,
            REG_IRQMASK =   8'h29,
            REG_PCM     =   8'h2A,
            REG_PCM_EN  =   8'h2B,
            REG_DACTEST =   8'h2C,
            REG_CLK_N6  =   8'h2D,
            REG_CLK_N3  =   8'h2E,
            REG_CLK_N2  =   8'h2F;


reg csm, effect;

reg [ 2:0] block_ch3op2,  block_ch3op3,  block_ch3op1;
reg [10:0] fnum_ch3op2, fnum_ch3op3, fnum_ch3op1;
reg [ 5:0] latch_fnum;


reg [2:0] up_ch;
reg [1:0] up_op;

reg old_write;
reg [7:0] din_copy;

always @(posedge clk)
    old_write <= write;

generate
    if( use_ssg ) begin
        assign psg_addr = selected_register[3:0];
        assign psg_data = din_copy;
    end else begin
        assign psg_addr = 4'd0;
        assign psg_data = 8'd0;
    end
endgenerate

reg part;

// this runs at clk speed, no clock gating here
always @(posedge clk) begin : memory_mapped_registers
    if( rst ) begin
        selected_register   <= 8'h0;
        div_setting         <= num_ch==6 ? 2'b10 : 2'b11; // divide by 6 or 3
        up_ch               <= 3'd0;
        up_op               <= 2'd0;
        up_keyon            <= 1'd0;
        up_opreg            <= 7'd0;
        up_chreg            <= 3'd0;
        // IRQ Mask
        /*{ irq_zero_en, irq_brdy_en, irq_eos_en,
            irq_tb_en, irq_ta_en } = 5'h1f; */
        // timers
        { value_A, value_B } <= 18'd0;
        { clr_flag_B, clr_flag_A,
        enable_irq_B, enable_irq_A, load_B, load_A } <= 6'd0;
        fast_timers <= 1'b0;
        // LFO
        lfo_freq    <= 3'd0;
        lfo_en      <= 1'b0;
        csm         <= 1'b0;
        effect      <= 1'b0;
        // PCM
        pcm         <= 9'h0;
        pcm_en      <= 1'b0;
        // sch          <= 1'b0;
        // Original test features
        eg_stop     <= 1'b0;
        pg_stop     <= 1'b0;
        psg_wr_n    <= 1'b1;
    end else begin
        // WRITE IN REGISTERS
        if( write ) begin
            if( !addr[0] ) begin
                selected_register <= din;  
                part <= addr[1];             
            end else begin
                // Global registers
                din_copy <= din;
                up_keyon <= selected_register == REG_KON;
                up_ch <= {part, selected_register[1:0]};
                up_op <= selected_register[3:2]; // 0=S1,1=S3,2=S2,3=S4
                casez( selected_register)
                    //REG_TEST: lfo_rst <= 1'b1; // regardless of din
                    8'h0?: psg_wr_n <= 1'b0;
                    REG_TESTYM: begin
                        eg_stop <= din[5];
                        pg_stop <= din[3];
                        fast_timers <= din[2];
                        end
                    REG_CLKA1:  value_A[9:2]<= din;
                    REG_CLKA2:  value_A[1:0]<= din[1:0];
                    REG_CLKB:   value_B     <= din;
                    REG_TIMER: begin
                        effect  <= |din[7:6];
                        csm     <= din[7:6] == 2'b10;
                        { clr_flag_B, clr_flag_A,
                          enable_irq_B, enable_irq_A,
                          load_B, load_A } <= din[5:0];
                        end
                    `ifndef NOLFO                   
                    REG_LFO:    { lfo_en, lfo_freq } <= din[3:0];
                    `endif
                    REG_DACTEST:if(use_pcm==1) pcm[0] <= din[3];
                    REG_PCM:    if(use_pcm==1) pcm[8:1]<= din;
                    REG_PCM_EN: if(use_pcm==1) pcm_en  <= din[7];
                    // clock divider
                    REG_CLK_N6: div_setting[1] <= 1'b1; 
                    REG_CLK_N3: div_setting[0] <= 1'b1; 
                    REG_CLK_N2: div_setting <= 2'b0;
                    // CH3 special registers
                    8'hA9: { block_ch3op1, fnum_ch3op1 } <= { latch_fnum, din };
                    8'hA8: { block_ch3op3, fnum_ch3op3 } <= { latch_fnum, din };
                    8'hAA: { block_ch3op2, fnum_ch3op2 } <= { latch_fnum, din };
                    // According to http://www.mjsstuf.x10host.com/pages/vgmPlay/vgmPlay.htm
                    // There is a single fnum latch for all channels
                    8'hA4, 8'hA5, 8'hA6, 8'hAD, 8'hAC, 8'hAE: latch_fnum <= din[5:0];
                    default:;   // avoid incomplete-case warning
                endcase
                if( selected_register[1:0]==2'b11 ) 
                    { up_chreg, up_opreg } <= { 3'h0, 7'h0 };
                else
                    casez( selected_register )
                        // channel registers
                        8'hA0, 8'hA1, 8'hA2:    { up_chreg, up_opreg } <= { 3'h1, 7'd0 }; // up_fnumlo
                        // FB + Algorithm
                        8'hB0, 8'hB1, 8'hB2: { up_chreg, up_opreg } <= { 3'h2, 7'd0 }; // up_alg
                        8'hB4, 8'hB5, 8'hB6: { up_chreg, up_opreg } <= { 3'h4, 7'd0 }; // up_pms
                        // operator registers
                        8'h3?: { up_chreg, up_opreg } <= { 3'h0, 7'h01 }; // up_dt1
                        8'h4?: { up_chreg, up_opreg } <= { 3'h0, 7'h02 }; // up_tl
                        8'h5?: { up_chreg, up_opreg } <= { 3'h0, 7'h04 }; // up_ks_ar
                        8'h6?: { up_chreg, up_opreg } <= { 3'h0, 7'h08 }; // up_amen_dr
                        8'h7?: { up_chreg, up_opreg } <= { 3'h0, 7'h10 }; // up_sr
                        8'h8?: { up_chreg, up_opreg } <= { 3'h0, 7'h20 }; // up_sl
                        8'h9?: { up_chreg, up_opreg } <= { 3'h0, 7'h40 }; // up_ssgeg
                        default: { up_chreg, up_opreg } <= { 3'h0, 7'h0 };
                    endcase // selected_register
            end
        end
        else if(clk_en) begin /* clear once-only bits */
            // lfo_rst <= 1'b0;
            { clr_flag_B, clr_flag_A } <= 2'd0;
            psg_wr_n <= 1'b1;
        end
    end
end

reg [4:0] busy_cnt; // busy lasts for 32 synth clock cycles, like in real chip

always @(posedge clk)
    if( rst ) begin
        busy <= 1'b0;
        busy_cnt <= 5'd0;
    end
    else begin
        if (!old_write && write && addr[0] ) begin // only set for data writes
            busy <= 1'b1;
            busy_cnt <= 5'd0;
        end
        else if(clk_en) begin
            if( busy_cnt == 5'd31 ) busy <= 1'b0;
            busy_cnt <= busy_cnt+5'd1;
        end
    end

jt12_reg #(.num_ch(num_ch)) u_reg(
    .rst        ( rst       ),
    .clk        ( clk       ),      // P1
    .clk_en     ( clk_en    ),
    .din        ( din_copy  ),

    .up_keyon   ( up_keyon  ),
    .up_fnumlo  ( up_chreg[0]   ),
    .up_alg     ( up_chreg[1]   ),
    .up_pms     ( up_chreg[2]   ),
    .up_dt1     ( up_opreg[0]   ),
    .up_tl      ( up_opreg[1]   ),
    .up_ks_ar   ( up_opreg[2]   ),
    .up_amen_dr ( up_opreg[3]   ),
    .up_sr      ( up_opreg[4]   ),
    .up_sl_rr   ( up_opreg[5]   ),
    .up_ssgeg   ( up_opreg[6]   ),

    .op         ( up_op     ),      // operator to update
    .ch         ( up_ch     ),      // channel to update

    .csm        ( csm       ),
    .flag_A     ( flag_A    ),
    .overflow_A ( overflow_A),

    .ch6op      ( ch6op     ),
    // CH3 Effect-mode operation
    .effect     ( effect    ),      // allows independent freq. for CH 3
    .fnum_ch3op2( fnum_ch3op2 ),
    .fnum_ch3op3( fnum_ch3op3 ),
    .fnum_ch3op1( fnum_ch3op1 ),
    .block_ch3op2( block_ch3op2 ),
    .block_ch3op3( block_ch3op3 ),
    .block_ch3op1( block_ch3op1 ),
    .latch_fnum ( latch_fnum    ),
    // Operator
    .use_prevprev1(use_prevprev1),
    .use_internal_x(use_internal_x),
    .use_internal_y(use_internal_y),
    .use_prev2  ( use_prev2 ),
    .use_prev1  ( use_prev1 ),
    // PG
    .fnum_I     (   fnum_I  ),
    .block_I    (   block_I ),
    .mul_II     (   mul_II  ),
    .dt1_I      (   dt1_I   ),

    // EG
    .ar_I       (ar_I       ), // attack  rate
    .d1r_I      (d1r_I      ), // decay   rate
    .d2r_I      (d2r_I      ), // sustain rate
    .rr_I       (rr_I       ), // release rate
    .sl_I       (sl_I       ), // sustain level
    .ks_II      (ks_II      ), // key scale
    // SSG operation
    .ssg_en_I   ( ssg_en_I  ),
    .ssg_eg_I   ( ssg_eg_I  ),
    // envelope number
    .tl_IV      (tl_IV      ),
    .pms_I      (pms_I      ),
    .ams_IV     (ams_IV     ),
    .amsen_IV   (amsen_IV   ),
    // channel configuration
    .rl         ( rl        ),
    .fb_II      ( fb_II     ),
    .alg_I      ( alg_I     ),
    .keyon_I    ( keyon_I   ),

    .zero       ( zero      ),
    .s1_enters  ( s1_enters ),
    .s2_enters  ( s2_enters ),
    .s3_enters  ( s3_enters ),
    .s4_enters  ( s4_enters )
);

endmodule
