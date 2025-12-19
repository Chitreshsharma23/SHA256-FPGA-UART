module sha(
    input clk,
    input reset,
    input start,
    input [511:0] data_block,  // One 512-bit message block
    output reg [255:0] hash,   // 256-bit output hash
    output reg complete
);
    

    // SHA-256 constants
    reg [31:0] k [0:63];
    initial begin
        k[ 0]=32'h428a2f98; k[ 1]=32'h71374491; k[ 2]=32'hb5c0fbcf; k[ 3]=32'he9b5dba5;
        k[ 4]=32'h3956c25b; k[ 5]=32'h59f111f1; k[ 6]=32'h923f82a4; k[ 7]=32'hab1c5ed5;
        k[ 8]=32'hd807aa98; k[ 9]=32'h12835b01; k[10]=32'h243185be; k[11]=32'h550c7dc3;
        k[12]=32'h72be5d74; k[13]=32'h80deb1fe; k[14]=32'h9bdc06a7; k[15]=32'hc19bf174;
        k[16]=32'he49b69c1; k[17]=32'hefbe4786; k[18]=32'h0fc19dc6; k[19]=32'h240ca1cc;
        k[20]=32'h2de92c6f; k[21]=32'h4a7484aa; k[22]=32'h5cb0a9dc; k[23]=32'h76f988da;
        k[24]=32'h983e5152; k[25]=32'ha831c66d; k[26]=32'hb00327c8; k[27]=32'hbf597fc7;
        k[28]=32'hc6e00bf3; k[29]=32'hd5a79147; k[30]=32'h06ca6351; k[31]=32'h14292967;
        k[32]=32'h27b70a85; k[33]=32'h2e1b2138; k[34]=32'h4d2c6dfc; k[35]=32'h53380d13;
        k[36]=32'h650a7354; k[37]=32'h766a0abb; k[38]=32'h81c2c92e; k[39]=32'h92722c85;
        k[40]=32'ha2bfe8a1; k[41]=32'ha81a664b; k[42]=32'hc24b8b70; k[43]=32'hc76c51a3;
        k[44]=32'hd192e819; k[45]=32'hd6990624; k[46]=32'hf40e3585; k[47]=32'h106aa070;
        k[48]=32'h19a4c116; k[49]=32'h1e376c08; k[50]=32'h2748774c; k[51]=32'h34b0bcb5;
        k[52]=32'h391c0cb3; k[53]=32'h4ed8aa4a; k[54]=32'h5b9cca4f; k[55]=32'h682e6ff3;
        k[56]=32'h748f82ee; k[57]=32'h78a5636f; k[58]=32'h84c87814; k[59]=32'h8cc70208;
        k[60]=32'h90befffa; k[61]=32'ha4506ceb; k[62]=32'hbef9a3f7; k[63]=32'hc67178f2;
    end

    // Initial hash values (h0..h7)
    reg [31:0] h [0:7];
    initial begin
        h[0] = 32'h6a09e667;
        h[1] = 32'hbb67ae85;
        h[2] = 32'h3c6ef372;
        h[3] = 32'ha54ff53a;
        h[4] = 32'h510e527f;
        h[5] = 32'h9b05688c;
        h[6] = 32'h1f83d9ab;
        h[7] = 32'h5be0cd19;
    end

    // Working variables
    reg [31:0] w [0:63];
    integer t;

    // Functions for SHA-256
    function [31:0] rotr;
        input [31:0] x;
        input [4:0] n;
        begin
            rotr = (x >> n) | (x << (32-n));
        end
    endfunction

    function [31:0] shr;
        input [31:0] x;
        input [4:0] n;
        begin
            shr = x >> n;
        end
    endfunction

    function [31:0] Ch;
        input [31:0] x,y,z;
        begin
            Ch = (x & y) ^ (~x & z);
        end
    endfunction

    function [31:0] Maj;
        input [31:0] x,y,z;
        begin
            Maj = (x & y) ^ (x & z) ^ (y & z);
        end
    endfunction

    function [31:0] Sigma0;
        input [31:0] x;
        begin
            Sigma0 = rotr(x,2) ^ rotr(x,13) ^ rotr(x,22);
        end
    endfunction

    function [31:0] Sigma1;
        input [31:0] x;
        begin
            Sigma1 = rotr(x,6) ^ rotr(x,11) ^ rotr(x,25);
        end
    endfunction

    function [31:0] sigma0;
        input [31:0] x;
        begin
            sigma0 = rotr(x,7) ^ rotr(x,18) ^ shr(x,3);
        end
    endfunction

    function [31:0] sigma1;
        input [31:0] x;
        begin
            sigma1 = rotr(x,17) ^ rotr(x,19) ^ shr(x,10);
        end
    endfunction

    // State machine
    reg [1:0] state;
    reg [31:0] a,b,c,d,e,f,g,h_;
    reg [31:0] T1, T2;

    localparam IDLE = 2'd0;
    localparam LOAD = 2'd1;
    localparam COMPRESS = 2'd2;
    localparam DONE = 2'd3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            complete <= 0;
            hash <= 0;
            state <= IDLE;
            t <= 0;
        end else begin
            case(state)
                IDLE: begin
                    complete <= 0;
                    if (start) begin
                        // Load the 512-bit input block into w[0..15]
                        for (t=0; t<16; t=t+1)
                            w[t] <= data_block[511-32*t -: 32];
                        // Initialize working variables
                        a <= h[0]; b <= h[1]; c <= h[2]; d <= h[3];
                        e <= h[4]; f <= h[5]; g <= h[6]; h_ <= h[7];
                        t <= 16;
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    // Extend the first 16 words into the remaining 48 words w[16..63]
                    if (t < 64) begin
                        w[t] <= sigma1(w[t-2]) + w[t-7] + sigma0(w[t-15]) + w[t-16];
                        t <= t + 1;
                    end else begin
                        t <= 0;
                        state <= COMPRESS;
                    end
                end
                COMPRESS: begin
                    if (t < 64) begin
                        T1 = h_ + Sigma1(e) + Ch(e,f,g) + k[t] + w[t];
                        T2 = Sigma0(a) + Maj(a,b,c);
                        h_ <= g;
                        g <= f;
                        f <= e;
                        e <= d + T1;
                        d <= c;
                        c <= b;
                        b <= a;
                        a <= T1 + T2;
                        t <= t + 1;
                    end else begin
                        // Add the compressed chunk to the current hash value
                        h[0] <= h[0] + a;
                        h[1] <= h[1] + b;
                        h[2] <= h[2] + c;
                        h[3] <= h[3] + d;
                        h[4] <= h[4] + e;
                        h[5] <= h[5] + f;
                        h[6] <= h[6] + g;
                        h[7] <= h[7] + h_;
                        state <= DONE;
                    end
                end
                DONE: begin
                    complete <= 1'b1;
                    // Concatenate final hash output
                    hash <= {h[0],h[1],h[2],h[3],h[4],h[5],h[6],h[7]};
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule