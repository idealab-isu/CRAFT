$fn=96;

// Pillow block bearing (UCP-style) for 12mm shaft, base 71x56mm
// One connected solid: base + saddle + housing + end caps
// Includes: 2 mounting slots through base, clear 12mm bore through housing, bearing seat step.
// All translate() values are derived from dimensions (no arbitrary placement).

shaft_d = 12.0;

base_L = 71.0;
base_W = 56.0;
base_H = 12.0;

mount_hole_d   = 10.0;
mount_hole_x   = 54.0;   // center-to-center along length (X)
mount_slot_len = 14.0;   // slot length along X

housing_outer_d   = 44.0;
housing_len       = 38.0;  // along X
housing_center_h  = 28.0;  // shaft center height from base bottom (z=0)

bearing_OD         = 35.0;
bearing_width      = 11.0;
bearing_seat_clear = 0.25;

set_screw_d        = 5.0;
set_screw_angle    = 25;   // degrees down from horizontal
set_screw_offset_z = 2.0;

fillet_r = 3.0;

module rounded_box(l,w,h,r){
    // robust for small r; keep positive core
    core_l = max(l-2*r, 0.01);
    core_w = max(w-2*r, 0.01);
    core_h = max(h-2*r, 0.01);
    minkowski(){
        cube([core_l, core_w, core_h], center=true);
        sphere(r=r);
    }
}

module slot_hole(d=10, slot=0, h=20){
    // slot along X
    if (slot <= 0){
        cylinder(d=d, h=h, center=true);
    } else {
        hull(){
            translate([-slot/2,0,0]) cylinder(d=d, h=h, center=true);
            translate([ slot/2,0,0]) cylinder(d=d, h=h, center=true);
        }
    }
}

module pillow_block(){
    // Derived placements
    z_base_c = base_H/2;
    z_shaft  = housing_center_h;

    // Overlap to guarantee connectivity
    overlap = 1.0;

    // Saddle between base and housing
    saddle_t   = 8.0;
    z_saddle_c = base_H + saddle_t/2 - overlap;

    saddle_L = min(housing_len*0.92, base_L - 2*fillet_r);
    saddle_W = min(base_W*0.78,     base_W - 2*fillet_r);

    // Mounting slots through base
    mount_y = 0;
    mount_z = z_base_c;

    // Set screw positions (mirrored in Y)
    ss_y = bearing_OD*0.22;
    ss_z = z_shaft + set_screw_offset_z;

    difference(){
        union(){
            // Base (bottom at z=0)
            translate([0,0,z_base_c])
                rounded_box(base_L, base_W, base_H, fillet_r);

            // Saddle (connected to base)
            translate([0,0,z_saddle_c])
                rounded_box(saddle_L, saddle_W, saddle_t, 2.0);

            // Main housing boss (axis along X)
            translate([0,0,z_shaft])
                rotate([0,90,0])
                    cylinder(d=housing_outer_d, h=housing_len, center=true);

            // Blend boss to saddle (ensures robust connection)
            hull(){
                translate([0,0,z_saddle_c])
                    cube([saddle_L*0.92, saddle_W*0.92, 0.2], center=true);
                translate([0,0,z_shaft])
                    rotate([0,90,0])
                        cylinder(d=housing_outer_d, h=housing_len*0.92, center=true);
            }

            // End caps/shoulders (connected)
            cap_t = 4.0;
            for (sx=[-1,1]){
                translate([sx*(housing_len/2 + cap_t/2 - overlap), 0, z_shaft])
                    rotate([0,90,0])
                        cylinder(d=housing_outer_d*0.92, h=cap_t, center=true);
            }
        }

        // Mounting slots (through base only)
        for (sx=[-1,1]){
            translate([sx*mount_hole_x/2, mount_y, mount_z])
                slot_hole(d=mount_hole_d, slot=mount_slot_len, h=base_H+2);
        }

        // Shaft bore through housing (along X) - clearly through
        translate([0,0,z_shaft])
            rotate([0,90,0])
                cylinder(d=shaft_d+0.4, h=housing_len+8, center=true);

        // Bearing seat (counterbore) centered in housing (along X)
        translate([0,0,z_shaft])
            rotate([0,90,0])
                cylinder(d=bearing_OD + bearing_seat_clear, h=bearing_width+0.6, center=true);

        // Shallow relief around seat (visible step)
        translate([0,0,z_shaft])
            rotate([0,90,0])
                cylinder(d=bearing_OD + 6, h=max(bearing_width-2, 2), center=true);

        // Set screw holes (angled), mirrored in Y
        for (sy=[-1,1]){
            translate([0, sy*ss_y, ss_z])
                rotate([0, set_screw_angle, 0])
                    rotate([90,0,0])
                        cylinder(d=set_screw_d, h=housing_outer_d+8, center=true);
        }

        // Flatten bottom exactly at z=0 (prevents underside artifacts)
        translate([-base_L, -base_W, -2*(base_H + housing_outer_d)])
            cube([2*base_L, 2*base_W, 2*(base_H + housing_outer_d)], center=false);
    }
}

pillow_block();