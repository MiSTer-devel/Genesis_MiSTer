// M95320 SPI EEPROM support for Pier Solar, by Kitrinx
// This module expects single-cycle bram. For longer delays the WIP reg
// can be used to emulate the original eeprom's slow write times.

module STM95XXX
(
	input clk,                   // Bus clock
	input enable,                // Enable Module
	// Chip pins
	output        so,            // Serial Out
	input         si,            // Serial In
	input         sck,           // Serial Clock
	input         hold_n,        // Hold (active low)
	input         cs_n,          // Chip Select (active low)
	input         wp_n,          // Write Protect (active low)
	// BRAM Interface
	output [11:0] ram_addr,      // RAM Address
	input  [7:0]  ram_q,         // Data read from RAM
	output [7:0]  ram_di,        // Data written to RAM
	output        ram_RnW        // RAM read/write (write is high)
);

assign ram_di = data_out;
assign ram_addr = address[11:0];
assign ram_RnW = ram_write;
assign so = bit_out;

localparam ADDRESS_LEN = 32'hF;
localparam ROM_SIZE = 'hFFF; // M95320 32k

// SPI Commands
localparam WRSR  = 8'b0000_0001;
localparam WRITE = 8'b0000_0010;
localparam READ  = 8'b0000_0011;
localparam WRDI  = 8'b0000_0100;
localparam RDSR  = 8'b0000_0101;
localparam WREN  = 8'b0000_0110;

enum bit [2:0] {
	M95_IDLE,
	M95_WRSR,
	M95_WRITE,
	M95_READ,
	M95_RDSR,
	M95_WAIT
} state;

int bit_count;

logic [15:0] address;
logic [7:0] data_in, data_out;
logic [2:0] byte_ptr;
logic old_sck;
logic bit_out;
logic ram_write;

// Hardware registers
logic [7:0] status; // {SRWD, 0, 0, 0, BP1, BP0, WEL, WIP};
logic WEL; // write enable latch
logic WIP; // write in progress
logic SRWD, BP1, BP0; // Non-volatile block protect bits

always_ff @(posedge clk) begin
	if (~enable || (~hold_n && cs_n)) begin
		state <= M95_IDLE;
		data_in <= 8'b0;
		WIP <= 1'b0;
		WEL <= 1'b0;
		SRWD <= 1'b0;
		BP1 <= 1'b0;
		BP0 <= 1'b0;
	end else begin

	old_sck <= sck;
	if (~old_sck & sck & hold_n & ~cs_n) begin
		case (state)
			M95_IDLE: begin
				bit_count <= bit_count + 1'b1;
				data_in <= {data_in[6:0], si};
				ram_write <= 1'b0;
				if (bit_count == 3'h7) begin
					bit_count <= 0;
					data_in <= 8'h0;
					byte_ptr <= 3'h7;
					case ({data_in[6:0], si}) // Command evaluation
						WRSR: begin // Write status register
							if (WEL) begin
								state <= M95_WRSR;
							end
							WEL <= 1'b0;
						end

						WRITE: begin // Write data
							if (WEL) begin
								state <= M95_WRITE;
							end
							WEL <= 1'b0;
						end

						READ: begin // Read data
							state <= M95_READ;
						end

						WRDI: begin // Write disable
							WEL <= 1'b0;
						end

						RDSR: begin // Read status register
							state <= M95_RDSR;
							status <= {SRWD, 3'b000, BP1, BP0, WEL, WIP};
						end

						WREN: begin // Write enable
							WEL <= 1'b1;
						end

						default: begin // WTF
							state <= M95_WAIT;
						end
					endcase
				end
			end

			M95_WRSR: begin // write status register
				status[byte_ptr] <= si;
				byte_ptr <= byte_ptr - 1'b1;
				WEL <= status[1];
				// We don't care about this right now, but if
				// this module is ever needed for use with write
				// protected banks, this needs implementation.
			end

			M95_RDSR: begin
				byte_ptr <= byte_ptr - 1'b1;
				bit_out <= status[byte_ptr];
			end

			M95_READ: begin
				if (bit_count <= ADDRESS_LEN) begin
					address <= {address[14:0], si};
					bit_count <= bit_count + 1'b1;
				end else begin
					byte_ptr <= byte_ptr - 1'b1;
					bit_out <= ram_q[byte_ptr];
					if (byte_ptr == 0)
						address <= (address == ROM_SIZE) ? 16'h0 : address + 1'b1;
				end
			end

			M95_WRITE: begin
				if (bit_count <= ADDRESS_LEN) begin
					address <= {address[14:0], si};
					bit_count <= bit_count + 1'b1;
				end else begin
					byte_ptr <= byte_ptr - 1'b1;
					data_out[byte_ptr] <= si;
					ram_write <= (byte_ptr == 0);
					if (ram_write)
						address <= (address == ROM_SIZE) ? 16'h0 : address + 1'b1;
				end
			end

			default:; // wait/error state
		endcase

	end
	if (cs_n) begin
		state <= M95_IDLE;
		bit_count <= 0;
		bit_out <= 1'b1;
	end
	end // if enabled
end
endmodule
