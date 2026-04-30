$fn = 64;

module flange_15pin(width=39.14, height=12.55, thickness=1.12, corner_r=2.0, hole_pitch=33.32, hole_d=3.2) {
    difference() {
        linear_extrude(height=thickness, center=true)
            offset(r=corner_r)
                square([width-2*corner_r, height-2*corner_r], center=true);

        for (sx=[-1,1])
            translate([sx*hole_pitch/2, 0, 0])
                cylinder(h=thickness+0.6, d=hole_d, center=true);
    }
}

module dsub_shell_15pin(shell_w=30.8, shell_h=10.2, shell_depth=10.0, lip=1.0, wall=1.2) {
    translate([0, 0, shell_depth/2])
    difference() {
        union() {
            linear_extrude(height=shell_depth, center=true, scale=[0.93,0.90])
                offset(r=1.6)
                    square([shell_w-3.2, shell_h-3.2], center=true);

            translate([0,0,-shell_depth/2 + 0.4])
                linear_extrude(height=0.8, center=false)
                    offset(r=1.4)
                        square([shell_w-2.8, shell_h-2.8], center=true);
        }

        linear_extrude(height=shell_depth+0.8, center=true, scale=[0.93,0.90])
            offset(r=1.2)
                square([shell_w-2*wall-2.4, shell_h-2*wall-2.4], center=true);
    }
}

module insulator_block_15pin(block_w=24.0, block_h=6.0, block_t=4.5) {
    translate([0,0,block_t/2])
        linear_extrude(height=block_t, center=true)
            offset(r=1.0)
                square([block_w-2.0, block_h-2.0], center=true);
}

module pins_15(rows_y=[-1.6, 1.6], cols_top=8, cols_bottom=7, pitch_x=2.77, pin_d=1.0, pin_len=6.0) {
    // pins extend forward (+Z) from insulator/shell area
    z0 = pin_len/2;
    // top row (8 pins)
    x_start_top = -((cols_top-1)*pitch_x)/2;
    for (i=[0:cols_top-1]) {
        translate([x_start_top + i*pitch_x, rows_y[1], z0])
            cylinder(h=pin_len, d=pin_d, center=true);
    }
    // bottom row (7 pins), centered between top row pins
    x_start_bot = -((cols_bottom-1)*pitch_x)/2;
    for (i=[0:cols_bottom-1]) {
        translate([x_start_bot + i*pitch_x, rows_y[0], z0])
            cylinder(h=pin_len, d=pin_d, center=true);
    }
}

module dsub_15_connector() {
    union() {
        // Flange centered at origin, thickness centered on Z=0
        flange_15pin();

        // Shell sits forward of flange
        translate([0,0,1.12/2])
            dsub_shell_15pin();

        // Insulator inside shell
        translate([0,0,1.12/2 + 2.0])
            insulator_block_15pin();

        // Pins in front
        translate([0,0,1.12/2 + 2.0])
            pins_15();
    }
}

dsub_15_connector();