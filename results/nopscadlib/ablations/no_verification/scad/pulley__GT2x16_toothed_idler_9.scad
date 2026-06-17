// Timing pulley: 16 teeth, 9.75mm pitch diameter
// One connected solid (union of body+teeth+hub+flanges) with bore subtracted.

$fn = 220;

// Parameters
tooth_count = 16;                 //[8:64:1]
pitch_diameter_mm = 9.75;         //[5:20:0.05]
pulley_width_mm = 10;             //[5:30:1]
bore_diameter_mm = 5;             //[2:10:0.1]

// Tooth geometry (visible timing-tooth approximation)
tooth_radial_height_mm = 1.2;     //[0.6:2.5:0.05]   // protrusion above pitch circle
tooth_tangential_width_mm = 1.6;  //[0.8:3.5:0.05]   // tooth thickness around circumference
tooth_overlap_mm = 0.8;           //[0.3:2:0.05]     // sinks into body for strong union

// Body sizing
body_radial_clearance_mm = 0.6;   //[0.2:1.5:0.05]   // body radius below pitch circle
hub_diameter_mm = 14;             //[8:28:0.5]
hub_length_mm = 8;                //[0:25:1]
flange_diameter_mm = 16;          //[0:35:0.5]
flange_thickness_mm = 1.5;        //[0:5:0.1]

eps_mm = 0.2;                     //[0.05:1:0.05]

// Derived radii
pitch_r = pitch_diameter_mm/2;
body_r  = max(0.1, pitch_r - body_radial_clearance_mm);

// Tooth placement: ensure teeth are centered on the pitch circle (so pitch diameter is correct)
tooth_outer_r = pitch_r + tooth_radial_height_mm;
tooth_inner_r = max(0.1, pitch_r - tooth_overlap_mm);
tooth_len_r   = tooth_outer_r - tooth_inner_r;
tooth_center_r = (tooth_outer_r + tooth_inner_r)/2;

// Main solid (no bore)
module pulley_solid() {
    union() {
        // Base cylinder under teeth
        cylinder(h=pulley_width_mm, r=body_r, center=true);

        // Teeth: radial array, protruding outward and overlapping into body
        for (i = [0:tooth_count-1]) {
            rotate([0, 0, i*360/tooth_count])
                translate([tooth_center_r, 0, 0])
                    cube([tooth_len_r, tooth_tangential_width_mm, pulley_width_mm], center=true);
        }

        // Hub (connected with overlap)
        if (hub_length_mm > 0) {
            translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - eps_mm)])
                cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);
        }

        // Flanges (connected with overlap)
        if (flange_diameter_mm > 0 && flange_thickness_mm > 0) {
            translate([0, 0,  (pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm)])
                cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);

            translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm)])
                cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
        }
    }
}

// Final part with bore subtracted (still one connected solid)
difference() {
    pulley_solid();

    // Through bore (covers full height of pulley + hub + flanges)
    total_h = pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 6*eps_mm;
    cylinder(h=total_h, r=bore_diameter_mm/2, center=true);
}