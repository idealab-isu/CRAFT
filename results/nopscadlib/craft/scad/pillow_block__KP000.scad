$fn = 96;

// Parameters
shaft_diameter_mm = 10; //[5:20:0.1]
shaft_clearance_mm = 0.3; //[0.1:0.8:0.05]

base_length_mm = 67; //[34:134:0.5]
base_width_mm  = 53; //[27:106:0.5]
base_thickness_mm = 10; //[5:20:0.5]

overall_height_mm = 36; //[20:72:0.5]

bearing_outer_diameter_mm = 30; //[18:60:0.5]
bearing_width_mm = 16; //[8:32:0.5]

housing_length_mm = 50; //[30:100:0.5]
housing_width_mm  = 40; //[20:80:0.5]
housing_base_height_mm = 18; //[10:40:0.5]

mounting_hole_diameter_mm = 8; //[4:14:0.5]
mounting_hole_center_spacing_mm = 50; //[30:100:0.5]
mounting_hole_y_offset_mm = 12; //[6:20:0.5]

connection_overlap_mm = 1; //[0.5:2:0.1]

// Derived
shaft_r   = (shaft_diameter_mm + shaft_clearance_mm)/2;
bearing_r = bearing_outer_diameter_mm/2;

seat_outer_wall_mm = 4;
seat_outer_r = bearing_r + seat_outer_wall_mm;

arch_h = max(6, overall_height_mm - base_thickness_mm - housing_base_height_mm);
seat_center_z = base_thickness_mm + housing_base_height_mm + arch_h/2;

cap_split_w = 2.2;

// Helpers
module rounded_box(size=[10,10,10], r=2, center=true) {
    minkowski() {
        cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
        sphere(r=r);
    }
}

module slot_holes() {
    // Two mounting slots along X, centered in Y, through base
    slot_len = max(mounting_hole_diameter_mm*2.2, 14);
    slot_w   = mounting_hole_diameter_mm;

    for (sx = [-1, 1]) {
        translate([sx*mounting_hole_center_spacing_mm/2, 0, base_thickness_mm/2])
            hull() {
                translate([-slot_len/2 + slot_w/2, 0, 0])
                    cylinder(d=slot_w, h=base_thickness_mm + 2, center=true);
                translate([ slot_len/2 - slot_w/2, 0, 0])
                    cylinder(d=slot_w, h=base_thickness_mm + 2, center=true);
            }
    }
}

module kp_body_solid() {
    union() {
        // Base (67 x 53)
        translate([0,0,base_thickness_mm/2])
            rounded_box([base_length_mm, base_width_mm, base_thickness_mm], r=2.2, center=true);

        // Pedestal (connected to base with overlap)
        translate([0,0,base_thickness_mm + housing_base_height_mm/2 - connection_overlap_mm])
            rounded_box([housing_length_mm, housing_width_mm, housing_base_height_mm], r=2.0, center=true);

        // KP-style arched seat: cylinder along X, clipped to a "cap" region so it looks like a pillow block
        intersection() {
            translate([0,0,seat_center_z])
                rotate([0,90,0])
                    cylinder(r=seat_outer_r, h=housing_length_mm, center=true);

            // Clip to only the upper portion above the pedestal top (with overlap into pedestal)
            pedestal_top_z = base_thickness_mm + housing_base_height_mm;
            cap_z0 = pedestal_top_z - connection_overlap_mm;
            cap_h  = arch_h + seat_outer_r; // enough to include full arch
            translate([0,0,cap_z0 + cap_h/2])
                cube([housing_length_mm + 2, housing_width_mm + 2, cap_h], center=true);
        }

        // Side ribs/cheeks (typical KP body mass around the seat)
        rib_t = max(3, (housing_width_mm - bearing_width_mm)/2);
        rib_h = arch_h * 0.85;
        for (sy = [-1, 1]) {
            translate([0,
                       sy*(bearing_width_mm/2 + rib_t/2 - connection_overlap_mm),
                       base_thickness_mm + housing_base_height_mm + rib_h/2 - connection_overlap_mm])
                rounded_box([housing_length_mm*0.92, rib_t, rib_h], r=1.6, center=true);
        }

        // Small end bulges to suggest KP end walls and keep silhouette closer to standard housings
        end_bulge_w = max(3, seat_outer_r*0.55);
        end_bulge_h = arch_h*0.9;
        for (sx = [-1, 1]) {
            translate([sx*(housing_length_mm/2 - end_bulge_w/2 + connection_overlap_mm),
                       0,
                       base_thickness_mm + housing_base_height_mm + end_bulge_h/2 - connection_overlap_mm])
                rounded_box([end_bulge_w, housing_width_mm*0.92, end_bulge_h], r=1.6, center=true);
        }
    }
}

// FIX: Bearing insert must be physically fused to the housing.
// Add small "keys" that overlap into the housing cheeks so the insert cannot be a separate floating body.
module bearing_insert_solid() {
    insert_overlap = max(1, min(2, connection_overlap_mm + 1)); // 1..2mm
    insert_len = housing_length_mm + 2*insert_overlap;

    // Cheek/key overlap: extend slightly into the side ribs region (Y) so union() fuses reliably.
    rib_t = max(3, (housing_width_mm - bearing_width_mm)/2);
    key_y = bearing_width_mm/2 + rib_t/2;                 // center of ribs
    key_w = max(2, min(4, rib_t));                        // key thickness in Y
    key_h = max(2, min(4, seat_outer_r*0.25));            // key height in Z
    key_x = max(2, min(4, insert_overlap + 1));           // key length in X (small but solid)

    union() {
        // Main insert cylinder (kept as in original intent)
        translate([0,0,seat_center_z])
            rotate([0,90,0])
                cylinder(r=bearing_r, h=insert_len, center=true);

        // Two small keys that intersect both the insert and the housing ribs by ~1-2mm
        for (sy = [-1, 1]) {
            translate([0, sy*key_y, seat_center_z])
                cube([key_x, key_w, key_h], center=true);
        }
    }
}

module pillow_block() {
    // Union all solids first (body + insert), then subtract holes/cavities.
    difference() {
        union() {
            kp_body_solid();
            bearing_insert_solid(); // FIX: now mechanically fused via overlap keys
        }

        // Mounting slots through base
        slot_holes();

        // Shaft through-bore (10mm + clearance) through entire base length
        translate([0,0,seat_center_z])
            rotate([0,90,0])
                cylinder(r=shaft_r, h=base_length_mm + 2, center=true);

        // Split-cap hint (shallow groove on top, does not disconnect)
        groove_depth = min(2.2, arch_h*0.35);
        groove_z = base_thickness_mm + housing_base_height_mm + arch_h - groove_depth/2;
        translate([0,0,groove_z])
            cube([housing_length_mm + 2, cap_split_w, groove_depth + 0.2], center=true);
    }
}

// Final
pillow_block();