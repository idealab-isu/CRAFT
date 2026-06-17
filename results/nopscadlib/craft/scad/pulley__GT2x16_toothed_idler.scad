// Timing pulley: 16 teeth, 9.75mm pitch diameter (pitch circle)
// One connected solid (union) with bore removed (difference)

$fn = 220;

// Parameters
tooth_count = 16;                 //[8:64:1]
pitch_diameter_mm = 9.75;         //[6:20:0.05]
pulley_width_mm = 10;             //[5:30:1]
bore_diameter_mm = 5;             //[2:10:0.1]
hub_diameter_mm = 12;             //[8:24:0.5]
hub_length_mm = 14;               //[8:30:1]
flange_diameter_mm = 16;          //[10:32:0.5]
flange_thickness_mm = 1.5;        //[0.8:4:0.1]

// Tooth geometry (printable approximation)
tooth_radial_height_mm = 1.2;     //[0.6:2.5:0.05]  // protrusion beyond pitch circle
tooth_tangential_width_mm = 1.0;  //[0.5:2.0:0.05]  // tooth thickness around circumference
tooth_root_clearance_mm = 0.4;    //[0.1:1.0:0.05]  // root sits inside pitch circle
tooth_overlap_mm = 0.8;           //[0.3:2.0:0.05]  // overlap into root cylinder for watertight union
connection_overlap_mm = 0.8;      //[0.3:2.0:0.05]

// Derived
pitch_radius_mm = pitch_diameter_mm/2;
tooth_root_radius_mm = pitch_radius_mm - tooth_root_clearance_mm;
tooth_outer_radius_mm = pitch_radius_mm + tooth_radial_height_mm;

// Root cylinder must not be hidden by a larger smooth cylinder.
// Ensure hub is connected but does not cover teeth: hub is limited to root radius.
hub_radius_mm = min(hub_diameter_mm/2, tooth_root_radius_mm - 0.01);

// Flanges should not cover teeth either; keep them at/under tooth outer radius.
flange_radius_mm = min(flange_diameter_mm/2, tooth_outer_radius_mm);

// Toothed belt section (root cylinder + radial array teeth)
module timing_teeth_section() {
    union() {
        // Root cylinder (inside pitch circle)
        cylinder(h=pulley_width_mm, r=tooth_root_radius_mm, center=true);

        // Teeth: protrude outward beyond pitch circle, overlap into root cylinder
        for (i = [0:tooth_count-1]) {
            rotate([0, 0, i*360/tooth_count])
                translate([
                    tooth_root_radius_mm + tooth_radial_height_mm/2 - tooth_overlap_mm/2,
                    0,
                    0
                ])
                    cube(
                        [tooth_radial_height_mm + tooth_overlap_mm, tooth_tangential_width_mm, pulley_width_mm],
                        center=true
                    );
        }
    }
}

// Main pulley solid, then subtract bore
module pulley_solid() {
    difference() {
        union() {
            // Toothed section (centered)
            timing_teeth_section();

            // Hub: connect through full length, but do not cover teeth radially
            cylinder(h=hub_length_mm, r=hub_radius_mm, center=true);

            // Flanges: placed at ends of toothed width, with overlap for connectivity
            translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm])
                cylinder(h=flange_thickness_mm, r=flange_radius_mm, center=true);

            translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + connection_overlap_mm])
                cylinder(h=flange_thickness_mm, r=flange_radius_mm, center=true);
        }

        // Bore hole through entire part
        cylinder(
            h=max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 4*connection_overlap_mm,
            r=bore_diameter_mm/2,
            center=true
        );
    }
}

pulley_solid();