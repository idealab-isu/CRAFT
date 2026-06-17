// Timing pulley: 10 teeth, 15.0mm pitch diameter
// One connected solid, visible external teeth, pitch diameter is the circle through tooth centers.

$fn = 200;

// Parameters
tooth_count = 10;                 //[5:40:1]
pitch_diameter_mm = 15.0;         //[7.5:30:0.1]
pulley_width_mm = 7;              //[4:20:0.5]
bore_diameter_mm = 5;             //[2:10:0.1]
hub_diameter_mm = 12;             //[8:24:0.5]
hub_length_mm = 10;               //[5:25:0.5]
flange_diameter_mm = 18;          //[14:30:0.5]
flange_thickness_mm = 1.5;        //[0.8:4:0.1]

// Tooth geometry (simple timing-pulley tooth form; tooth centerline lies on pitch circle)
tooth_radial_height_mm = 1.2;     //[0.4:2.5:0.05]  // radial protrusion beyond pitch circle
tooth_tangential_width_mm = 2.2;  //[0.6:4.0:0.05]  // tooth thickness around circumference
tooth_root_fillet_mm = 0.35;      //[0.1:1.2:0.05]  // rounding at tooth tip/root

// Connectivity / robustness
overlap_mm = 0.8;                 //[0.2:2:0.1]
eps_mm = 0.12;                    //[0.05:0.5:0.05]

// Derived
pitch_r = pitch_diameter_mm/2;

// Tooth radial extents (ensure tooth "center" is on pitch circle)
tooth_r_in  = pitch_r - tooth_radial_height_mm/2;
tooth_r_out = pitch_r + tooth_radial_height_mm/2;

// Root cylinder radius (solid under teeth; must reach into tooth base for a single connected solid)
root_r = max(tooth_r_in - overlap_mm, bore_diameter_mm/2 + 1.2);

// Total height for bore cut
total_h = max(hub_length_mm, pulley_width_mm + 2*flange_thickness_mm) + 4*eps_mm;

module tooth_2d() {
    // 2D tooth profile in XY, extruded along Z.
    // Built as a rounded rectangle spanning [tooth_r_in .. tooth_r_out] radially,
    // with tangential width = tooth_tangential_width_mm.
    // Overlaps into root cylinder by overlap_mm to guarantee union connectivity.
    w = tooth_tangential_width_mm;
    rin = tooth_r_in - overlap_mm;
    rout = tooth_r_out;
    len = max(0.01, rout - rin);
    rfil = min(tooth_root_fillet_mm, w/2 - 0.01, len/2 - 0.01);

    // Rounded rectangle via hull of 4 circles
    hull() {
        translate([rin + rfil,  w/2 - rfil]) circle(r=rfil, $fn=48);
        translate([rin + rfil, -w/2 + rfil]) circle(r=rfil, $fn=48);
        translate([rout - rfil,  w/2 - rfil]) circle(r=rfil, $fn=48);
        translate([rout - rfil, -w/2 + rfil]) circle(r=rfil, $fn=48);
    }
}

module teeth_ring() {
    linear_extrude(height=pulley_width_mm + 2*eps_mm, center=true, convexity=10)
        union() {
            for (i = [0:tooth_count-1])
                rotate(i*360/tooth_count)
                    tooth_2d();
        }
}

module pulley_body() {
    union() {
        // Root cylinder under teeth
        cylinder(r=root_r, h=pulley_width_mm, center=true);

        // Teeth (exactly tooth_count)
        teeth_ring();

        // Hub (overlaps pulley body)
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

        // Flanges (overlap into pulley body)
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
            cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
}

module pulley() {
    difference() {
        pulley_body();
        // Central bore through entire part
        cylinder(r=bore_diameter_mm/2, h=total_h, center=true);
    }
}

pulley();