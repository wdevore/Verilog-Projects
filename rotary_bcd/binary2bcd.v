// Reference: http://verilogcodes.blogspot.com/2015/10/verilog-code-for-8-bit-binary-to-bcd.html
// This handles three digits but this gist only uses 2 digits.
module binary2bcd(
   input[7:0] bin,
   output[11:0] bcd
   );

   //Internal variables
   reg[3:0] i;   

   // The "Double Dabble" algorithm
   always @(bin)
   begin
      bcd = 0; // initialize bcd to zero.
      for (i = 0; i < 8; i = i+1) begin // run for 8 iterations
         bcd = {bcd[10:0],bin[7-i]}; // concatenation
            
         // if a hex digit of 'bcd' is more than 4, add 3 to it.  
         if(i < 7 && bcd[3:0] > 4)
            bcd[3:0] = bcd[3:0] + 3;
         if(i < 7 && bcd[7:4] > 4)
            bcd[7:4] = bcd[7:4] + 3;
         if(i < 7 && bcd[11:8] > 4)
            bcd[11:8] = bcd[11:8] + 3;
      end
   end
endmodule
