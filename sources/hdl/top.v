`timescale 1ns / 1ps

`default_nettype none

module top
    (   input wire i_top_clk,
        input wire i_top_rst,
        
        input wire  i_top_cam_start, 
        output wire o_top_cam_done, 
        
        // I/O to camera
        input wire       i_top_pclk, 
        input wire [7:0] i_top_pix_byte,
        input wire       i_top_pix_vsync,
        input wire       i_top_pix_href,
        output wire      o_top_reset,
        output wire      o_top_pwdn,
        output wire      o_top_xclk,
        output wire      o_top_siod,
        output wire      o_top_sioc,
    
        // I/O to HDMI
        output wire hdmi_tmds_clk_n,
        output wire hdmi_tmds_clk_p,
        output wire [2:0]hdmi_tmds_data_n,
        output wire [2:0]hdmi_tmds_data_p

    );
    
    // VGA Signals
    wire [2:0] o_top_vga_red, o_top_vga_green, o_top_vga_blue;
    wire       o_top_vga_vsync, o_top_vga_hsync, vde;  
    
    // HDMI Signal
    wire locked;   
    
    // Connect cam_top/vga_top modules to on-chip memory
    wire [11:0] i_bram_pix_data,    o_bram_pix_data;          // 12-bit representation
    wire [8:0] i_bram_pix_data_nine,    o_bram_pix_data_nine; //  9-bit representation
    wire [18:0] i_bram_pix_addr,    o_bram_pix_addr; 
    wire        i_bram_pix_wr;
           
    // Reset synchronizers for all clock domains
    reg r1_rstn_top_clk,    r2_rstn_top_clk;
    reg r1_rstn_pclk,       r2_rstn_pclk;
    reg r1_rstn_clk25m,     r2_rstn_clk25m; 
        
    wire w_clk25m; 
    
    // For 12-bit representation, use: i_bram_pix_data 
    // For 9-bit  representation, use: i_bram_pix_data_nine
    assign i_bram_pix_data_nine = {i_bram_pix_data[11:9], i_bram_pix_data[7:5], i_bram_pix_data[3:1]}; 
    
    // Debounce top level button - invert reset to have debounced negedge reset
    wire w_rst_btn_db; 
    localparam DELAY_TOP_TB = 240_000; //240_000 when uploading to hardware, 10 when simulating in testbench 
    debouncer 
    #(  .DELAY(DELAY_TOP_TB)    )
    top_btn_db
    (
        .i_clk(i_top_clk        ),
        .i_btn_in(~i_top_rst    ),
        .o_btn_db(w_rst_btn_db  )
    ); 
    
    // Double FF for negedge reset synchronization 
    always @(posedge i_top_clk or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_top_clk, r1_rstn_top_clk} <= 0; 
            else              {r2_rstn_top_clk, r1_rstn_top_clk} <= {r1_rstn_top_clk, 1'b1}; 
        end 
    always @(posedge w_clk25m or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_clk25m, r1_rstn_clk25m} <= 0; 
            else              {r2_rstn_clk25m, r1_rstn_clk25m} <= {r1_rstn_clk25m, 1'b1}; 
        end
    always @(posedge i_top_pclk or negedge w_rst_btn_db)
        begin
            if(!w_rst_btn_db) {r2_rstn_pclk, r1_rstn_pclk} <= 0; 
            else              {r2_rstn_pclk, r1_rstn_pclk} <= {r1_rstn_pclk, 1'b1}; 
        end 
        
    //Clock Wizard configured with a 1x and 5x clock for HDMI
    clk_wiz_0 clk_wiz (
        .clk_out1(w_clk25m              ),  //  25MHz Clock
        .clk_out2(o_top_xclk            ),  // 125MHz Clock
        .locked(locked                  ),
        .clk_in1(i_top_clk              )
    );
    
    // FPGA-camera interface
    cam_top 
    #(  .CAM_CONFIG_CLK(100_000_000)    )
    OV7670_cam
    (
        .i_clk(w_clk25m                 ),
        .i_rstn_clk(r2_rstn_top_clk     ),
        .i_rstn_pclk(r2_rstn_pclk       ),
        
        // I/O for camera init
        .i_cam_start(i_top_cam_start    ),
        .o_cam_done(o_top_cam_done      ), 
        
        // I/O camera
        .i_pclk(i_top_pclk              ),
        .i_pix_byte(i_top_pix_byte      ), 
        .i_vsync(i_top_pix_vsync        ), 
        .i_href(i_top_pix_href          ),
        .o_reset(o_top_reset            ),
        .o_pwdn(o_top_pwdn              ),
        .o_siod(o_top_siod              ),
        .o_sioc(o_top_sioc              ), 
        
        // Outputs from camera to BRAM
        .o_pix_wr(                      ),
        .o_pix_data(i_bram_pix_data     ),
        .o_pix_addr(i_bram_pix_addr     )
    );
    
    // Block Memory
    blk_mem_gen_0 pixel_memory (
    // BRAM Write signals (cam_top)
	.addra		(i_bram_pix_addr         ), 
	.clka		(i_top_pclk              ), 
	.dina   	(i_bram_pix_data_nine    ), 
	.ena		(1'b1                    ), 
	.wea		(1'b1                    ),
	
	// BRAM Read signals (vga_top)
	.addrb		(o_bram_pix_addr         ), 
	.clkb		(w_clk25m                ), 
	.doutb   	(o_bram_pix_data_nine    ), 
	.enb		(1'b1                    )
);
     
    // VGA Interface
    wire X; 
    wire Y;
    vga_top
    display_interface
    (
        .i_clk25m(w_clk25m              ),
        .i_rstn_clk25m(r2_rstn_clk25m   ), 
        
        // VGA timing signals
        .o_VGA_x(X                      ),
        .o_VGA_y(Y                      ), 
        .o_VGA_vsync(o_top_vga_vsync    ),
        .o_VGA_hsync(o_top_vga_hsync    ), 
        .o_VGA_video(                   ),
        
        // VGA RGB Pixel Data
        .o_VGA_red(o_top_vga_red        ),
        .o_VGA_green(o_top_vga_green    ),
        .o_VGA_blue(o_top_vga_blue      ), 
        .active_nblank(vde              ),                    
        
        // VGA read/write from/to BRAM
        .i_pix_data(o_bram_pix_data_nine), 
        .o_pix_addr(o_bram_pix_addr     )
    );
    
    //Real Digital VGA to HDMI converter
    hdmi_tx_0 vga_to_hdmi (
        //Clocking and Reset
        .pix_clk(w_clk25m               ),  
        .pix_clkx5(o_top_xclk           ),
        .pix_clk_locked(locked          ),
        //Reset is active HIGH
        .rst(~r2_rstn_clk25m            ), 
        //Color and Sync Signals
        .red(o_top_vga_red              ), 
        .green(o_top_vga_green          ), 
        .blue(o_top_vga_blue            ), 
        .hsync(o_top_vga_hsync          ),
        .vsync(o_top_vga_vsync          ),
        .vde(vde                        ),
        
        //aux Data (unused)
        .aux0_din(4'b0                  ),
        .aux1_din(4'b0                  ),
        .aux2_din(4'b0                  ),
        .ade(1'b0                       ),
        
        //Differential outputs
        .TMDS_CLK_P(hdmi_tmds_clk_p     ),          
        .TMDS_CLK_N(hdmi_tmds_clk_n     ),          
        .TMDS_DATA_P(hdmi_tmds_data_p   ),         
        .TMDS_DATA_N(hdmi_tmds_data_n   )          
    );
    
endmodule
