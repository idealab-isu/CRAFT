// Sheet DiBond (aluminum skins + composite core) with corner chamfers and mounting holes
// ONE connected solid (holes are subtractions). Layering is represented by shallow surface recesses.

$fn = 96;

// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width  = 500;  //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.1]

corner_chamfer = 10;     //[0:30:0.5]
hole_diameter  = 6;      //[2:12:0.5]
hole_edge_offset = 25;   //[10:80:1]

// DiBond construction (typical)
skin_thickness = 0.3;    //[0.1:1:0.05]  // aluminum skin thickness each side

// Robustness
eps = 0.02;
min_skin = 0.05;

// Clamp skin thickness to valid range
skin_t = min(max(skin_thickness, min_skin), (sheet_thickness - min_skin)/2);
core_t = max(sheet_thickness - 2*skin_t, min_skin);

// Derived
halfL = sheet_length/2;
halfW = sheet_width/2;
halfT = sheet_thickness/2;

hole_r = hole_diameter/2;
hole_h = sheet_thickness + 2*eps;

ch = min(corner_chamfer, min(sheet_length, sheet_width)/2);
ch_cut_h = sheet_thickness + 4*eps;

// Visual layer cue (engraved step line) - keep small so it doesn't weaken geometry
recess_depth = min(skin_t*0.35, sheet_thickness*0.15);
recess_depth = max(recess_depth, 0); // safety

// Ensure holes stay inside sheet
off = min(max(hole_edge_offset, hole_r + 0.5), min(halfL, halfW) - hole_r - 0.5);

// Base sheet
module sheet_solid() {
    cube([sheet_length, sheet_width, sheet_thickness], center=true);
}

// Chamfer cut at corner
module chamfer_cut_at(xsign, ysign) {
    translate([xsign*(halfL - ch/2), ysign*(halfW - ch/2), 0])
        rotate([0, 0, 45])
            cube([ch, ch, ch_cut_h], center=true);
}

// Hole
module hole_at(x, y) {
    translate([x, y, 0])
        cylinder(r=hole_r, h=hole_h, center=true);
}

// All holes
module mounting_holes() {
    hole_at(-halfL + off, -halfW + off);
    hole_at( halfL - off, -halfW + off);
    hole_at( halfL - off,  halfW - off);
    hole_at(-halfL + off,  halfW - off);
}

// Layer boundary recess (shows aluminum skin boundary on faces)
module skin_boundary_recesses() {
    if (recess_depth > 0) {
        // Top face recess: remove everything above z = halfT - skin_t
        translate([0, 0, (halfT - skin_t) + (recess_depth/2)])
            cube([sheet_length + 4*eps, sheet_width + 4*eps, recess_depth + 2*eps], center=true);

        // Bottom face recess: remove everything below z = -halfT + skin_t
        translate([0, 0, (-halfT + skin_t) - (recess_depth/2)])
            cube([sheet_length + 4*eps, sheet_width + 4*eps, recess_depth + 2*eps], center=true);
    }
}

// Final connected solid
module dibond_sheet_connected() {
    color([0.72, 0.72, 0.74])  // aluminum-like overall
    difference() {
        sheet_solid();

        // Corner chamfers
        if (ch > 0) {
            chamfer_cut_at( 1,  1);
            chamfer_cut_at(-1,  1);
            chamfer_cut_at(-1, -1);
            chamfer_cut_at( 1, -1);
        }

        // Mounting holes
        mounting_holes();

        // Subtle recesses to indicate aluminum skins vs core while keeping ONE solid
        skin_boundary_recesses();
    }
}

dibond_sheet_connected();