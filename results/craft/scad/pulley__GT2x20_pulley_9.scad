// Timing pulley: 20 teeth, 12.22mm pitch diameter
// One connected solid (union of body + teeth) with bore and optional set-screw holes subtracted.

$fn = 200;

// -------------------- Parameters --------------------
tooth_count = 20;                 // required
pitch_diameter_mm = 12.22;        // required
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10;

tolerance_mm = 0.2;

// Tooth geometry (GT2-like simplified, but shaped as belt teeth around circumference)
tooth_depth_mm = 0.75;            // radial height from root to tip
tooth_tangential_width_mm = 1.15; // chord width at root (approx)
tooth_tip_width_mm = 0.65;        // chord width at tip (approx)
tooth_round_radius_mm = 0.35;     // rounding at tooth tip corners

tooth_root_clearance_mm = 0.35;   // pitch line sits above root by this amount

bore_diameter_mm = 5;

hub_diameter_mm = 16;
hub_length_mm = 6;

flange_diameter_mm = 18;
flange_thickness_mm = 1.5;

set_screw_count = 1;              // 0..2
set_screw_size = 3;
set_screw_z_mm = 3;

overlap_mm = 0.6;                 // overlap for robust unions
eps_mm = 0.2;

// -------------------- Derived radii --------------------
// Ensure requested pitch diameter: pitch_radius = root_radius + tooth_root_clearance
tooth_root_radius_mm  = pitch_radius_mm - tooth_root_clearance_mm;
tooth_outer_radius_mm = tooth_root_radius_mm + tooth_depth_mm;

// Z layout (all formulas, no arbitrary offsets)
z_hub_center     = hub_length_mm/2;
z_flange1_center = hub_length_mm + flange_thickness_mm/2;
z_teeth_center   = hub_length_mm + flange_thickness_mm + pulley_width_mm/2;
z_flange2_center = hub_length_mm + flange_thickness_mm + pulley_width_mm + flange_thickness_mm/2;

total_height_mm  = hub_length_mm + 2*flange_thickness_mm + pulley_width_mm;
z_total_center   = total_height_mm/2;

// -------------------- Modules --------------------
module tooth_2d() {
    // Tooth cross-section in XY where +X is radial outward, Y is tangential.
    // Built as a rounded trapezoid to look like timing-belt teeth (not axial ribs).
    w_root = tooth_tangential_width_mm;
    w_tip  = tooth_tip_width_mm;
    h      = tooth_depth_mm;
    rr     = min(tooth_round_radius_mm, min(w_tip, h)/2);

    // Rounded trapezoid via hull of circles at the four corners
    hull() {
        // root corners
        translate([0 + rr, -w_root/2 + rr]) circle(r=rr, $fn=32);
        translate([0 + rr,  w_root/2 - rr]) circle(r=rr, $fn=32);

        // tip corners
        translate([h - rr, -w_tip/2 + rr])  circle(r=rr, $fn=32);
        translate([h - rr,  w_tip/2 - rr])  circle(r=rr, $fn=32);
    }
}

module teeth_ring() {
    // Place teeth around circumference so they protrude radially outward.
    // Inner edge overlaps into root cylinder by overlap_mm for connectivity.
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*360/tooth_count])
            translate([tooth_root_radius_mm - overlap_mm, 0, z_teeth_center])
                linear_extrude(height=pulley_width_mm, center=true, convexity=10)
                    tooth_2d();
    }
}

module pulley_solid() {
    union() {
        // Hub (bottom)
        translate([0,0,z_hub_center])
            cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (connected)
        translate([0,0,z_flange1_center])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        translate([0,0,z_flange2_center])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

        // Root cylinder under teeth (continuous body)
        translate([0,0,z_teeth_center])
            cylinder(r=tooth_root_radius_mm, h=pulley_width_mm, center=true);

        // Teeth
        teeth_ring();
    }
}

module pulley_cutouts() {
    // Bore through entire part
    translate([0,0,z_total_center])
        cylinder(r=bore_diameter_mm/2 + tolerance_mm/2,
                 h=total_height_mm + 2*eps_mm, center=true);

    // Set screw holes (through hub)
    if (set_screw_count > 0) {
        translate([0,0,set_screw_z_mm])
            rotate([0,90,0])
                cylinder(r=set_screw_size/2 + tolerance_mm/2,
                         h=hub_diameter_mm + 2*eps_mm, center=true);
    }
    if (set_screw_count > 1) {
        translate([0,0,set_screw_z_mm])
            rotate([0,90,90])
                cylinder(r=set_screw_size/2 + tolerance_mm/2,
                         h=hub_diameter_mm + 2*eps_mm, center=true);
    }
}

// -------------------- Final assembly (ONE connected solid) --------------------
difference() {
    pulley_solid();
    pulley_cutouts();
}