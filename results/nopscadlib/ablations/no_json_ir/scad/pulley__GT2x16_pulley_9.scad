// Timing pulley: 16 teeth, 9.65mm pitch diameter
// One connected solid; all placements are formula-based.

$fn = 180;

// Parameters
teeth = 16;
pitch_diameter = 9.65;                 // mm (pitch circle diameter)
pitch_radius   = pitch_diameter/2;

belt_width = 6;                        // toothed section height (Z)

tooth_height = 1.2;                    // radial tooth protrusion above pitch radius
tooth_root_depth = 0.7;                // radial depth below pitch radius (forms valleys)
tooth_tip_arc_frac  = 0.42;            // fraction of tooth pitch used as tooth tip width (0..1)
tooth_root_arc_frac = 0.62;            // fraction of tooth pitch used as root/valley width (0..1)

center_bore_diameter = 5;              // shaft bore

hub_diameter = 12;                     // hub OD
hub_height = 10;                       // hub height (extends below toothed section)

flange_thickness = 1;                  // each flange thickness
flange_overhang = 2.0;                 // flange radial overhang beyond tooth OD

// Derived
pitch_circumference = PI * pitch_diameter;
tooth_pitch = pitch_circumference / teeth;          // arc length per tooth at pitch circle

tooth_tip_arc  = tooth_pitch * tooth_tip_arc_frac;
tooth_root_arc = tooth_pitch * tooth_root_arc_frac;

tooth_tip_angle  = (tooth_tip_arc  / pitch_radius) * 180 / PI;
tooth_root_angle = (tooth_root_arc / pitch_radius) * 180 / PI;

tooth_outer_radius = pitch_radius + tooth_height;
root_radius = max(0.2, pitch_radius - tooth_root_depth);

flange_diameter = 2 * (tooth_outer_radius + flange_overhang);

toothed_total_h = belt_width + 2*flange_thickness;
total_h = hub_height + toothed_total_h;

// Modules
module tooth_wedge() {
    // Tooth protrusion wedge (adds material)
    // Slightly overlaps into the pitch cylinder for robust union.
    inner_r = max(0.2, pitch_radius - 0.25);
    outer_r = tooth_outer_radius;

    rotate([0,0,-tooth_tip_angle/2])
        rotate_extrude(angle=tooth_tip_angle, $fn=max(16, ceil(tooth_tip_angle*3)))
            translate([inner_r, 0, 0])
                square([outer_r - inner_r, belt_width], center=false);
}

module root_slot() {
    // Valley/space between teeth (removes material)
    // Cuts from root_radius up to slightly beyond pitch_radius to create visible tooth profile.
    cut_inner_r = root_radius;
    cut_outer_r = pitch_radius + 0.15;

    rotate([0,0,-tooth_root_angle/2])
        rotate_extrude(angle=tooth_root_angle, $fn=max(16, ceil(tooth_root_angle*3)))
            translate([cut_inner_r, 0, 0])
                square([cut_outer_r - cut_inner_r, belt_width + 0.4], center=false);
}

module toothed_section() {
    // Build teeth as protrusions, then cut valleys to ensure clear tooth count/profile.
    difference() {
        union() {
            // Base cylinder to pitch radius
            cylinder(h=belt_width, r=pitch_radius, center=false, $fn=teeth*24);

            // Teeth protrusions
            for (i = [0:teeth-1])
                rotate([0,0,i*360/teeth])
                    tooth_wedge();
        }

        // Valleys between teeth (one per tooth pitch)
        for (i = [0:teeth-1])
            rotate([0,0,(i+0.5)*360/teeth])
                translate([0,0,-0.2])
                    root_slot();
    }
}

module pulley() {
    difference() {
        union() {
            // Hub (below toothed section) with overlap to ensure connectivity
            translate([0,0,-hub_height])
                cylinder(h=hub_height + 0.3, d=hub_diameter, center=false, $fn=180);

            // Toothed section
            translate([0,0,0])
                toothed_section();

            // Flanges (top and bottom), overlapping into toothed section
            translate([0,0,-flange_thickness + 0.25])
                cylinder(h=flange_thickness + 0.25, d=flange_diameter, center=false, $fn=180);

            translate([0,0,belt_width - 0.25])
                cylinder(h=flange_thickness + 0.25, d=flange_diameter, center=false, $fn=180);
        }

        // Center bore through entire part (extra length to guarantee cut)
        translate([0,0,-hub_height - 1])
            cylinder(h=total_h + 2, d=center_bore_diameter, center=false, $fn=120);
    }
}

// Render
pulley();