$fn=96;

// Parameters
rod_d = 8.0;
height = 20.0;

// Bracket geometry
wall = 4.0;                 // radial wall thickness around rod
base_th = 6.0;              // base thickness
base_len = 34.0;            // base length (X)
base_w = 22.0;              // base width (Y)
boss_d = rod_d + 2*wall;    // outer diameter of rod boss

// Clamp slit + screw
slit_w = 1.6;               // width of clamp slit
screw_d = 4.2;              // clearance for M4
nut_flat = 7.2;             // across flats for M4 nut
nut_th = 3.4;               // nut thickness
screw_z = base_th + (height - base_th)*0.62; // screw height

module shaft_support_bracket() {
    difference() {
        union() {
            // Base
            translate([-base_len/2, -base_w/2, 0])
                cube([base_len, base_w, base_th], center=false);

            // Boss (rod holder)
            translate([0, 0, base_th])
                cylinder(d=boss_d, h=height-base_th);

            // Side ribs for strength
            rib_th = 4.0;
            rib_len = base_len*0.55;
            rib_h = height*0.65;
            for (sx=[-1,1]) {
                translate([sx*(boss_d/2 - 0.5), -rib_th/2, base_th])
                    hull() {
                        cube([sx>0? rib_len : rib_len, rib_th, 0.1], center=false);
                        translate([sx>0? rib_len*0.55 : rib_len*0.55, 0, rib_h])
                            cube([0.1, rib_th, 0.1], center=false);
                    }
            }
        }

        // Rod hole
        translate([0, 0, -0.5])
            cylinder(d=rod_d+0.3, h=height+1.0);

        // Clamp slit (from front to center)
        translate([-base_len/2-0.5, -slit_w/2, base_th])
            cube([base_len/2 + boss_d/2 + 1.0, slit_w, height-base_th+0.5], center=false);

        // Clamp screw through boss (Y direction)
        translate([0, 0, screw_z])
            rotate([90,0,0])
                cylinder(d=screw_d, h=base_w+2.0, center=true);

        // Nut trap on one side (hex pocket)
        translate([0, base_w/2 - (nut_th/2 + 1.2), screw_z])
            rotate([90,0,0])
                cylinder(d=nut_flat/0.8660254, h=nut_th, $fn=6, center=true);

        // Screw head clearance on opposite side
        head_d = 8.5;
        head_h = 3.5;
        translate([0, -base_w/2 + (head_h/2 + 1.2), screw_z])
            rotate([90,0,0])
                cylinder(d=head_d, h=head_h, center=true);

        // Mounting holes in base (2 holes)
        mount_d = 5.2; // M5 clearance
        mount_x = base_len*0.32;
        mount_y = base_w*0.28;
        for (x=[-mount_x, mount_x]) {
            for (y=[-mount_y, mount_y]) {
                translate([x, y, -0.5])
                    cylinder(d=mount_d, h=base_th+1.0);
            }
        }

        // Light chamfer on base edges (simple bevel via subtracting wedges)
        cham = 1.2;
        // X edges
        for (sx=[-1,1]) {
            translate([sx*(base_len/2), 0, 0])
                rotate([0,0,45])
                    translate([-cham, -base_w, -0.5])
                        cube([2*cham, 2*base_w, base_th+1.0], center=false);
        }
        // Y edges
        for (sy=[-1,1]) {
            translate([0, sy*(base_w/2), 0])
                rotate([0,0,45])
                    translate([-base_len, -cham, -0.5])
                        cube([2*base_len, 2*cham, base_th+1.0], center=false);
        }
    }
}

shaft_support_bracket();