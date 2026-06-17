$fn = 96;

// Pillow block bearing (UCP-style) for 8.0mm shaft, base 55x42mm
// Parametric, renderable, printable-ish representation (not a certified bearing model).

// ---------- Parameters ----------
shaft_d = 8.0;

base_L = 55.0;
base_W = 42.0;
base_H = 10.0;

mount_hole_d = 6.5;          // typical for M6 clearance
mount_hole_offset_L = 18.0;  // from center along length (gives 36mm spacing)
mount_hole_offset_W = 14.0;  // from center along width (gives 28mm spacing)

pedestal_L = 40.0;
pedestal_W = 30.0;
pedestal_H = 18.0;

housing_outer_d = 34.0;
housing_len = 30.0;          // along X
housing_center_z = base_H + pedestal_H;

bore_d = shaft_d + 0.4;      // slight clearance
bearing_seat_d = 22.0;       // visual seat
bearing_seat_len = 18.0;

set_screw_d = 3.2;           // M3 clearance
set_screw_z = housing_center_z + housing_outer_d*0.25;

fillet_r = 2.0;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1.0) {
    // Minkowski rounded edges (heavier but simple)
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module slot_hole(d=6, slot=0, h=10) {
    // slot along X by 'slot' (0 => round hole)
    if (slot <= 0) {
        cylinder(d=d, h=h, center=true);
    } else {
        hull() {
            translate([-slot/2,0,0]) cylinder(d=d, h=h, center=true);
            translate([ slot/2,0,0]) cylinder(d=d, h=h, center=true);
        }
    }
}

// ---------- Model ----------
module pillow_block() {
    difference() {
        union() {
            // Base
            translate([0,0,base_H/2])
                rounded_box([base_L, base_W, base_H], r=fillet_r);

            // Pedestal
            translate([0,0,base_H + pedestal_H/2])
                rounded_box([pedestal_L, pedestal_W, pedestal_H], r=fillet_r);

            // Housing outer (cylindrical body)
            translate([0,0,housing_center_z])
                rotate([0,90,0])
                    cylinder(d=housing_outer_d, h=housing_len, center=true);

            // Side cheeks to blend housing into pedestal
            for (sx=[-1,1]) {
                translate([sx*(housing_len/2 - 2.5), 0, housing_center_z])
                    rotate([0,90,0])
                        cylinder(d=housing_outer_d*0.92, h=6, center=true);
            }

            // Small top boss (visual)
            translate([0,0,housing_center_z + housing_outer_d*0.35])
                rounded_box([18, 16, 8], r=1.5);
        }

        // Mounting holes (through base)
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*mount_hole_offset_L, sy*mount_hole_offset_W, base_H/2])
                cylinder(d=mount_hole_d, h=base_H+2, center=true);
        }

        // Shaft bore through housing (along X)
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=bore_d, h=housing_len+4, center=true);

        // Bearing seat (counterbore) for visual realism
        translate([0,0,housing_center_z])
            rotate([0,90,0])
                cylinder(d=bearing_seat_d, h=bearing_seat_len, center=true);

        // Relief under housing (creates U-shape cradle)
        translate([0,0,housing_center_z - housing_outer_d*0.35])
            rotate([0,90,0])
                cylinder(d=housing_outer_d*0.78, h=housing_len+2, center=true);

        // Set screw hole (radial, from top down into bore)
        translate([0,0,set_screw_z])
            rotate([90,0,0])
                cylinder(d=set_screw_d, h=base_W+20, center=true);

        // Flatten bottom (ensure perfectly flat)
        translate([0,0,-50])
            cube([base_L+20, base_W+20, 100], center=true);
    }
}

pillow_block();