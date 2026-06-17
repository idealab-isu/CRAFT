// Dimension-calibrated (target: 0.25 x 0.07 x 0.09 mm)
scale([0.840000, 0.593333, 0.638095])
{
// Mirrored L-shaped sheet-metal bracket pair (single connected solid)
// Units: mm

$fn = 64;

// Target bounding box (approx): 0.3 x 0.1 x 0.1
bbox_L = 0.30;
bbox_W = 0.10;
bbox_H = 0.10;

// Sheet metal + features
t = 0.005;

plate_L = bbox_L;     // along X
plate_H = bbox_H;     // along Z
flange_L = bbox_L;    // along X
flange_W = 0.07;      // along Y (each bracket)

bend_r = 0.01;

hole_d = 0.008;
hole_pitch_x = 0.06;
hole_pitch_z = 0.03;
hole_edge_x = 0.03;
hole_edge_z = 0.02;

slot_L = 0.02;
slot_W = 0.008;
slot_offset_from_bend = 0.008; // from inside corner along flange Y

pair_gap = 0.01;      // gap between the two mirrored brackets (air gap)
bridge_t = 0.001;     // thin connector to ensure ONE connected solid

overlap = 0.001;

// Derived placement
// Each bracket occupies Y in [y0, y0+flange_W], with vertical plate centered at y0 + t/2
y0_left  = -(pair_gap/2 + flange_W);
y0_right =  (pair_gap/2);

// ---------- Helpers ----------
module rounded_bend_solid(len_x, r, th) {
    // Quarter-cylinder "bend" volume that connects plate and flange.
    // Axis along X, quarter in +Y/+Z from the inside corner.
    // Built as intersection of a cylinder with a cube to keep only the quadrant.
    intersection() {
        rotate([0,90,0]) cylinder(r=r+th, h=len_x, center=true);
        // Keep +Y and +Z quadrant relative to local origin
        translate([0, (r+th)/2, (r+th)/2])
            cube([len_x + 2*overlap, r+th + 2*overlap, r+th + 2*overlap], center=true);
    }
}

module bracket_at_y(y0) {
    // Inside corner (bend) reference:
    // - Flange top surface at z = t
    // - Plate starts at z = t (so plate does not extend below flange)
    // - Inside corner line at y = y0 + t
    y_inside = y0 + t;

    module raw_body() {
        union() {
            // Horizontal flange: spans y0..y0+flange_W, thickness t at z=0..t
            translate([0, y0 + flange_W/2, t/2])
                cube([flange_L, flange_W, t], center=true);

            // Vertical plate: thickness t in Y, height plate_H above flange (z=t..t+plate_H)
            translate([0, y0 + t/2, t + plate_H/2])
                cube([plate_L, t, plate_H], center=true);

            // Radiused bend volume at inside corner (y=y_inside, z=t)
            translate([0, y_inside, t])
                rounded_bend_solid(plate_L, bend_r, t);
        }
    }

    module hole_pattern_cut() {
        // Holes through the vertical plate (along Y)
        // Place on plate mid-thickness at y = y0 + t/2, with Z measured from bottom of plate (z=t)
        y_hole = y0 + t/2;
        z0 = t + hole_edge_z;
        x0 = -plate_L/2 + hole_edge_x;

        for (ix = [0,1])
            for (iz = [0,1])
                translate([x0 + ix*hole_pitch_x, y_hole, z0 + iz*hole_pitch_z])
                    rotate([90,0,0])
                        cylinder(d=hole_d, h=t + 2*overlap, center=true);
    }

    module flange_slot_cut() {
        // Small central slot on flange near the bend (through thickness)
        // Centered in X, located near inside corner along Y.
        y_slot = y_inside + slot_offset_from_bend;
        translate([0, y_slot, t/2])
            cube([slot_L, slot_W, t + 2*overlap], center=true);
    }

    difference() {
        raw_body();
        union() {
            hole_pattern_cut();
            flange_slot_cut();
        }
    }
}

module connector_bridge() {
    // Thin bridge between the two brackets to make the overall model ONE connected solid.
    // Placed near the inside corners, low profile so it doesn't dominate the shape.
    // Spans the air gap between brackets.
    y_left_inner  = y0_left  + flange_W; // left bracket inner edge at y = -pair_gap/2
    y_right_inner = y0_right;            // right bracket inner edge at y = +pair_gap/2
    y_mid = (y_left_inner + y_right_inner)/2;

    // Bridge spans across the gap plus a tiny overlap into each bracket
    bridge_w = (y_right_inner - y_left_inner) + 2*overlap;

    // Put bridge near the bend region (z around t) and centered in X
    translate([0, y_mid, t/2])
        cube([bbox_L*0.25, bridge_w, bridge_t], center=true);
}

// ---------- Final model ----------
color("Silver")
union() {
    bracket_at_y(y0_left);
    bracket_at_y(y0_right);
    connector_bridge();
}
}
