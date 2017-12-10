module main();

reg clk_reg = 1'b0;
initial
  forever
    clk_reg = #5 ~clk_reg;

wire clk = clk_reg;

log log();
bench_main bench_main(.clk(clk));



/////// Start of code /////

wire [3:0] data;
wire vld;

stream_source #(
  .data_width(4),
  .filename("input.txt"),
  .data_type("ascii_hex")
)
stream_source (
  .clk(clk),
  .data(data),
  .vld(vld),
  .rdy(1'b1)
);

integer sum = 0;
reg is_first_data = 1;
reg [3:0] data_prev;
reg [3:0] first_data;

always @(posedge clk)
begin
  if (vld && is_first_data)
  begin
    first_data<=data;
    is_first_data <= 0;
  end
  else if(vld)
  begin
    data_prev<=data;
    if (data_prev == data)
      sum += data;
  end
end

initial
begin
  stream_source.start(0);
  #0;
  @(stream_source.eof)
  @(posedge clk);
  if (data_prev == first_data)
    sum += data_prev;
  $display("captcha is %d", sum);
  $finish;
end

endmodule
