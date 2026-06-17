$fn = 220;

// Parameters (mm)
teeth            = 10;
pitch_diameter   = 15.0;   // MUST be 15.0mm
belt_width       = 6.0;
bore_diameter    = 5.0;

hub_diameter     = 20.0;
hub_length       = 10.0;

flange_thickness = 1.5;
flange_diameter  = 25.0;

set_screw_diameter = 3.0;
set_screw_distance = 7.5;

// Tooth shaping (simple, clearly visible teeth)
tooth_height     = 1.6;     // radial tooth height above pitch circle
tooth_land_frac  = 0.45;    // fraction of pitch occupied by tooth at pitch circle
tooth_tip_frac   = 0.25;    // fraction of pitch at tooth tip (smaller -> more trapezoid)
root_clearance   = 0.15;    // small extra depth for clean valleys

// Derived
pitch_r      = pitch_diameter/2;
tooth_pitch  = PI * pitch_diameter / teeth;     // arc length per tooth at pitch circle

land_arc     = tooth_pitch * tooth_land_frac;
tip_arc      = tooth_pitch * tooth_tip_frac;

land_ang     = land_arc / pitch_r * 180/PI;
tip_ang      = tip_arc  / pitch_r * 180/PI;

outer_r      = pitch_r + tooth_height;          // tooth tip radius
root_r       = pitch_r - tooth_height;          // valley/root radius

overlap      = 0.25;                            // boolean overlap

module pulley() {
    difference() {
        union() {
            // Toothed ring (teeth protrude outward)
            toothed_body();

            // Hub on +Z side, connected with overlap
            translate([0, 0, belt_width/2 + hub_length/2 - overlap])
                cylinder(h=hub_length, r=hub_diameter/2, center=true);

            // Flanges (top and bottom), connected with overlap
            translate([0, 0,  belt_width/2 + flange_thickness/2 - overlap])
                cylinder(h=flange_thickness, r=flange_diameter/2, center=true);

            translate([0, 0, -belt_width/2 - flange_thickness/2 + overlap])
                cylinder(h=flange_thickness, r=flange_diameter/2, center=true);
        }

        // Center bore through entire part
        cylinder(h=belt_width + hub_length + 2*flange_thickness + 4, r=bore_diameter/2, center=true);

        // Set screw holes (two, 180° apart) through hub wall
        for (a = [0, 180]) {
            rotate([0, 0, a])
                translate([set_screw_distance, 0, belt_width/2 + hub_length/2 - overlap])
                    rotate([90, 0, 0])
                        cylinder(h=hub_diameter + 4, r=set_screw_diameter/2, center=true);
        }
    }
}

// Build a clearly-toothed pulley body by unioning a root cylinder + trapezoid teeth
module toothed_body() {
    union() {
        // Root cylinder (valley diameter)
        cylinder(h=belt_width, r=root_r - root_clearance, center=true);

        // Teeth
        for (i = [0:teeth-1]) {
            rotate([0, 0, i*360/teeth])
                tooth();
        }
    }
}

// One tooth as a trapezoid sector (rotate_extrude of a 2D trapezoid in r-z plane)
module tooth() {
    // Tooth centered on its angular slot
    rotate([0, 0, -land_ang/2])
        rotate_extrude(angle=land_ang, convexity=10)
            polygon(points=[
                // r, z (z spans belt width)
                [root_r - root_clearance, -belt_width/2],
                [outer_r,               -belt_width/2],
                [outer_r,                belt_width/2],
                [root_r - root_clearance, belt_width/2]
            ]);

    // Trim tooth to a narrower tip by subtracting side wedges (forms trapezoid in angle)
    // Implemented by intersecting with a tip sector + root sector blend
    // (done as intersection to avoid floating parts)
    intersection() {
        // The raw tooth volume (same as above)
        rotate([0, 0, -land_ang/2])
            rotate_extrude(angle=land_ang, convexity=10)
                polygon(points=[
                    [root_r - root_clearance, -belt_width/2],
                    [outer_r,               -belt_width/2],
                    [outer_r,                belt_width/2],
                    [root_r - root_clearance, belt_width/2]
                ]);

        // Angular limiter that narrows at the tip: hull between a wide root sector and narrow tip sector
        hull() {
            // Wide at root
            rotate([0, 0, -land_ang/2])
                rotate_extrude(angle=land_ang, convexity=10)
                    translate([root_r - root_clearance, 0, 0])
                        square([0.01, belt_width], center=true);

            // Narrow at tip
            rotate([0, 0, -tip_ang/2])
                rotate_extrude(angle=tip_ang, convexity=10)
                    translate([outer_r, 0, 0])
                        square([0.01, belt_width], center=true);
        }
    }
}

pulley();