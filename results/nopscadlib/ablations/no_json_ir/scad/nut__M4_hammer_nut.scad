$fn = 96;

// --- Requested dimensions ---
nut_thickness  = 3.25;  // overall thickness (Z)
hex_af         = 6.0;   // across flats (hex pocket)
screw_diameter = 4.0;   // through hole diameter

// --- T-slot nut body dimensions (parametric, connected "T" profile) ---
t_head_w = 8.0;   // head width (X) that sits in slot
t_head_l = 12.0;  // head length (Y) along slot
t_neck_w = 6.0;   // neck width (X)
t_neck_l = 8.0;   // neck length (Y)

// --- Features ---
hex_pocket_depth = 2.2;   // depth of hex socket from TOP face (<= nut_thickness)
chamfer          = 0.35;  // small edge chamfer (top/bottom)
eps              = 0.02;

// --- Connectivity / overlap control (1-2mm as required) ---
overlap_xy = 1.2; // ensures attached parts intersect in XY (prevents "floating" in top view)

// --- Helpers ---
function hex_r_from_af(af) = af / sqrt(3); // circumradius for a hex with given across-flats

module hex_prism(af, h, center=false) {
    r = hex_r_from_af(af);
    cylinder(h=h, r=r, $fn=6, center=center);
}

module t_body_2d() {
    // True "T": neck extends only to one side of head (anti-rotation geometry)
    // Head centered at origin; neck centered below head.
    union() {
        square([t_head_w, t_head_l], center=true);
        translate([0, -(t_head_l/2 + t_neck_l/2), 0])
            square([t_neck_w, t_neck_l], center=true);
    }
}

module t_slot_nut() {
    difference() {
        // --- ONE connected solid (union) ---
        union() {
            // Main extruded T-body
            linear_extrude(height=nut_thickness, center=true)
                t_body_2d();

            // Added "keeper/plate" block (the previously floating blue part):
            // Attach it to the *bottom end* of the neck with a guaranteed overlap in Y.
            // This preserves the overall design intent while ensuring physical connection.
            plate_w = t_neck_w;          // match neck width
            plate_l = 4.0;               // small rectangular plate length (Y)
            plate_h = nut_thickness;     // same thickness so it is one solid

            // Neck bottom edge (most negative Y) is at: -(t_head_l/2 + t_neck_l)
            // Place plate so its top overlaps the neck by overlap_xy.
            y_neck_bottom = -(t_head_l/2 + t_neck_l);
            y_plate_center = y_neck_bottom - plate_l/2 + overlap_xy;

            translate([0, y_plate_center, 0])
                cube([plate_w, plate_l, plate_h], center=true);
        }

        // --- Subtractions / features ---
        // Through-hole for 4.0mm screw (full cut)
        cylinder(h=nut_thickness + 2, d=screw_diameter, center=true);

        // Hex socket (across flats = 6.0mm) from TOP face
        pocket_h = min(hex_pocket_depth, nut_thickness - eps);
        translate([0, 0, nut_thickness/2 - pocket_h + eps])
            hex_prism(hex_af, pocket_h + 2*eps, center=false);

        // Top/bottom chamfers: subtract shallow frustums sized from body extents
        body_r = sqrt(pow(t_head_w/2, 2) + pow((t_head_l + t_neck_l)/2, 2));
        for (s = [-1, 1]) {
            translate([0, 0, s*(nut_thickness/2 - chamfer/2)])
                cylinder(h=chamfer + eps,
                         r1=body_r + chamfer,
                         r2=body_r,
                         center=true);
        }
    }
}

t_slot_nut();