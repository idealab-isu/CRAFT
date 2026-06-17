// Pillow block bearing housing (KP-style) for 8.0mm shaft
// Base: 55.0mm x 42.0mm
// One connected solid, with visible bore + mounting holes

$fn = 128;

// Parameters
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
base_length_mm = 55.0; //[30.0:110.0:0.5]
base_width_mm  = 42.0; //[21.0:84.0:0.5]
base_thickness_mm = 6.0; //[3.0:12.0:0.5]

pedestal_height_mm = 14.0; //[8.0:30.0:0.5]     // height from base top to bore centerline
pedestal_length_mm = 40.0; //[25.0:80.0:0.5]    // length of raised pedestal (along X)
pedestal_width_mm  = 30.0; //[18.0:60.0:0.5]    // width of raised pedestal (along Y)

cap_outer_diameter_mm = 34.0; //[24.0:60.0:0.5] // outer "bearing seat" diameter
cap_length_mm = 30.0; //[18.0:55.0:0.5]         // length of cylindrical cap (along X)

bearing_bore_clearance_mm = 0.2; //[0.0:0.6:0.05]

mount_hole_diameter_mm = 6.5; //[3.0:10.0:0.1]
mount_hole_center_spacing_mm = 40.0; //[20.0:80.0:0.5]
mount_hole_y_offset_mm = 0.0; //[0.0:10.0:0.5]  // keep centered by default

slot_length_mm = 12.0; //[0.0:20.0:0.5]         // 0 => round holes, >0 => slots
slot_end_overlap_mm = 0.6; //[0.2:1.5:0.1]

overlap_mm = 1.0; //[0.5:2.0:0.1]
bore_extra_length_mm = 2.0; //[0.5:6.0:0.5]

// Derived
base_L = base_length_mm;
base_W = base_width_mm;
base_T = base_thickness_mm;

ped_L = min(pedestal_length_mm, base_L - 2*4); // keep within base
ped_W = min(pedestal_width_mm,  base_W - 2*4);

cap_L = min(cap_length_mm, base_L - 2*6);
cap_R = cap_outer_diameter_mm/2;

bore_r = (shaft_diameter_mm + bearing_bore_clearance_mm)/2;
bore_h = base_L + bore_extra_length_mm;

z_base_center = -base_T/2;
z_base_top = 0;

z_bore = z_base_top + pedestal_height_mm;
z_ped_center = z_base_top + pedestal_height_mm/2 - overlap_mm/2; // overlap into base
z_cap_center = z_bore; // cylinder centerline at bore height

// Ensure cap is not smaller than bore + wall
min_wall = 4;
cap_R_eff = max(cap_R, bore_r + min_wall);

// Slot/hole cutter through base
module mount_cut(xc, yc) {
    h = base_T + bore_extra_length_mm;
    if (slot_length_mm <= 0.01) {
        translate([xc, yc, z_base_center])
            cylinder(r=mount_hole_diameter_mm/2, h=h, center=true);
    } else {
        // Slot along X: hull of two cylinders separated by slot_length_mm
        dx = slot_length_mm/2;
        translate([0, 0, z_base_center])
            hull() {
                translate([xc - dx, yc, 0])
                    cylinder(r=mount_hole_diameter_mm/2, h=h, center=true);
                translate([xc + dx, yc, 0])
                    cylinder(r=mount_hole_diameter_mm/2, h=h, center=true);
            }
    }
}

// Main solid (base + pedestal + cap + gussets)
module kp_pillow_block_solid() {
    union() {
        // Base plate (exact 55 x 42)
        translate([0, 0, z_base_center])
            cube([base_L, base_W, base_T], center=true);

        // Raised pedestal block (connected to base)
        translate([0, 0, z_ped_center])
            cube([ped_L, ped_W, pedestal_height_mm + overlap_mm], center=true);

        // Cylindrical cap (bearing seat outer) along X, connected to pedestal
        translate([0, 0, z_cap_center])
            rotate([0, 90, 0])
                cylinder(r=cap_R_eff, h=cap_L, center=true);

        // Gussets (front/back) to resemble pillow block supports, connected at both ends
        for (sx = [-1, 1]) {
            x_end = sx*(cap_L/2 - 2); // near cap ends
            translate([x_end, 0, 0])
                hull() {
                    // base contact pad
                    translate([0, 0, z_base_top + 1])
                        cube([4, ped_W, 2], center=true);
                    // upper contact pad near cap
                    translate([0, 0, z_bore + cap_R_eff*0.55])
                        cube([4, ped_W*0.55, 2], center=true);
                }
        }
    }
}

// Holes (bore + mounting)
module kp_pillow_block_holes() {
    union() {
        // Shaft/bearing bore through the cap (along X)
        translate([0, 0, z_bore])
            rotate([0, 90, 0])
                cylinder(r=bore_r, h=bore_h, center=true);

        // Optional counterbore/seat relief (subtle) to show bearing seat detail
        // (kept shallow so it doesn't disconnect anything)
        seat_r = min(cap_R_eff - 1.5, bore_r + 6);
        seat_h = cap_L * 0.55;
        translate([0, 0, z_bore])
            rotate([0, 90, 0])
                cylinder(r=seat_r, h=seat_h, center=true);

        // Mounting holes/slots through base
        for (sx = [-1, 1]) {
            xh = sx * (mount_hole_center_spacing_mm/2);
            // keep holes inside base by clamping to margins
            xh_clamped = min(max(xh, -base_L/2 + mount_hole_diameter_mm), base_L/2 - mount_hole_diameter_mm);
            mount_cut(xh_clamped, mount_hole_y_offset_mm);
        }
    }
}

// Final assembly
difference() {
    kp_pillow_block_solid();
    kp_pillow_block_holes();
}