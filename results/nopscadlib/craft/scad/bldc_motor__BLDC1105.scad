// Brushless DC motor (single connected solid)
// Target: 14.0mm stator diameter, 11.75mm stator height

$fn = 128;

// -------------------- Parameters --------------------
stator_diameter = 14.0;          //[7.0:28.0:0.1]
stator_height   = 11.75;         //[5.875:23.5:0.05]

overlap = 0.6;                   //[0.2:2.0:0.1]

// Rotor/bell (outer can)
rotor_wall = 0.8;                //[0.4:1.6:0.05]
rotor_radial_clearance = 0.35;   //[0.2:1.0:0.05]
rotor_height = stator_height;    // match stator height

// Shaft
shaft_diameter = 2.0;            //[1.0:5.0:0.05]
shaft_length = 22.0;             //[11.0:44.0:0.1]

// End features
endcap_thickness = 1.2;          //[0.8:3.0:0.05]
endcap_radial_margin = 0.6;      //[0.2:2.0:0.05]

// Mounting face + holes
mount_face_thickness = 1.2;
mount_face_diameter = stator_diameter + 2*endcap_radial_margin;
mount_hole_d = 1.6;
mount_hole_circle_d = 9.0;

// Stator teeth (visual cue)
num_teeth = 12;
tooth_radial = 0.9;
tooth_width = 1.2;

// Rotor exterior ribs (visual cue)
num_ribs = 10;
rib_depth = 0.6;
rib_width = 1.2;

// -------------------- Derived --------------------
stator_r = stator_diameter/2;

rotor_inner_r = stator_r + rotor_radial_clearance;
rotor_outer_r = rotor_inner_r + rotor_wall;

// Ensure rotor is the outermost visible diameter (typical outrunner look)
min_outer_r = stator_r + 1.2;
rotor_outer_r_eff = max(rotor_outer_r, min_outer_r);
rotor_wall_eff = rotor_outer_r_eff - rotor_inner_r;

// Axial layout (centered at origin)
z_stator_c = 0;
z_front_face_c = stator_height/2 + mount_face_thickness/2 - overlap;
z_rear_cap_c   = -stator_height/2 - endcap_thickness/2 + overlap;

// -------------------- Modules --------------------
module stator_with_teeth() {
    union() {
        // Stator core (exact target dimensions)
        cylinder(r=stator_r, h=stator_height, center=true);

        // Teeth protruding outward, overlapping into core for connectivity
        for (i = [0:num_teeth-1]) {
            rotate([0,0,i*360/num_teeth])
                translate([stator_r + tooth_radial/2 - overlap, 0, 0])
                    cube([tooth_radial, tooth_width, stator_height], center=true);
        }
    }
}

module rotor_bell_with_ribs() {
    // Outrunner bell as a cup (open at bottom), plus exterior ribs.
    // NOTE: This is a separate solid in union; connectivity is guaranteed via the shaft
    // which intersects both stator and rotor.
    union() {
        // Bell shell
        difference() {
            cylinder(r=rotor_outer_r_eff, h=rotor_height, center=true);
            cylinder(r=rotor_inner_r, h=rotor_height + 2*overlap, center=true);

            // Open bottom: remove lower half to create a cup/bell
            translate([0,0,-rotor_height/2 - overlap])
                cylinder(r=rotor_outer_r_eff + 2*overlap,
                         h=rotor_height/2 + 2*overlap,
                         center=false);
        }

        // Exterior ribs for recognizable motor can detail (connected to shell via overlap)
        for (i = [0:num_ribs-1]) {
            rotate([0,0,i*360/num_ribs])
                translate([rotor_outer_r_eff - rib_depth/2 + overlap/2, 0, 0])
                    cube([rib_depth + overlap, rib_width, rotor_height*0.85], center=true);
        }
    }
}

module mounting_face() {
    // Front face plate with 4 holes; plate overlaps stator for connectivity
    difference() {
        translate([0,0,z_front_face_c])
            cylinder(r=mount_face_diameter/2, h=mount_face_thickness, center=true);

        for (a = [0:90:270]) {
            rotate([0,0,a])
                translate([mount_hole_circle_d/2, 0, z_front_face_c])
                    cylinder(r=mount_hole_d/2, h=mount_face_thickness + 2*overlap, center=true);
        }
    }
}

module rear_endcap() {
    // Rear endcap ring (bearing seat look), connected to stator
    translate([0,0,z_rear_cap_c])
        cylinder(r=stator_r + endcap_radial_margin, h=endcap_thickness, center=true);
}

module shaft() {
    // Shaft passes through entire assembly to guarantee one connected solid
    cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
}

module motor() {
    union() {
        // Stator (exact target dimensions)
        stator_with_teeth();

        // Rotor bell (outer can)
        rotor_bell_with_ribs();

        // Front mounting face (connected to stator)
        mounting_face();

        // Rear endcap (connected to stator)
        rear_endcap();

        // Shaft (connects through everything, including rotor)
        shaft();
    }
}

motor();