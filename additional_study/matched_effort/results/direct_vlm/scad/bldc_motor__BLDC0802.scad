$fn = 128;

// Brushless DC motor (mini outrunner-style, simplified but recognizable)
// Requirements:
// - Stator diameter = 11.5mm (exact)
// - Stator height   = 9.5mm  (exact)
// - ONE connected solid (all parts fused via small overlaps)
// - No arbitrary translate values: all placements derived from dimensions

stator_d = 11.5;
stator_h = 9.5;

// Clear BLDC features (simplified):
// - Stator ring with teeth
// - Rotor bell/can with top cap and open bottom
// - Base plate with mounting holes
// - Central shaft
// - Three wires exiting from side

air_gap     = 0.35;
can_wall    = 0.6;
can_overhang= 0.8;

can_id = stator_d + 2*air_gap;
can_od = can_id + 2*can_wall;
can_h  = stator_h + 2*can_overhang;

base_h   = 1.2;
topcap_h = 0.8;

shaft_d     = 2.0;
shaft_above = 10;
shaft_below = 2;

wire_d       = 0.8;
wire_len     = 18;
wire_spacing = 1.4;

eps     = 0.02;
overlap = 0.25;

// --- helpers ---
module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=false);
        translate([0,0,-eps]) cylinder(d=id, h=h+2*eps, center=false);
    }
}

// --- stator with teeth (recognizable) ---
module stator(){
    bore_d = max(shaft_d + 0.6, 3.0);

    tooth_count = 12;
    tooth_radial = 0.9;                 // protrusion outward from stator OD
    tooth_w = (stator_d*PI/tooth_count) * 0.45; // tangential width
    tooth_h = stator_h;

    union(){
        // main stator ring (exact OD = stator_d, exact height = stator_h)
        ring(od=stator_d, id=bore_d, h=stator_h);

        // teeth: protrude outward and overlap into ring for connectivity
        for(i=[0:tooth_count-1]){
            rotate([0,0,i*360/tooth_count])
                translate([stator_d/2 + tooth_radial/2 - overlap, 0, 0])
                    cube([tooth_radial, tooth_w, tooth_h], center=false);
        }
    }
}

// --- rotor bell/can (cup) with simple outer ribs for recognizability ---
module rotor_can(){
    rib_count = 10;
    rib_w = 0.7;
    rib_depth = 0.5;

    difference(){
        union(){
            // outer wall
            ring(od=can_od, id=can_id, h=can_h);

            // top cap
            translate([0,0,can_h-topcap_h])
                cylinder(d=can_od, h=topcap_h, center=false);

            // external ribs (fused to can wall)
            for(i=[0:rib_count-1]){
                rotate([0,0,i*360/rib_count])
                    translate([can_od/2 - rib_depth/2, 0, 0])
                        cube([rib_depth, rib_w, can_h-topcap_h], center=false);
            }
        }

        // hollow interior (open bottom)
        translate([0,0,eps])
            cylinder(d=can_id, h=can_h-topcap_h+2*eps, center=false);
    }
}

// --- base plate with mounting holes (holes are fine; solid remains connected) ---
module base(){
    base_d = can_od - 0.6;

    difference(){
        cylinder(d=base_d, h=base_h, center=false);

        // shaft clearance hole
        translate([0,0,-eps])
            cylinder(d=shaft_d+0.4, h=base_h+2*eps, center=false);

        // 3 mounting holes
        mount_r = base_d*0.32;
        hole_d = 1.2;
        for(a=[0:120:240]){
            translate([mount_r*cos(a), mount_r*sin(a), -eps])
                cylinder(d=hole_d, h=base_h+2*eps, center=false);
        }
    }
}

// --- shaft (single solid rod through assembly) ---
module shaft(){
    z0 = -shaft_below;
    total_h = shaft_below + base_h + can_h + shaft_above;
    translate([0,0,z0])
        cylinder(d=shaft_d, h=total_h, center=false);
}

// --- wires (fused into can wall) ---
module wires(){
    // exit near base, from side; pushed slightly into can for guaranteed connection
    exit_z = base_h*0.6;
    exit_r = (can_od/2) - overlap;

    for(i=[-1,0,1]){
        translate([exit_r, i*wire_spacing, exit_z])
            rotate([0,90,0])
                cylinder(d=wire_d, h=wire_len, center=false);
    }
}

// --- assembly (ONE connected solid) ---
module motor(){
    union(){
        // Base at z=[0..base_h]
        base();

        // Can overlaps base slightly for connectivity
        translate([0,0,base_h - can_overhang - overlap])
            rotor_can();

        // Stator placed inside can; exact dimensions preserved
        translate([0,0,base_h])
            stator();

        // Shaft through everything
        shaft();

        // Wires fused into can
        wires();
    }
}

motor();