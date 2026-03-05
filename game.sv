`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2026 05:44:24 PM
// Design Name: 
// Module Name: Pong1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


 module Pong1(
    input logic CLK100MHZ,
    input logic btnU,
    input logic btnD,
    input logic btnC,
    
    output logic Hsync,
    output logic Vsync,
    output logic [3:0] vgaRed,
    output logic [3:0] vgaGreen,
    output logic [3:0] vgaBlue,
    output logic [6:0] seg,
    output logic [3:0] an
    );
    
    logic [1:0] game_state;
    
    logic [7:0] zero = 7'b1000000;
    logic [7:0] one = 7'b1111001;
    logic [7:0] two = 7'b0100100;
    logic [7:0] three = 7'b0110000;
    logic [7:0] four = 7'b0011001;
    logic [7:0] five = 7'b0010010;
    logic [7:0] six = 7'b0000010;
    logic [7:0] seven = 7'b1111000;
    logic [7:0] eight = 7'b0000000;
    logic [7:0] nine = 7'b0010000;
    
    logic pixel_clk;
    logic video_on;
    
    logic [1:0] count = 0;
    logic [19:0] refresh_count = 0;
    
    always_ff@(posedge  CLK100MHZ) begin
        count <= count + 1; 
        refresh_count <= refresh_count + 1;
    end
    
    logic [1:0] lcd_point;
    assign lcd_point = refresh_count[19:18];
    
    assign pixel_clk = count[1];
    
    logic [9:0] paddle_x = 620;
    logic [9:0] paddle_y = 240;
    
    logic [9:0] paddle2_x = 20;
    logic signed [9:0] paddle2_y = 240;
    
    logic btnU_stg1;
    logic btnU_stg2;
    
    logic btnD_stgl;
    logic btnD_stg2;
    
    logic btnC_stg1;
    logic btnC_stg2;
    
    always_ff@(posedge pixel_clk) begin
        btnU_stg1 <= btnU;
        btnU_stg2 <= btnU_stg1;
        
        btnD_stgl <= btnD;
        btnD_stg2 <= btnD_stgl;
        
        btnC_stg1 <= btnC;
        btnC_stg2 <= btnC_stg1;
    end
    
    logic signed [10:0] h_count = 0;
    logic signed [10:0] v_count = 0;
    
    always_ff@(posedge pixel_clk) begin
        if (h_count == 799) begin
            h_count <= 0;
        end else begin
            h_count <= h_count + 1;
        end
    end
    
    logic signed [10:0] ball_x = 320;
    logic signed [10:0] ball_y = 240;
    
    logic signed [5:0] x_veloc = 5;
    logic signed [5:0] y_veloc = 5;
    
    logic paddle1_collision;
    logic paddle2_collision;
    
    assign paddle1_collision = (ball_x + 8 >= paddle_x - 6  && ball_y + 8 >= paddle_y - 60 && ball_y - 8 <= paddle_y + 60) ? 1 : 0;
    assign paddle2_collision = (ball_x - 8 <= paddle2_x + 6  && ball_y + 8 >= paddle2_y - 60 && ball_y - 8 <= paddle2_y + 60) ? 1 : 0;
    
    logic signed [2:0] paddle2_dir;
    
    logic [6:0] scoreplayer;
    logic [6:0] scorecpu;
    
    assign paddle2_dir = (ball_y >= paddle2_y && paddle2_y <= 415) ? 1 : (ball_y <= paddle2_y && paddle2_y >= 65) ? -1 : 0;
        
    always_ff@(posedge  pixel_clk) begin
        if (h_count == 799) begin
            if (v_count == 524) begin
                v_count <= 0;
                if (game_state == 1) begin
                    paddle2_y <= paddle2_y + (paddle2_dir * 4);
                    if (paddle1_collision | paddle2_collision) begin
                        x_veloc <= x_veloc * -1;
                        ball_x <= ball_x - x_veloc;
                    end else begin
                        ball_x <= ball_x + x_veloc;
                    end
                    if (ball_y >= 475 | ball_y <= 5) begin
                        y_veloc <= y_veloc * -1;
                        ball_y <= ball_y - y_veloc;;
                    end else begin              
                        ball_y <= ball_y + y_veloc;
                    end
                    if (ball_x + 8 >= 635) begin
                        ball_x <= 320;
                        x_veloc <= x_veloc * -1;
                        scorecpu <= scorecpu + 1;
                        game_state <= 0;
                    end
                    if (ball_x - 8 <= 5) begin
                        ball_x <= 320;
                        x_veloc <= x_veloc * -1;
                        scoreplayer <= scoreplayer + 1;
                        game_state <= 0;
                    end
                    if (btnU_stg2  && paddle_y >= 65) begin
                        paddle_y <= paddle_y - 5;
                    end
                    if(btnD_stg2 && paddle_y <= 415) begin
                        paddle_y <= paddle_y + 5;
                    end
                end
                if (game_state == 0) begin
                    ball_x <= 320;
                    ball_y <= 240;
                    if (btnC == 1) begin
                        game_state <= 1;
                    end
                end
            end else begin
                v_count <= v_count + 1;
            end
        end  
    end
    
    logic [7:0] score_to_display;
    
    always_comb begin
        case (lcd_point)
            2'b00: begin
                an = 4'b0111;
                score_to_display = scorecpu;
            end
            2'b11: begin
                an = 4'b1110;
                score_to_display = scoreplayer;
            end
            default: begin
                an = 4'b1111;
                score_to_display = 0;
            end
        endcase
    end 
    
    always_comb begin
        case (score_to_display)
            4'd0: seg = zero;
            4'd1: seg = one;
            4'd2: seg = two;
            4'd3: seg = three;
            4'd4: seg = four;
            4'd5: seg = five;
            4'd6: seg = six;
            4'd7: seg = seven;
            4'd8: seg = eight;
            4'd9: seg = nine;
            default: seg = 7'b1111111;
        endcase
    end
    
    logic drawball; 
    logic drawpaddle;
    logic drawpaddle2;
    
    logic drawnet;
       
    assign Hsync = (h_count >= 656 && h_count <= 751) ? 0 : 1;
    assign Vsync = (v_count >= 490 && v_count <= 491) ? 0 : 1;
    
 //   assign video_on = (v_count <= 479 && h_count <= 639) ? 1 : 0;
    
    assign drawnet = ((h_count >= 317 && h_count <= 323) && (v_count % 20 < 10));
    assign drawball = (h_count > ball_x - 8 && h_count < ball_x + 8 && v_count > ball_y - 8 && v_count < ball_y + 8) ? 1 : 0;
    assign drawpaddle = (h_count > paddle_x - 6 && h_count < paddle_x + 6 && v_count > paddle_y - 60 && v_count < paddle_y + 60) ? 1 : 0;
    assign drawpaddle2 = (h_count > paddle2_x - 6 && h_count < paddle2_x + 6 && v_count > paddle2_y - 60 && v_count < paddle2_y + 60) ? 1 : 0;
    
    assign vgaGreen = (drawball | drawpaddle | drawpaddle2 | drawnet) ? 4'b1111 : 4'b0000; 

endmodule
