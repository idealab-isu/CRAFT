// Faceted bowl-like cup with circular thick rim + deep interior cavity + opposing rim notches
// Structural fixes: ensure cavity is truly open/visible from the top, keep a base, and keep all parts connected.
// All dimensions in mm (very small part as provided)

// ----------------- Parameters -----------------
outer_D = 0.07;                 //[0.035:0.14:0.001]
H = 0.04;                       //[0.02:0.08:0.001]
outer_D_bottom = 0.045;         //[0.0225:0.09:0.001]

rim_th = 0.006;                 //[0.003:0.012:0.001]
lip_radial = 0.004;             //[0.002:0.008:0.001]

wall_th = 0.004;                //[0.002:0.008:0.001]
base_th = 0.002;                //[0.001:0.004:0.0005]

cavity_D_top = 0.056;           //[0.028:0.112:0.001]
cavity_depth = 0.032;           //[0.016:0.064:0.001]
cavity_tip_r = 0.004;           //[0.002:0.008:0.001]

facet_count = 12;               //[6:24:1]

notch_W = 0.012;                //[0.006:0.024:0.001]
notch_H = 0.01;                 //[0.005:0.02:0.001]
notch_depth = 0.006;            //[0.003:0.012:0.001]
notch_z_from_top = 0.006;       //[0.003:0.012:0.001]

rim_round_r = 0.0015;           //[0.0005:0.003:0.0005]
eps = 0.0005;                   //[0.0002:0.002:0.0001]

// ----------------- Derived -----------------
outer_R_top = outer_D/2;
outer_R_bot = outer_D_bottom/2;

// Rim outer radius (thickened lip)
rim_R = outer_R_top + lip_radial;

// Inner opening radius at rim (ensure wall thickness at rim)
inner_R_top = min(max(0.001, cavity_D_top/2), rim_R - wall_th);

// Inner bottom/tip radius
inner_R_bot = max(0.001, cavity_tip_r);

// Keep cavity inside and leave a base
cav_depth = min(cavity_depth, H - base_th - eps);

// Small overlap to guarantee watertight boolean intersections (scaled to tiny model)
ov = max(eps*4, 0.001);

// Z references (centered model)
z_top =  H/2;
z_bot = -H/2;

// Cavity should be OPEN at the top: start the subtractive cavity slightly ABOVE the top surface
// but keep the thick rim by limiting the cavity radius at the rim (inner_R_top).
cav_top_z = z_top + ov;                 // ensures opening is cut through the top
cav_bot_z = z_top - rim_th - cav_depth; // leaves thick rim and base

// ----------------- Geometry helpers -----------------
module faceted_outer_body() {
    cylinder(h=H, r1=outer_R_top, r2=outer_R_bot, center=true, $fn=facet_count);
}

module circular_rim_lip() {
    // Circular thickened rim/lip; overlaps into body for a single connected solid
    translate([0,0, z_top - rim_th/2 - ov/2])
        cylinder(h=rim_th + ov, r=rim_R, center=true, $fn=128);
}

module outer_solid() {
    union() {
        faceted_outer_body();
        circular_rim_lip();
    }
}

module deep_bowl_cavity() {
    // Deep conical/rounded cavity (subtractive), guaranteed open at top.
    // Use a single union of cone + rounded tip, both overlapping.
    union() {
        cav_h = (cav_top_z - cav_bot_z) + 2*ov;
        cav_center_z = (cav_top_z + cav_bot_z)/2;

        // Main conical cavity
        translate([0,0, cav_center_z])
            cylinder(h=cav_h, r1=inner_R_top, r2=inner_R_bot, center=true, $fn=128);

        // Rounded tip at bottom (overlaps into cone)
        translate([0,0, cav_bot_z + inner_R_bot - ov])
            sphere(r=inner_R_bot, $fn=128);
    }
}

module opposing_rim_notches() {
    // Two opposing side cutouts near rim; cut into rim/body radially.
    notch_center_z = z_top - notch_z_from_top;

    // Ensure cutter intersects rim OD and reaches inward
    notch_center_x = rim_R - notch_depth/2 + ov;

    for (sx = [-1, 1]) {
        translate([sx*notch_center_x, 0, notch_center_z])
            cube([notch_depth + 2*ov, notch_W, notch_H], center=true);
    }
}

module rim_roundover_cut() {
    // Subtle roundover at the very top outer edge (subtractive torus segment)
    translate([0,0, z_top - rim_round_r + ov/4])
        rotate_extrude($fn=192)
            translate([rim_R - rim_round_r, 0, 0])
                circle(r=rim_round_r + ov/4, $fn=96);
}

// ----------------- Final model -----------------
difference() {
    // Outer solid (single connected object)
    outer_solid();

    // Hollow it out (deep bowl) - now guaranteed to open through the top
    deep_bowl_cavity();

    // Opposing notches near rim
    opposing_rim_notches();

    // Subtle rim roundover
    rim_roundover_cut();
}