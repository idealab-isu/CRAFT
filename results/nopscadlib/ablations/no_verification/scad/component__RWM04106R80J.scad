$fn = 96;

// Vitreous enamel wirewound resistor (axial) - single connected solid
// No text/labels per requirements

// Parameters
resistance_ohms = 6.8; //[3.4:13.6:0.1]
power_w = 3; //[1.5:6:0.5]

body_length_mm = 18; //[9:36:0.5]
body_diameter_mm = 6; //[3:12:0.1]

end_cap_length_mm = 1.6; //[0.75:3:0.1]
end_cap_diameter_mm = 6.2; //[3:13:0.1]   // slightly larger than body

lead_diameter_mm = 0.8; //[0.4:1.6:0.05]
lead_length_each_side_mm = 25; //[12.5:50:1]

lead_exit_boss_length_mm = 1.2; //[0.4:2.5:0.05]
lead_exit_boss_diameter_mm = 2.0; //[0.8:3.2:0.05]

fillet_radius_mm = 0.6; //[0.25:1.2:0.05]
overlap_mm = 0.6; //[0.2:2:0.1]

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module axial_vitreous_resistor() {
    // Derived dimensions
    body_r = body_diameter_mm/2;
    cap_r  = end_cap_diameter_mm/2;
    boss_r = lead_exit_boss_diameter_mm/2;
    lead_r = lead_diameter_mm/2;

    // Keep fillet sane
    fr = clamp(fillet_radius_mm, 0.05, min(body_r*0.45, end_cap_length_mm*0.9));

    // Axial positions along X
    body_half = body_length_mm/2;

    cap_center_left  = -(body_half - end_cap_length_mm/2);
    cap_center_right = +(body_half - end_cap_length_mm/2);

    // Bosses sit just outside the body, overlapping into end caps
    boss_center_left  = -(body_half + lead_exit_boss_length_mm/2 - overlap_mm);
    boss_center_right = +(body_half + lead_exit_boss_length_mm/2 - overlap_mm);

    // Leads start at boss outer face and extend outward
    lead_center_left  = -(body_half + lead_exit_boss_length_mm - overlap_mm + lead_length_each_side_mm/2);
    lead_center_right = +(body_half + lead_exit_boss_length_mm - overlap_mm + lead_length_each_side_mm/2);

    union() {
        // Main ceramic body (cylindrical)
        rotate([0,90,0])
            cylinder(r=body_r, h=body_length_mm, center=true);

        // End caps (slightly larger diameter)
        translate([cap_center_left, 0, 0])
            rotate([0,90,0])
                cylinder(r=cap_r, h=end_cap_length_mm, center=true);

        translate([cap_center_right, 0, 0])
            rotate([0,90,0])
                cylinder(r=cap_r, h=end_cap_length_mm, center=true);

        // Gentle shoulder/fillet at body ends (adds typical rounded transition)
        // Implemented as a short hull between two rings to avoid fragile rotate_extrude placement.
        for (s = [-1, 1]) {
            x0 = s*(body_half - fr);
            x1 = s*(body_half - end_cap_length_mm + fr);

            hull() {
                translate([x0, 0, 0])
                    rotate([0,90,0])
                        cylinder(r=body_r, h=0.2, center=true);
                translate([x1, 0, 0])
                    rotate([0,90,0])
                        cylinder(r=cap_r, h=0.2, center=true);
            }
        }

        // Lead exit bosses (small collars)
        translate([boss_center_left, 0, 0])
            rotate([0,90,0])
                cylinder(r=boss_r, h=lead_exit_boss_length_mm, center=true);

        translate([boss_center_right, 0, 0])
            rotate([0,90,0])
                cylinder(r=boss_r, h=lead_exit_boss_length_mm, center=true);

        // Leads (axial wires) - overlap into bosses for watertight union
        translate([lead_center_left, 0, 0])
            rotate([0,90,0])
                cylinder(r=lead_r, h=lead_length_each_side_mm + overlap_mm, center=true);

        translate([lead_center_right, 0, 0])
            rotate([0,90,0])
                cylinder(r=lead_r, h=lead_length_each_side_mm + overlap_mm, center=true);
    }
}

// Single connected solid output
axial_vitreous_resistor();