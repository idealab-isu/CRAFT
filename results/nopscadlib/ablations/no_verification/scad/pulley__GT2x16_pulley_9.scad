// Timing pulley: 16 teeth, 9.65mm pitch diameter
// Single connected solid (union of body + teeth) with bore and optional set-screw holes subtracted.

$fn = 200;

// -------------------- Parameters --------------------
tooth_count = 16;                 //[8:64:1]
pitch_diameter_mm = 9.65;         //[4.8:30:0.01]
pulley_width_mm = 7;              //[3.5:20:0.1]
bore_diameter_mm = 5;             //[2.5:12:0.01]

hub_diameter_mm = 12;             //[6:30:0.1]
hub_length_mm = 10;               //[5:30:0.1]

flange_diameter_mm = 14;          //[7:40:0.1]
flange_thickness_mm = 1.2;        //[0.6:4:0.05]
flanges_enabled = 1;              //[0:1:1]

set_screw_count = 1;              //[0:2:1]
set_screw_size = 3;               //[2:6:1]
set_screw_z_offset_mm = 5;        //[0:20:0.1]
set_screw_length_mm = 30;         //[15:80:1]

tolerance_mm = 0.2;               //[0:0.6:0.01]
overlap_mm = 0.8;                 //[0.5:2:0.1]

// Tooth geometry (printable approximation; pitch diameter is enforced)
tooth_radial_height_mm = 0.75;    //[0.3:2:0.01]
tooth_root_clearance_mm = 0.35;   //[0.1:1.2:0.01]
tooth_tip_round_mm = 0.35;        //[0.1:1.2:0.01]
tooth_fill = 0.55;                //[0.35:0.75:0.01]

// -------------------- Derived --------------------
pitch_r = pitch_diameter_mm/2;

// Ensure pitch diameter is exactly 9.65mm by centering tooth thickness about pitch circle.
// Root is below pitch by half tooth height + clearance; tip is above pitch by half tooth height + rounding.
root_r = pitch_r - (tooth_radial_height_mm/2 + tooth_root_clearance_mm);
tip_r  = pitch_r + (tooth_radial_height_mm/2 + tooth_tip_round_mm);

tooth_pitch_deg = 360/tooth_count;
tooth_ang_deg = tooth_pitch_deg * tooth_fill;

// Tooth axial margins (avoid touching flanges if enabled)
axial_margin = (flanges_enabled ? max(0.2, flange_thickness_mm*0.35) : 0);
tooth_h = max(0.1, pulley_width_mm - 2*axial_margin);

// -------------------- Modules --------------------
module tooth_wedge() {
    // Single tooth as an annular sector extruded along Z.
    linear_extrude(height=tooth_h, center=true)
        polygon(points=[
            [root_r*cos(-tooth_ang_deg/2), root_r*sin(-tooth_ang_deg/2)],
            [tip_r*cos(-tooth_ang_deg/2),  tip_r*sin(-tooth_ang_deg/2)],
            [tip_r*cos( tooth_ang_deg/2),  tip_r*sin( tooth_ang_deg/2)],
            [root_r*cos( tooth_ang_deg/2), root_r*sin( tooth_ang_deg/2)]
        ]);
}

module teeth_ring() {
    for (i = [0:tooth_count-1])
        rotate([0,0,i*tooth_pitch_deg])
            tooth_wedge();
}

module pulley_solid() {
    union() {
        // Main toothed barrel at root radius
        cylinder(h=pulley_width_mm, r=root_r, center=true);

        // Teeth (connected by construction; root_r is inside barrel)
        teeth_ring();

        // Hub (connected to barrel with overlap)
        translate([0, 0, -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm])
            cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);

        // Flanges (connected with overlap)
        if (flanges_enabled) {
            translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
                cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
            translate([0, 0,  pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
                cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
        }
    }
}

module bore_and_set_screws() {
    // Through bore
    total_h = pulley_width_mm + hub_length_mm + (flanges_enabled ? 2*flange_thickness_mm : 0) + 4;
    cylinder(h=total_h, r=bore_diameter_mm/2 + tolerance_mm/2, center=true);

    // Set screw holes (radial), placed through hub region
    if (set_screw_count > 0) {
        z_hub_center = -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm;
        // Clamp offset into hub length so it always intersects the hub
        z_local = min(max(set_screw_z_offset_mm, 0), hub_length_mm);

        for (k = [0:set_screw_count-1]) {
            rotate([0,0,k*(180/set_screw_count)])
                translate([0,0, z_hub_center - hub_length_mm/2 + z_local])
                    rotate([0,90,0])
                        cylinder(h=hub_diameter_mm + 6,
                                 r=set_screw_size/2 + tolerance_mm/2,
                                 center=true);
        }
    }
}

// -------------------- Assembly --------------------
difference() {
    pulley_solid();
    bore_and_set_screws();
}