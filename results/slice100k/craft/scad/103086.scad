// Rigid C-shaped / U-bracket with open rectangular throat and a CLEAR hex through-hole
// Bounding box target: 55.4 x 31.5 x 37.5 mm (L x W x H)

$fn = 96;

// -------------------- Parameters (mm) --------------------
bbox_L = 55.44;
bbox_W = 31.55;
bbox_H = 37.52;

wall_t        = 4.0;   // leg thickness along X
bar_thickness = 8.0;   // base bar thickness along Z

// Leg heights (asymmetric)
long_leg_H  = bbox_H;  // tall leg reaches full height
short_leg_H = 22.0;    // shorter leg

// Throat (open window) dimensions (void)
throat_L = 39.0;
throat_W = 23.0;

// Hex through-hole (through Z so hex is visible in TOP view)
hex_flat_to_flat         = 8.0;
hex_hole_offset_from_end = 10.0; // from left end along X
hex_hole_y_from_center   = 0.0;  // centered in width

// Place hole in the base bar so it is unmistakably present
hex_hole_z_from_bottom   = bar_thickness/2; // centered in bar thickness

// Chamfer/taper on outer end of tall leg (left end)
chamfer_len  = 3.0;   // along X
chamfer_drop = 1.5;   // along Z

// Robust boolean overlap
eps = 0.6;

// -------------------- Helpers --------------------
function hex_R_from_F(F) = F / sqrt(3); // circumradius for flat-to-flat F

module hex_prism_through_z(F, hZ) {
    // Hex centered at origin in XY, extruded along Z
    linear_extrude(height=hZ, center=true)
        polygon(points=[
            for (i=[0:5]) [
                hex_R_from_F(F) * cos(60*i),
                hex_R_from_F(F) * sin(60*i)
            ]
        ]);
}

// -------------------- Main solids --------------------
module long_bar() {
    // Base bar spans full length and width, thickness in Z, bottom at Z=0
    translate([0, 0, bar_thickness/2])
        cube([bbox_L, bbox_W, bar_thickness], center=true);
}

module leg_at_end(is_left=true, H=30) {
    // Vertical plate at an end, spanning full width in Y, thickness wall_t in X
    // Slight overlap into the bar for watertight union
    x = (is_left ? -bbox_L/2 + wall_t/2 : bbox_L/2 - wall_t/2);
    translate([x, 0, H/2])
        cube([wall_t + eps, bbox_W, H], center=true);
}

module u_bracket_solid() {
    union() {
        long_bar();
        leg_at_end(true,  long_leg_H);
        leg_at_end(false, short_leg_H);
    }
}

module throat_void() {
    // Remove a rectangular window above the bar, leaving end legs and open throat.
    // Keep a little clearance from the legs by using throat_L < (bbox_L - 2*wall_t).
    z_h = (bbox_H - bar_thickness) + 2*eps;
    translate([0, 0, bar_thickness + (bbox_H - bar_thickness)/2])
        cube([throat_L, throat_W, z_h], center=true);
}

module hex_hole() {
    // CLEAR hex through-hole through Z (visible in TOP view), located near left end.
    // Drill through the base bar thickness (plus eps) so it always cuts.
    x = -bbox_L/2 + hex_hole_offset_from_end;
    y = hex_hole_y_from_center;
    z = hex_hole_z_from_bottom;

    translate([x, y, z])
        hex_prism_through_z(hex_flat_to_flat, bar_thickness + 2*eps);
}

module long_leg_outer_chamfer() {
    // Chamfer at the OUTER top end of the tall (left) leg.
    // Cut a wedge near the leftmost face, sloping down toward +X.
    x_outer = -bbox_L/2;

    // Position cutter so it intersects the top of the long leg and the outer face.
    // Use generous size + eps to guarantee a clean cut.
    translate([x_outer + chamfer_len/2, 0, long_leg_H - chamfer_drop/2])
        rotate([0, 35, 0])
            cube([chamfer_len*2.4, bbox_W + 2*eps, chamfer_drop*3.4], center=true);
}

// -------------------- Final model --------------------
difference() {
    u_bracket_solid();
    throat_void();
    hex_hole();
    long_leg_outer_chamfer();
}