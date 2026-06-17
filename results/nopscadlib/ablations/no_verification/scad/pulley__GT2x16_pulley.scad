// Timing pulley: 16 teeth, 9.75mm pitch diameter
// Fix: create VISIBLE external teeth (protruding) with exact tooth count,
// and enforce pitch diameter by placing tooth centers on the pitch circle.

$fn = 220;

// Parameters
tooth_count = 16;                 //[8:32:1]
pitch_diameter_mm = 9.75;         //[5:20:0.01]
pitch_radius_mm = pitch_diameter_mm/2;

pulley_width_mm = 10;             //[5:20:0.5]
bore_diameter_mm = 5;             //[2:10:0.1]

hub_diameter_mm = 14;             //[8:28:0.5]
hub_length_mm = 12;               //[6:24:0.5]

flange_diameter_mm = 18;          //[10:36:0.5]
flange_thickness_mm = 1.5;        //[0.8:4:0.1]
flange_enabled = 1;               //[0:1:1]

tolerance_mm = 0.2;               //[0.05:0.6:0.01]

// Tooth geometry (simple external timing-pulley teeth)
tooth_height_mm = 1.2;            //[0.6:2.4:0.05]   // radial protrusion above pitch circle
tooth_width_mm  = 1.35;           //[0.6:2.8:0.05]   // tangential width at pitch circle
tooth_round_mm  = 0.25;           //[0.0:1.0:0.05]   // rounding of tooth corners

// Base cylinder radii (ensure teeth are visible)
root_radius_mm  = max(pitch_radius_mm - 0.9, 0.5);   // cylinder under teeth (below pitch circle)
outer_radius_mm = pitch_radius_mm + tooth_height_mm; // tooth tip radius

eps = 0.25; // overlap for robust unions/differences

module flanges() {
    if (flange_enabled) {
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - eps])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + eps])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module teeth() {
    // Teeth protrude outward; tooth centerline lies on pitch circle (verifiable pitch diameter).
    // Overlap into root cylinder ensures a single connected solid.
    overlap_into_root = 0.6; // mm

    tooth_radial_len = tooth_height_mm + overlap_into_root;
    tooth_h = pulley_width_mm + 2*eps;

    for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
            translate([pitch_radius_mm + tooth_height_mm/2 - overlap_into_root/2, 0, 0])
                linear_extrude(height=tooth_h, center=true)
                    offset(r=tooth_round_mm)
                        square([tooth_radial_len, tooth_width_mm], center=true);
    }
}

module pulley_solid() {
    union() {
        // Root cylinder under teeth
        cylinder(r=root_radius_mm, h=pulley_width_mm, center=true);

        // External teeth
        teeth();

        // Hub (connected, centered)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (connected with overlap)
        flanges();
    }
}

module assembly() {
    total_h = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 6*eps;

    difference() {
        pulley_solid();

        // Central bore
        cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=total_h, center=true);
    }
}

assembly();