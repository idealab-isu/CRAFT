$fn = 96;

// -------------------- Parameters (mm) --------------------
base_L = 55.0;                 // base length (X)
base_W = 42.0;                 // base width  (Y)
base_T = 6.0;                  // base thickness (Z)

bore_D = 8.0;                  // shaft diameter
bore_clearance = 0.2;

center_height = 18.0;          // shaft center above bottom of base

// Typical 2-hole pillow block uses 2 mounting holes along X
mount_hole_D = 6.5;
mount_hole_spacing_L = 40.0;   // hole spacing along X
mount_slot_L = 12.0;           // slot length along X (>= hole_D)
counterbore_D = 11.0;
counterbore_depth = 3.0;

housing_L = 40.0;              // housing length (X)
housing_W = 30.0;              // housing width  (Y)
housing_H = 22.0;              // housing block height (Z)

housing_seat_R = 12.0;         // outer "cap" radius around bore
cap_len = housing_L;           // cap length along X

grease_boss_D = 8.0;
grease_boss_H = 6.0;

set_screw_D = 4.0;
set_screw_depth = 12.0;

fillet_R = 1.0;                // small edge softening
overlap = 0.6;                 // boolean overlap

// -------------------- Derived --------------------
bore_R = (bore_D + bore_clearance)/2;
shaft_Z = center_height;

base_top_Z = base_T;

housing_bottom_Z = base_top_Z - overlap;
housing_top_Z = housing_bottom_Z + housing_H;

// Cap centered on shaft axis; ensure it intersects housing
cap_center_Z = shaft_Z;
cap_bottom_Z = cap_center_Z - housing_seat_R;
cap_raise = max(0, (housing_bottom_Z + 1.0) - cap_bottom_Z);
cap_center_Z_adj = cap_center_Z + cap_raise;

// Ensure housing reaches up to cap (if parameters change)
cap_bottom_Z_adj = cap_center_Z_adj - housing_seat_R;
housing_H_adj = max(housing_H, (cap_bottom_Z_adj - housing_bottom_Z) + 1.0);

// Mounting hole Y position (2-hole base, symmetric)
mount_hole_Y = base_W * 0.30;  // visually similar to typical pillow blocks, stays within base

// -------------------- Primitives --------------------
module base_plate() {
    translate([0, 0, base_T/2])
        cube([base_L, base_W, base_T], center=true);
}

module housing_block() {
    translate([0, 0, housing_bottom_Z + housing_H_adj/2])
        cube([housing_L, housing_W, housing_H_adj], center=true);
}

module bearing_cap() {
    translate([0, 0, cap_center_Z_adj])
        rotate([0, 90, 0])
            cylinder(r=housing_seat_R, h=cap_len, center=true);
}

module grease_boss() {
    translate([0, 0, (cap_center_Z_adj + housing_seat_R) + grease_boss_H/2 - overlap])
        cylinder(d=grease_boss_D, h=grease_boss_H, center=true);
}

module shaft_bore() {
    // Through bore along X (clearly visible)
    translate([0, 0, cap_center_Z_adj])
        rotate([0, 90, 0])
            cylinder(r=bore_R, h=base_L + 2*housing_seat_R + 20, center=true);
}

module set_screw_hole() {
    // Radial set screw from +Y side into bore (along -Y)
    y_outside = max(housing_W/2, housing_seat_R) + set_screw_depth/2 - overlap;
    translate([0, y_outside, cap_center_Z_adj])
        rotate([90, 0, 0])
            cylinder(d=set_screw_D, h=set_screw_depth + 2*overlap, center=true);
}

module mount_slots_and_counterbores() {
    // 2 mounting slots along X, symmetric about origin, located near Y edges
    // Slot made by hull of two cylinders; counterbore similarly from top.
    slot_r = mount_hole_D/2;
    slot_half = max(0, mount_slot_L/2 - slot_r);

    for (sy = [-1, 1]) {
        y = sy * mount_hole_Y;

        // Through slot
        hull() {
            translate([+slot_half, y, base_T/2])
                cylinder(r=slot_r, h=base_T + 2*overlap, center=true);
            translate([-slot_half, y, base_T/2])
                cylinder(r=slot_r, h=base_T + 2*overlap, center=true);
        }

        // Counterbore slot from top
        cb_r = counterbore_D/2;
        cb_half = max(0, mount_slot_L/2 - cb_r);
        hull() {
            translate([+cb_half, y, base_T - counterbore_depth/2])
                cylinder(r=cb_r, h=counterbore_depth + 2*overlap, center=true);
            translate([-cb_half, y, base_T - counterbore_depth/2])
                cylinder(r=cb_r, h=counterbore_depth + 2*overlap, center=true);
        }
    }
}

// -------------------- Main solid --------------------
module pillow_block_solid() {
    union() {
        base_plate();
        housing_block();   // overlaps into base via housing_bottom_Z
        bearing_cap();     // intersects housing by construction
        grease_boss();     // overlaps into cap
    }
}

module pillow_block() {
    difference() {
        pillow_block_solid();
        shaft_bore();
        mount_slots_and_counterbores();
        set_screw_hole();
    }
}

// Fillet/soften edges while keeping one connected solid
minkowski() {
    pillow_block();
    sphere(r=fillet_R);
}