$fn = 128;

// Brushless DC motor (simplified) with 9.0mm stator diameter and 8.0mm height
stator_d = 9.0;
stator_h = 8.0;

// Outer can (kept slightly larger than stator)
can_wall = 0.6;
can_d = stator_d + 2*can_wall;
can_h = stator_h + 1.2;

base_h = 0.8;
top_cap_h = 0.6;

shaft_d = 1.5;
shaft_len_above = 6.0;
shaft_len_below = 2.0;

mount_hole_d = 1.2;
mount_hole_r = 3.0;
mount_hole_count = 4;

wire_exit_w = 2.2;
wire_exit_h = 1.2;
wire_exit_len = 3.0;

eps = 0.05;
overlap = 0.2;

// --- Z layout (centered for consistent orthographic views) ---
z_can0 = -can_h/2;
z_can1 =  can_h/2;

z_base0 = z_can0 - base_h;
z_base1 = z_can0;

z_top0  = z_can1 - top_cap_h;
z_top1  = z_can1;

z_stator0 = -stator_h/2;
z_stator1 =  stator_h/2;

z_shaft0 = z_base0 - shaft_len_below;
z_shaft1 = z_can1 + shaft_len_above;

module motor_body_solid() {
    // One connected solid: can + top cap + base flange
    union() {
        // Main can (below top cap)
        translate([0,0,z_can0])
            cylinder(d=can_d, h=can_h - top_cap_h);

        // Top cap lip
        translate([0,0,z_top0])
            cylinder(d=can_d*0.98, h=top_cap_h);

        // Base flange
        translate([0,0,z_base0])
            cylinder(d=can_d*0.95, h=base_h);
    }
}

module stator_solid() {
    // Stator core: exact requested dimensions (d=9, h=8)
    translate([0,0,z_stator0])
        cylinder(d=stator_d, h=stator_h);
}

module shaft_solid() {
    // Shaft passes through and overlaps body for watertight union
    translate([0,0,z_shaft0])
        cylinder(d=shaft_d, h=(z_shaft1 - z_shaft0));
}

module mount_holes_cut() {
    // Holes in base flange (cut only; does not disconnect solid)
    for (i=[0:mount_hole_count-1]) {
        a = 360/mount_hole_count * i;
        translate([mount_hole_r*cos(a), mount_hole_r*sin(a), z_base0 - eps])
            cylinder(d=mount_hole_d, h=base_h + 2*eps);
    }
}

module wire_exit_cut() {
    // Small rectangular notch on side near base for wires
    // Positioned to intersect the can wall (formula-based)
    x0 = can_d/2 - 0.2;
    zc = z_can0 + 1.2;
    translate([x0, 0, zc])
        rotate([0,90,0])
            linear_extrude(height=wire_exit_len)
                square([wire_exit_w, wire_exit_h], center=true);
}

module bldc_motor() {
    // Ensure ONE connected solid: union of body+stator+shaft, then subtract holes/notch
    difference() {
        union() {
            motor_body_solid();

            // Slight overlap into can for robust union
            translate([0,0,-overlap])
                stator_solid();

            // Slight overlap into body for robust union
            translate([0,0,-overlap])
                shaft_solid();
        }
        mount_holes_cut();
        wire_exit_cut();
    }
}

bldc_motor();