// Timing pulley: 16 teeth, pitch diameter 9.75mm (pitch radius 4.875mm)
// Discrete outward belt teeth (trapezoid-ish) with correct tooth count and pitch circle.
// One connected solid (union) with bore removed (difference).

$fn = 220;

// -------------------- Parameters --------------------
tooth_count = 16;                 // requested
pitch_diameter_mm = 9.75;         // requested
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10;

// Tooth geometry (simple timing-pulley tooth approximation: trapezoid prism)
tooth_radial_height_mm = 1.25;    // protrusion beyond pitch radius
tooth_root_radial_mm   = 0.55;    // tooth depth below pitch radius (into body)
tooth_tip_width_mm     = 0.85;    // tangential width at tooth tip
tooth_root_width_mm    = 1.55;    // tangential width at tooth root (wider than tip)
tooth_overlap_mm       = 0.35;    // extra overlap into body to guarantee manifold union

// Body under teeth (root cylinder)
body_extra_under_root_mm = 0.25;  // ensures tooth roots are supported

bore_diameter_mm = 5;
hub_diameter_mm = 12;
hub_length_mm = 14;

flange_enabled = 1;
flange_diameter_mm = 16;
flange_thickness_mm = 1.5;

tolerance_mm = 0.2;
eps_mm = 0.05;

// -------------------- Derived --------------------
tooth_angle_deg = 360/tooth_count;

// Radii for tooth placement
r_pitch = pitch_radius_mm;
r_root  = r_pitch - tooth_root_radial_mm;
r_tip   = r_pitch + tooth_radial_height_mm;

// Ensure body supports tooth roots and overlaps for a single connected solid
body_radius_mm = r_root + body_extra_under_root_mm;

// Tooth center radius (so tooth spans from root to tip, with overlap into body)
tooth_radial_span_mm = (r_tip - r_root) + tooth_overlap_mm;
tooth_center_r_mm = r_root + tooth_radial_span_mm/2 - tooth_overlap_mm/2;

// -------------------- Modules --------------------
module tooth_profile_2d() {
    // Trapezoid centered on X axis, extruded along Z later.
    // X = radial direction, Y = tangential direction.
    polygon(points=[
        [-tooth_radial_span_mm/2, -tooth_root_width_mm/2],
        [-tooth_radial_span_mm/2,  tooth_root_width_mm/2],
        [ tooth_radial_span_mm/2,  tooth_tip_width_mm/2],
        [ tooth_radial_span_mm/2, -tooth_tip_width_mm/2]
    ]);
}

module tooth_3d() {
    // Place tooth so it protrudes outward and overlaps into body.
    translate([tooth_center_r_mm, 0, 0])
        linear_extrude(height=pulley_width_mm, center=true, convexity=10)
            tooth_profile_2d();
}

module teeth_ring() {
    for (i = [0:tooth_count-1])
        rotate([0, 0, i*tooth_angle_deg])
            tooth_3d();
}

module assembly() {
    difference() {
        union() {
            // Root body under teeth
            cylinder(r=body_radius_mm, h=pulley_width_mm, center=true);

            // Teeth
            teeth_ring();

            // Hub (overlaps body)
            cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

            // Flanges (connected with slight overlap)
            if (flange_enabled) {
                translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm)])
                    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
                translate([0, 0,  (pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm)])
                    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
            }
        }

        // Bore through entire part
        cylinder(r=(bore_diameter_mm + tolerance_mm)/2,
                 h=hub_length_mm + 2*pulley_width_mm + 2*flange_thickness_mm + 4,
                 center=true);
    }
}

assembly();