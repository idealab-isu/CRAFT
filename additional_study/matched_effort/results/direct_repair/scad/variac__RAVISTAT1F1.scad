$fn=96;

// RAVISTAT 1F-1 variac (approximate visual model)
// Units: mm

// ---------- Parameters ----------
base_w = 165;
base_d = 135;
base_h = 55;

top_plate_h = 3;

corner_r = 10;

front_panel_h = 40;
front_panel_t = 3;

knob_d = 70;
knob_h = 22;
knob_skirt_h = 6;

dial_d = 92;
dial_t = 2.2;

shaft_d = 10;
shaft_h = 18;

handle_w = 18;
handle_l = 28;
handle_t = 10;

vent_slot_w = 3;
vent_slot_l = 22;
vent_rows = 2;
vent_cols = 10;
vent_pitch_x = 7;
vent_pitch_y = 10;

foot_d = 14;
foot_h = 4;

label_w = 70;
label_h = 18;
label_t = 0.8;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2) {
    // Minkowski rounded rectangular prism
    sx = size[0]; sy = size[1]; sz = size[2];
    minkowski() {
        cube([sx-2*r, sy-2*r, sz-2*r], center=true);
        sphere(r=r);
    }
}

module screw_boss(d=10, h=10, hole_d=3.2) {
    difference() {
        cylinder(d=d, h=h);
        translate([0,0,-0.1]) cylinder(d=hole_d, h=h+0.2);
    }
}

module knurl_ring(d=70, h=10, teeth=48, depth=1.2) {
    // Simple knurl approximation by subtracting small cylinders around perimeter
    difference() {
        cylinder(d=d, h=h);
        for(i=[0:teeth-1]) {
            a = 360*i/teeth;
            rotate([0,0,a])
                translate([d/2 - depth/2,0,h/2])
                    rotate([90,0,0])
                        cylinder(d=depth, h=depth*2, center=true);
        }
    }
}

module dial_face(d=92, t=2.2) {
    // Dial disk with tick marks engraved
    difference() {
        cylinder(d=d, h=t);
        // center hole
        translate([0,0,-0.1]) cylinder(d=shaft_d+1.5, h=t+0.2);
        // ticks
        for(i=[0:50]) {
            a = 270*i/50 - 225; // sweep ~270 degrees
            len = (i%5==0) ? 10 : 6;
            w = (i%5==0) ? 1.2 : 0.8;
            rotate([0,0,a])
                translate([d/2 - 6 - len/2, 0, t/2])
                    cube([len, w, t+0.4], center=true);
        }
        // pointer notch at top
        rotate([0,0,0])
            translate([d/2 - 4, 0, t/2])
                cube([10, 2.2, t+0.4], center=true);
    }
}

module vent_grid(area_w, area_h, z0, inset=8) {
    // Cut vent slots on top surface
    start_x = -area_w/2 + inset;
    start_y = -area_h/2 + inset;
    for(r=[0:vent_rows-1]) for(c=[0:vent_cols-1]) {
        x = start_x + c*vent_pitch_x;
        y = start_y + r*vent_pitch_y;
        translate([x, y, z0])
            cube([vent_slot_l, vent_slot_w, 10], center=true);
    }
}

module feet() {
    for(sx=[-1,1], sy=[-1,1]) {
        translate([sx*(base_w/2 - 18), sy*(base_d/2 - 18), -base_h/2 - foot_h])
            cylinder(d=foot_d, h=foot_h);
    }
}

module front_label() {
    translate([0, base_d/2 + front_panel_t/2 + 0.01, -base_h/2 + front_panel_h/2 + 8])
        cube([label_w, front_panel_t+0.02, label_h], center=true);
}

// ---------- Main Body ----------
module variac_body() {
    difference() {
        // Outer shell
        translate([0,0,0])
            rounded_box([base_w, base_d, base_h], r=corner_r);

        // Hollow interior
        translate([0,0,2])
            rounded_box([base_w-6, base_d-6, base_h-6], r=max(1,corner_r-3));

        // Top vents
        translate([0,0, base_h/2 - top_plate_h/2])
            vent_grid(base_w, base_d, 0, inset=18);

        // Front panel recess
        translate([0, base_d/2 - 1.5, -base_h/2 + front_panel_h/2 + 6])
            cube([base_w-20, 6, front_panel_h], center=true);

        // Side cable grommet hole (right side)
        translate([base_w/2 - 2, -10, -base_h/2 + 18])
            rotate([0,90,0])
                cylinder(d=14, h=10, center=true);

        // Bottom screw holes (approx)
        for(sx=[-1,1], sy=[-1,1]) {
            translate([sx*(base_w/2 - 22), sy*(base_d/2 - 22), -base_h/2 - 0.1])
                cylinder(d=4, h=8);
        }
    }

    // Feet
    feet();

    // Front panel plate
    translate([0, base_d/2 + front_panel_t/2, -base_h/2 + front_panel_h/2 + 6])
        cube([base_w-18, front_panel_t, front_panel_h], center=true);

    // Label plaque (raised)
    translate([0, base_d/2 + front_panel_t + label_t/2, -base_h/2 + front_panel_h/2 + 6])
        cube([label_w, label_t, label_h], center=true);

    // Small bosses inside (visual)
    for(sx=[-1,1], sy=[-1,1]) {
        translate([sx*(base_w/2 - 25), sy*(base_d/2 - 25), -base_h/2 + 6])
            screw_boss(d=12, h=10, hole_d=3.2);
    }
}

// ---------- Knob Assembly ----------
module knob_assembly() {
    // Position on top, slightly forward
    knob_z = base_h/2 + 0.5;
    knob_y = 10;

    // Dial
    translate([0, knob_y, knob_z])
        color("gainsboro")
            dial_face(d=dial_d, t=dial_t);

    // Knob body
    translate([0, knob_y, knob_z + dial_t])
        color("dimgray")
        union() {
            // skirt
            knurl_ring(d=knob_d, h=knob_skirt_h, teeth=56, depth=1.3);
            // upper dome-ish
            translate([0,0,knob_skirt_h])
                hull() {
                    cylinder(d=knob_d*0.92, h=1);
                    translate([0,0,knob_h - knob_skirt_h - 1])
                        cylinder(d=knob_d*0.72, h=1);
                }
            // center hub
            translate([0,0,knob_h*0.35])
                cylinder(d=knob_d*0.35, h=knob_h*0.45);
        }

    // Shaft
    translate([0, knob_y, knob_z + dial_t])
        color("silver")
            cylinder(d=shaft_d, h=shaft_h);

    // Handle
    translate([0, knob_y, knob_z + dial_t + knob_h*0.55])
        color("black")
        rotate([0,0,35])
        translate([knob_d*0.33,0,0])
            hull() {
                cube([handle_l, handle_w, handle_t], center=true);
                translate([handle_l*0.35,0,0])
                    cylinder(d=handle_w, h=handle_t, center=true);
            }
}

// ---------- Rear Terminals (visual) ----------
module rear_terminals() {
    // Simple terminal block and cord strain relief
    y = -base_d/2 - 2;
    z = -base_h/2 + 18;

    // Terminal block
    translate([0, y, z])
        color("black")
            cube([60, 10, 22], center=true);

    // Two binding posts
    for(x=[-15,15]) {
        translate([x, y-6, z+4])
            color("gold")
                rotate([90,0,0])
                    cylinder(d=8, h=10, center=true);
    }

    // Strain relief bump
    translate([base_w/2 - 10, -base_d/2 - 2, -base_h/2 + 18])
        color("black")
            rotate([0,90,0])
                cylinder(d=18, h=10, center=true);
}

// ---------- Render ----------
union() {
    color([0.85,0.85,0.86]) variac_body();
    knob_assembly();
    rear_terminals();
}