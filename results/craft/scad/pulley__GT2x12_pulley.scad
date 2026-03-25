$fn = 180;

// Target: timing pulley with 12 teeth and 7.15mm pitch diameter
tooth_count         = 12;
pitch_diameter_mm   = 7.15;
pitch_radius_mm     = pitch_diameter_mm/2;

pulley_width        = 8;

hub_diameter        = 12;
hub_length          = 10;

bore_diameter       = 5;

flange_diameter     = 14;
flange_thickness    = 1.5;

// Tooth geometry (simple rectangular teeth for visibility)
tooth_radial_height     = 1.2;   // outward from pitch circle
tooth_tangential_width  = 1.6;   // width around circumference
tooth_overlap           = 0.9;   // overlaps into rim for solid union

connect_overlap     = 0.6;
eps                 = 0.05;

// Derived radii
tooth_outer_radius  = pitch_radius_mm + tooth_radial_height;
tooth_inner_radius  = pitch_radius_mm - tooth_overlap;

// Rim radius must reach tooth_inner_radius so teeth are not "floating"
rim_radius = max(tooth_inner_radius + connect_overlap, pitch_radius_mm + connect_overlap);

// Teeth as blocks, radially arrayed, protruding outward and overlapping into rim
module timing_teeth() {
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*360/tooth_count])
            translate([pitch_radius_mm + tooth_radial_height/2 - tooth_overlap, 0, 0])
                cube([tooth_radial_height + tooth_overlap, tooth_tangential_width, pulley_width], center=true);
    }
}

module pulley_solid() {
    union() {
        // Base rim (up to at least tooth_inner_radius)
        cylinder(r=rim_radius, h=pulley_width, center=true);

        // Teeth
        timing_teeth();

        // Hub (centered, overlaps rim)
        cylinder(r=hub_diameter/2, h=hub_length, center=true);

        // Flanges (connected to rim)
        translate([0,0, pulley_width/2 + flange_thickness/2 - connect_overlap])
            cylinder(r=flange_diameter/2, h=flange_thickness, center=true);

        translate([0,0,-pulley_width/2 - flange_thickness/2 + connect_overlap])
            cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
    }
}

difference() {
    pulley_solid();

    // Bore through entire part
    cylinder(
        r=bore_diameter/2,
        h=hub_length + pulley_width + 2*flange_thickness + 4*eps,
        center=true
    );
}