$fn = 96;

// Target bounding box (approx): 92.7 x 67.7 x 10.8 mm

// Key dimensions
bbox_L = 92.71;
bbox_W = 67.70;
bbox_H = 10.79;

plate_t = 3.20;          // main plate thickness
boss_h  = bbox_H - plate_t;

plate_L = 34.0;          // central rectangle length (X)
plate_W = 22.0;          // central rectangle width  (Y)

arm_w   = 10.0;          // arm width
lug_od  = 18.0;          // lug outer diameter
hole_d  = 5.20;          // through-hole diameter

// Lug center offsets (set to hit the target bbox)
lug_center_offset_x = bbox_L/2 - lug_od/2;  // 37.355
lug_center_offset_y = bbox_W/2 - lug_od/2;  // 25.85

// Small overlaps to guarantee watertight unions/differences
eps = 0.05;
overlap = 0.6;

// Derived
boss_zc = plate_t + boss_h/2;     // boss center Z (boss sits on top of plate)
plate_zc = plate_t/2;

// 2D helpers
module rect2d(L, W) { square([L, W], center=true); }
module circ2d(d)    { circle(d=d); }

// One arm as a 2D hull between a rectangle at the plate corner and a circle at the lug center
module arm2d(sx, sy) {
    // Plate corner point where arm starts (outer corner of central plate)
    px = sx * plate_L/2;
    py = sy * plate_W/2;

    // Lug center
    lx = sx * lug_center_offset_x;
    ly = sy * lug_center_offset_y;

    hull() {
        translate([px, py]) rect2d(arm_w, arm_w);
        translate([lx, ly]) circ2d(lug_od);
    }
}

// Full 2D outline: central plate + 4 arms + 4 lug discs
module outline2d() {
    union() {
        rect2d(plate_L, plate_W);

        arm2d( 1,  1);
        arm2d(-1,  1);
        arm2d( 1, -1);
        arm2d(-1, -1);

        // Ensure full circular lugs are present
        translate([ lug_center_offset_x,  lug_center_offset_y]) circ2d(lug_od);
        translate([-lug_center_offset_x,  lug_center_offset_y]) circ2d(lug_od);
        translate([ lug_center_offset_x, -lug_center_offset_y]) circ2d(lug_od);
        translate([-lug_center_offset_x, -lug_center_offset_y]) circ2d(lug_od);
    }
}

// Main solid: planar plate + raised bosses at lugs, then subtract through-holes
module bracket() {
    difference() {
        union() {
            // Base plate (planar X-shape)
            linear_extrude(height=plate_t)
                outline2d();

            // Raised cylindrical bosses at the four mounting points (connected to plate)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([sx*lug_center_offset_x, sy*lug_center_offset_y, plate_t - overlap])
                    cylinder(h=boss_h + overlap, d=lug_od, center=false);
            }
        }

        // Through-holes at the four mounting points (cut through entire thickness)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*lug_center_offset_x, sy*lug_center_offset_y, -eps])
                cylinder(h=bbox_H + 2*eps, d=hole_d, center=false);
        }
    }
}

bracket();