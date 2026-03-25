// Dimension-calibrated (target: 0.04 x 0.05 x 0.07 mm)
scale([0.001130, 0.000723, 0.000880])
{
// Wedge-shaped mounting bracket/block (single connected solid)
// Units: mm
$fn = 64;

// -------------------- Parameters (mm) --------------------
body_x = 60;     // length (X)
body_y = 40;     // width  (Y)
body_z = 50;     // height (Z)

// Sloped face: z at x=-body_x/2 is slope_z_left, at x=+body_x/2 is slope_z_right
slope_z_left  = 6;
slope_z_right = 46;

// End flange/step on +X end (thicker vertical flange)
flange_len_x = 10;
flange_extra_y = 10;   // adds thickness on +Y side
flange_z = body_z;

// Small lower protruding foot near +X end, on -Y and bottom
foot_len_x = 14;
foot_y = 12;
foot_z = 10;

// Side relief cavity (small cut on -Y side)
side_cavity_x = 22;
side_cavity_y = 10;
side_cavity_z = 26;
side_cavity_offset_x = 14;  // from -X face inward
side_cavity_offset_z = 10;  // from bottom upward

// Small alignment notch (cut at -X, +Y, bottom corner)
notch_x = 8;
notch_y = 8;
notch_z = 8;

// Cosmetic shallow recess on -Y face
cosmetic_recess_x = 30;
cosmetic_recess_y = 2;
cosmetic_recess_z = 26;

// Holes through Y (on sloped region), plus shallow counterbore/recess on +Y side
hole_d = 4;
recess_d = 7;
recess_depth = 3;
hole_count = 2;
hole_spacing = 16;
hole_edge_margin_x = 16; // from -X face

// Small overlap for robust booleans
eps = 0.2;

// -------------------- Helpers --------------------
function slope_z_at_x(x) =
    slope_z_left + (x + body_x/2) * (slope_z_right - slope_z_left) / body_x;

// Main wedge body: rectangular block with a diagonal cut creating a sloped face
module wedge_body() {
    difference() {
        // Base block
        translate([0, 0, body_z/2])
            cube([body_x, body_y, body_z], center=true);

        // Cut away volume above the sloped plane (creates the diagonal face)
        // Use a large prism defined by a polygon in XZ, extruded along Y.
        translate([0, 0, 0])
            rotate([90, 0, 0])
                linear_extrude(height=body_y + 2*eps, center=true)
                    polygon(points=[
                        // Keep region below the line; remove region above by subtracting a big shape
                        [-body_x/2 - eps, slope_z_left],
                        [ body_x/2 + eps, slope_z_right],
                        [ body_x/2 + eps, body_z + 50],
                        [-body_x/2 - eps, body_z + 50]
                    ]);
    }
}

// End flange step on +X end, thicker on +Y side
module end_flange() {
    // Place flange so it overlaps the main body by eps to ensure connectivity
    translate([ body_x/2 - flange_len_x/2 + eps, (body_y + flange_extra_y)/2 - flange_extra_y/2, flange_z/2 ])
        cube([flange_len_x, body_y + flange_extra_y, flange_z], center=true);
}

// Lower foot protrusion near +X end, on -Y and bottom
module lower_foot() {
    translate([ body_x/2 - foot_len_x/2 + eps, -body_y/2 + foot_y/2, foot_z/2 ])
        cube([foot_len_x, foot_y, foot_z], center=true);
}

// Through holes and shallow recesses (counterbore) on +Y side
module holes_and_recesses() {
    for (i = [0:hole_count-1]) {
        xh = -body_x/2 + hole_edge_margin_x + i*hole_spacing;
        zh = min(body_z - 8, max(8, slope_z_at_x(xh) - 6)); // keep within body

        // Through hole along Y
        translate([xh, 0, zh])
            rotate([90, 0, 0])
                cylinder(d=hole_d, h=body_y + flange_extra_y + 4*eps, center=true);

        // Shallow recess from +Y side
        translate([xh, body_y/2 + flange_extra_y - recess_depth/2 + eps, zh])
            rotate([90, 0, 0])
                cylinder(d=recess_d, h=recess_depth + 2*eps, center=true);
    }
}

// Side relief cavity cut on -Y side
module side_relief_cavity() {
    translate([
        -body_x/2 + side_cavity_offset_x + side_cavity_x/2,
        -body_y/2 + side_cavity_y/2 + eps,
        side_cavity_offset_z + side_cavity_z/2
    ])
        cube([side_cavity_x, side_cavity_y, side_cavity_z], center=true);
}

// Small alignment notch cut at -X, +Y, bottom
module alignment_notch() {
    translate([
        -body_x/2 + notch_x/2 - eps,
        body_y/2 - notch_y/2 + eps,
        notch_z/2 - eps
    ])
        cube([notch_x, notch_y, notch_z], center=true);
}

// Cosmetic shallow recess on -Y face
module cosmetic_recess() {
    translate([0, -body_y/2 + cosmetic_recess_y/2 + eps, body_z/2])
        cube([cosmetic_recess_x, cosmetic_recess_y, cosmetic_recess_z], center=true);
}

// -------------------- Final assembly --------------------
difference() {
    union() {
        wedge_body();
        end_flange();
        lower_foot();
    }

    holes_and_recesses();
    side_relief_cavity();
    alignment_notch();
    cosmetic_recess();
}
}
