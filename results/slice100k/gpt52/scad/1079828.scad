$fn=96;

L = 61.0;
W = 12.8;
H = 5.1;

end_len = 7.0;
end_step = 0.6;

seam_w = 1.2;
seam_step = 0.25;

sag = 1.2;

module v_saddle_bar(len=L, wid=W, height=H, sag_amt=sag) {
    linear_extrude(height=len, center=true, convexity=10, scale=1)
        polygon(points=[
            [-wid/2, 0],
            [-wid/2, height],
            [0, height - sag_amt],
            [wid/2, height],
            [wid/2, 0]
        ]);
}

module end_step_cut(len=L, wid=W, step_h=end_step, step_len=end_len) {
    union() {
        translate([0, 0,  len/2 - step_len/2])
            cube([wid+0.6, step_h, step_len], center=true);
        translate([0, 0, -len/2 + step_len/2])
            cube([wid+0.6, step_h, step_len], center=true);
    }
}

module seam_cut(len=L, wid=W, step_h=seam_step, seam_width=seam_w) {
    translate([0, 0, 0])
        cube([wid+0.6, step_h, seam_width], center=true);
}

difference() {
    rotate([90,0,0])
        v_saddle_bar();
    end_step_cut();
    seam_cut();
}