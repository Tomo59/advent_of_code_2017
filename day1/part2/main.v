module main();

bit clk_reg = 1'b0;
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

bit [3:0] queue[$];
bit [3:0] data_prev;

integer sum = 0;

always @(posedge clk)
begin
  if (vld)
  begin
    queue.push_back(data);
    if (queue.size() == 1003)
      data_prev = queue.pop_front();
    if (data == data_prev)
      sum += data;
  end
end

initial
begin
  stream_source.start(0);
  #0;
  wait(stream_source.eof == 1);
  @(posedge clk);
  @(posedge clk);
  $display("captcha is %d", sum * 2);
  @(posedge clk);
  @(posedge clk);
  $finish;
end

endmodule
