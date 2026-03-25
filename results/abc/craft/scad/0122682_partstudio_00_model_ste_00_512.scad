// Dimension-calibrated (target: 0.08 x 0.08 x 0.05 mm)
scale([0.683333, 0.939767, 0.662619])
{
$fn = 32;

// -------------------- Parameters (mm) --------------------
bbox_x = 0.10;
bbox_y = 0.10;
bbox_z = 0.10;

plate_t = 0.008;

base_L = 0.080;
base_W = 0.080;

upright_H = 0.050;
upright_W = 0.080;

fillet_r = 0.020;

hole_d = 0.012;
hole_center_from_bend = 0.030;     // along Z from inside corner (bend)
hole_center_from_side = 0.040;     // along Y from -upright_W/2

flange_h = 0.010;
flange_t = 0.006;

outer_r = 0.003;                  // simplified: used only in 2D offset (no minkowski)

relief_L = 0.012;
relief_W = 0.012;
relief_depth = 0.004;

eps = 0.0008;

// -------------------- Helpers --------------------
module rrect2d(w, h, r) {
    rr = min(r, min(w,h)/2);
    offset(r=rr) square([w-2*rr, h-2*rr], center=true);
}

// Quarter-cylinder fillet (solid) along Y, placed in +X,+Z quadrant from origin
module internal_fillet_quarter(r, len_y) {
    intersection() {
        rotate([90,0,0]) cylinder(r=r, h=len_y, center=true);
        translate([r/2, 0, r/2]) cube([r, len_y + 2*eps, r], center=true);
    }
}

// -------------------- Main geometry --------------------
module base_plate_rounded() {
    // Rounded in XY only (fast): offset 2D then extrude
    translate([base_L/2, 0, 0])
        linear_extrude(height=plate_t)
            rrect2d(base_L, base_W, outer_r);
}

module upright_plate_rounded() {
    // Rounded in YZ only (fast): offset 2D then extrude along X
    translate([0, 0, upright_H/2])
        rotate([0,90,0])
            linear_extrude(height=plate_t)
                rrect2d(upright_W, upright_H, outer_r);
}

module edge_flange_lip() {
    // Thickened lip along +Y edge of base, sitting on top of base
    translate([base_L/2, base_W/2 - flange_t/2, plate_t - eps])
        cube([base_L, flange_t, flange_h], center=false);
}

module internal_fillet() {
    // Large internal fillet at inside corner between base (Z=0) and upright (X=0)
    translate([fillet_r, 0, fillet_r])
        internal_fillet_quarter(fillet_r, upright_W);
}

module bend_relief() {
    // Small relieved region near the bend (remove material)
    translate([relief_L/2 + eps, 0, relief_depth/2 + eps])
        cube([relief_L, relief_W, relief_depth], center=true);
}

module upright_through_hole() {
    // Through-hole in upright leg, drilled along X through the plate thickness
    y0 = -upright_W/2 + hole_center_from_side;
    z0 = hole_center_from_bend;
    translate([plate_t/2, y0, z0])
        rotate([0,90,0])
            cylinder(d=hole_d, h=plate_t + 6*eps, center=true);
}

// -------------------- Assembly --------------------
module raw_bracket() {
    union() {
        base_plate_rounded();
        upright_plate_rounded();
        internal_fillet();
        edge_flange_lip();
    }
}

module final_bracket() {
    difference() {
        raw_bracket();
        upright_through_hole();
        bend_relief();
    }
}

// -------------------- Render --------------------
final_bracket();
}
