$fn=64;

// 608ZZ bearing typical dimensions
bearing_od = 22;
bearing_id = 8;
bearing_w  = 7;

// Press-fit parameters
press_interference = 0.20;          // positive makes bore smaller for press-fit
bore_d = bearing_od - press_interference;

// Housing geometry
wall = 3.0;                         // radial wall thickness around bearing
housing_od = bearing_od + 2*wall;    // outer diameter of main body
housing_w = bearing_w + 2.0;        // overall body thickness (axial)

// Flanges (front/back)
flange_th = 2.0;
flange_overhang = 4.0;              // radial overhang beyond housing_od/2
flange_od = housing_od + 2*flange_overhang;

// Lead-in chamfer (approximated with conical frustum)
lead_in_h = 1.0;
lead_in_extra = 1.0;                // increases entry diameter

// Mounting ears
ear_th = housing_w;                 // same as body thickness
ear_len = 14.0;                     // extension from body OD
ear_w  = 14.0;                      // tangential width of each ear
ear_hole_d = 4.2;                   // clearance for M4
ear_hole_offset = (housing_od/2) + ear_len*0.65;

// Optional lightening pocket
pocket_d = housing_od - 6.0;
pocket_depth = housing_w - 2.0;

module bearing_housing() {
    difference() {
        union() {
            // Main cylindrical body
            cylinder(d=housing_od, h=housing_w, center=true);

            // Front flange
            translate([0,0,(housing_w/2) + (flange_th/2)])
                cylinder(d=flange_od, h=flange_th, center=true);

            // Back flange
            translate([0,0,-(housing_w/2) - (flange_th/2)])
                cylinder(d=flange_od, h=flange_th, center=true);

            // Mounting ears (two opposite)
            for (a = [0,180]) {
                rotate([0,0,a])
                    translate([housing_od/2 + ear_len/2, 0, 0])
                        cube([ear_len, ear_w, ear_th], center=true);
            }
        }

        // Bearing bore (press-fit) through main body only
        cylinder(d=bore_d, h=housing_w + 0.2, center=true);

        // Lead-in on both sides (conical entry)
        translate([0,0,(housing_w/2) - (lead_in_h/2)])
            cylinder(h=lead_in_h, d1=bore_d + 2*lead_in_extra, d2=bore_d, center=true);
        translate([0,0,-(housing_w/2) + (lead_in_h/2)])
            cylinder(h=lead_in_h, d1=bore_d, d2=bore_d + 2*lead_in_extra, center=true);

        // Lightening pocket (does not break through)
        if (pocket_d > 0 && pocket_depth > 0) {
            translate([0,0,0])
                cylinder(d=pocket_d, h=pocket_depth, center=true);
        }

        // Mounting holes in ears
        for (a = [0,180]) {
            rotate([0,0,a])
                translate([ear_hole_offset, 0, 0])
                    cylinder(d=ear_hole_d, h=ear_th + 2, center=true);
        }
    }
}

bearing_housing();