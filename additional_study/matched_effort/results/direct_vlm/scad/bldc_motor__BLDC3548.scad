$fn = 160;

// Brushless DC motor (outrunner-style)
// Requested: 35.0mm stator diameter, 45.0mm overall height
stator_d = 35.0;
motor_h  = 45.0;

// Small overlap to guarantee one connected solid
eps = 0.25;

// Can / rotor bell
can_wall = 1.2;
can_d    = stator_d + 2*can_wall;   // rotor bell OD derived from stator + wall
can_h    = motor_h * 0.78;
base_h   = motor_h - can_h;

// Shaft / hub
shaft_d  = 5.0;
shaft_h  = motor_h * 0.35;

top_hub_d = 12.0;
top_hub_h = 4.0;

// Base details
mount_boss_d = 18.0;
mount_boss_h = base_h * 0.55;

bolt_circle_d = 25.0;
bolt_d = 3.0;
bolt_head_d = 5.6;
bolt_head_h = 1.6;

wire_exit_w = 8.0;
wire_exit_h = 4.0;
wire_exit_len = 10.0;

// Visible BLDC details
stator_h = can_h - 2*can_wall;
stator_z0 = base_h + can_wall;

tooth_count = 12;
tooth_radial = 1.6;
tooth_tangential = 3.0;

magnet_count = 14;
magnet_radial = 1.2;
magnet_tangential = 3.0;

vent_count = 8;
vent_w = 3.0;
vent_h = can_h * 0.55;

// Add non-axisymmetric exterior features so orthographic side/front views are not a flat circle
rib_count = 6;
rib_w = 2.2;
rib_depth = 0.9;
rib_h = can_h * 0.85;

flat_w = can_d * 0.18;   // small flats on two sides
flat_depth = 0.8;

module bolt_hole(h){
    union(){
        cylinder(d=bolt_d, h=h);
        translate([0,0,h - bolt_head_h])
            cylinder(d=bolt_head_d, h=bolt_head_h);
    }
}

module stator_teeth(){
    union(){
        cylinder(d=stator_d, h=stator_h);
        for(i=[0:tooth_count-1]){
            rotate([0,0,i*360/tooth_count])
                translate([stator_d/2 + tooth_radial/2 - eps, 0, stator_h/2])
                    cube([tooth_radial, tooth_tangential, stator_h], center=true);
        }
    }
}

module rotor_magnets(){
    inner_d = can_d - 2*can_wall;
    r_in = inner_d/2;
    for(i=[0:magnet_count-1]){
        rotate([0,0,i*360/magnet_count])
            translate([r_in - magnet_radial/2 + eps, 0, can_h/2])
                cube([magnet_radial, magnet_tangential, can_h*0.75], center=true);
    }
}

module outer_ribs(){
    // Ribs protrude outward from can OD (non-axisymmetric silhouette)
    for(i=[0:rib_count-1]){
        rotate([0,0,i*360/rib_count])
            translate([can_d/2 + rib_depth/2 - eps, 0, rib_h/2])
                cube([rib_depth, rib_w, rib_h], center=true);
    }
}

module side_flats(){
    // Two small flats (subtractive) to break perfect circular outline in orthographic views
    for(a=[0,180]){
        rotate([0,0,a])
            translate([can_d/2 - flat_depth/2, 0, can_h/2])
                cube([flat_depth, flat_w, can_h + 2*eps], center=true);
    }
}

module motor(){
    union(){
        // Base/endbell with mounting pattern and wire exit notch
        difference(){
            cylinder(d=can_d*0.98, h=base_h);

            // bolt holes (4x) on bolt circle
            for(a=[0:90:270]){
                rotate([0,0,a])
                    translate([bolt_circle_d/2, 0, 0])
                        bolt_hole(base_h);
            }

            // wire exit notch (cuts from side into base)
            translate([can_d*0.49, 0, base_h*0.45])
                rotate([0,90,0])
                    cube([wire_exit_len, wire_exit_w, wire_exit_h], center=true);
        }

        // Mount boss (connected to base)
        cylinder(d=mount_boss_d, h=mount_boss_h);

        // Rotor bell (outer can) with vents, ribs, flats, and internal magnets
        translate([0,0,base_h - eps])
        difference(){
            union(){
                // Outer shell
                difference(){
                    cylinder(d=can_d, h=can_h + eps);
                    translate([0,0,can_wall])
                        cylinder(d=can_d - 2*can_wall, h=can_h + eps);
                }

                // Top rim/lip
                translate([0,0,can_h - 2.0])
                    cylinder(d=can_d, h=2.0 + eps);

                // Exterior ribs (add silhouette detail)
                outer_ribs();

                // Internal magnets (solid features)
                rotor_magnets();
            }

            // Side vents (slots) around the can
            for(i=[0:vent_count-1]){
                rotate([0,0,i*360/vent_count])
                    translate([can_d/2 - can_wall/2, 0, can_h*0.55])
                        cube([can_wall*2.2, vent_w, vent_h], center=true);
            }

            // Two flats to break circular outline in orthographic views
            side_flats();
        }

        // Stator with teeth (solid, connected via slight overlap into base region)
        translate([0,0,stator_z0 - eps])
            stator_teeth();

        // Top hub (connected to can top)
        translate([0,0,base_h + can_h - top_hub_h + eps])
            cylinder(d=top_hub_d, h=top_hub_h);

        // Shaft (connected to top hub)
        translate([0,0,base_h + can_h - eps])
            cylinder(d=shaft_d, h=shaft_h);
    }
}

motor();