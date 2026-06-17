$fn = 96;

// Parameters (mm)
length = 40.0;   // X
width  = 35.0;   // Y
height = 20.0;   // Z

shaft_diameter = 8.0;          // shaft size
shaft_clearance = 0.3;         // clearance for sliding fit

// Typical LM8UU outer diameter is ~15mm; use as bearing seat OD
bearing_seat_diameter = 15.0;
bearing_seat_clearance = 0.2;

mounting_hole_diameter = 4.0;
mounting_hole_spacing_x = 30.0;
mounting_hole_spacing_y = 25.0;

clamp_slit_width = 1.0;     // slit thickness (X)
clamp_slit_depth = 12.0;    // how far slit goes down from top (Z)

edge_margin = 2.0;          // keep holes away from edges
eps = 0.02;

// Structural connectivity requirements:
// - Keep the clamp slit, but ensure NO left/right split and NO top/bottom split.
// - Achieve this by leaving BOTH:
//   (1) a Y "web" (prevents left/right halves separation)
//   (2) a Z "web" (prevents top/bottom separation)
// Both webs are 1–2mm+ thick to guarantee a real connection.
web_thickness_y = 2.0;  // mm (center web in Y)
web_thickness_z = 2.0;  // mm (center web in Z)

// Main bearing block (centered)
module bearing_block_body() {
    cube([length, width, height], center=true);
}

// Bearing seat (OD) along X axis
module bearing_seat_bore() {
    rotate([0, 90, 0])
        cylinder(h = length + 2*eps,
                 d = bearing_seat_diameter + bearing_seat_clearance,
                 center=true);
}

// Through bore for 8mm shaft along X axis
module shaft_bore() {
    rotate([0, 90, 0])
        cylinder(h = length + 2*eps,
                 d = shaft_diameter + shaft_clearance,
                 center=true);
}

// Mounting holes: 4x through holes along Z
module mounting_hole_pattern() {
    hx = mounting_hole_spacing_x/2;
    hy = mounting_hole_spacing_y/2;

    // Clamp spacing to fit inside block with margin
    hx2 = min(hx, length/2 - edge_margin);
    hy2 = min(hy, width/2  - edge_margin);

    for (x = [-hx2, hx2])
        for (y = [-hy2, hy2])
            translate([x, y, 0])
                cylinder(h = height + 2*eps, d = mounting_hole_diameter, center=true);
}

// Clamp slit from top down, centered over bore
// FIX: do NOT cut fully across Y (prevents left/right split)
// FIX: do NOT cut fully through Z (prevents top/bottom split)
// We cut two side pockets (+Y and -Y) and stop above the mid-plane,
// leaving a Z web of thickness web_thickness_z.
module clamp_slit_connected() {
    // Ensure slit depth doesn't exceed available height while leaving a Z web
    slit_h = min(clamp_slit_depth, height - web_thickness_z - 0.5);
    slit_h = max(slit_h, 0); // safety

    // Leave a web in the middle of Y so left/right halves remain attached.
    side_cut_w = (width - web_thickness_y)/2 + 2*eps; // each side cut width in Y
    y_off = web_thickness_y/2 + side_cut_w/2 - eps;   // slight overlap into boundary

    // Place the slit so it starts at the top surface and goes down by slit_h,
    // but does NOT cross the central Z web.
    // Top surface is at +height/2. Center of slit volume:
    z_center = height/2 - slit_h/2 + eps;

    // Two slit cuts: one on +Y side, one on -Y side
    translate([0,  y_off, z_center])
        cube([clamp_slit_width, side_cut_w, slit_h + 2*eps], center=true);

    translate([0, -y_off, z_center])
        cube([clamp_slit_width, side_cut_w, slit_h + 2*eps], center=true);
}

// Assembly (single connected solid)
union() {
    difference() {
        bearing_block_body();

        // Bearing cavity
        bearing_seat_bore();
        shaft_bore();

        // Mounting holes
        mounting_hole_pattern();

        // Clamp slit (connected in both Y and Z)
        clamp_slit_connected();
    }
}