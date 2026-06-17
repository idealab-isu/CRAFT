$fn = 220;

// Parameters (mm)
tooth_count      = 20;
pitch_diameter   = 12.22;   // required pitch diameter
belt_width       = 6;

bore_diameter    = 5;

hub_diameter     = 10;

flange_thickness = 1.5;
flange_diameter  = pitch_diameter + 4;

// Tooth geometry (simple visible timing-tooth approximation)
tooth_height     = 1.5;     // radial height above root
tooth_tip_width  = 0.6;     // tangential width at tip
tooth_root_width = 1.6;     // tangential width at root

// Derived
pitch_radius = pitch_diameter/2;

// Place tooth so its CENTERLINE (mid-height) lies on pitch circle:
// root_radius + tooth_height/2 = pitch_radius  => root_radius = pitch_radius - tooth_height/2
root_radius  = pitch_radius - tooth_height/2;

// Total pulley thickness including flanges
total_h = belt_width + 2*flange_thickness;

// Small overlaps for robust unions
z_overlap = 0.25;
r_overlap = 0.20;

// Single tooth as a prism extruded along Z.
// 2D polygon is defined in XY where +Y is radial outward.
module tooth_prism(h) {
    linear_extrude(height=h, center=true, convexity=10)
        polygon(points=[
            [-tooth_root_width/2, 0],
            [ tooth_root_width/2, 0],
            [ tooth_tip_width/2,  tooth_height],
            [-tooth_tip_width/2,  tooth_height]
        ]);
}

module teeth_ring(h) {
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*360/tooth_count])
            // Put tooth base at root_radius, and overlap slightly into the root cylinder
            translate([0, root_radius - r_overlap, 0])
                tooth_prism(h);
    }
}

module pulley() {
    difference() {
        union() {
            // Root cylinder under teeth (continuous ring)
            cylinder(h=belt_width, r=root_radius + r_overlap, center=true);

            // Teeth (protrude outward)
            teeth_ring(belt_width);

            // Flanges (connected to root cylinder with slight Z overlap)
            for (z = [-1, 1]) {
                translate([0,0, z*(belt_width/2 + flange_thickness/2 - z_overlap)])
                    cylinder(h=flange_thickness + 2*z_overlap, d=flange_diameter, center=true);
            }

            // Hub (spans full height so everything is one connected solid)
            cylinder(h=total_h, d=hub_diameter, center=true);
        }

        // Bore (subtracted)
        cylinder(h=total_h + 1, d=bore_diameter, center=true);
    }
}

pulley();