$fn = 96;

// -------------------- Parameters (approximate RAVISTAT 1F-1 form factor) --------------------
body_d            = 80;
body_h            = 50;

top_flange_d      = 90;
top_flange_h      = 8;

bottom_flange_d   = 92;
bottom_flange_h   = 10;

foot_w            = 18;
foot_l            = 14;
foot_h            = 6;

shaft_d           = 10;
shaft_h           = 18;

dial_d            = 85;
dial_h            = 5;

knob_d            = 22;
knob_h            = 14;

terminal_block_w  = 46;
terminal_block_d  = 22;
terminal_block_h  = 18;

lug_d             = 7;
lug_h             = 10;

vent_slot_w       = 6;
vent_slot_h       = 18;
vent_slot_depth   = 3;
vent_slot_count   = 10;

overlap           = 1.2;   // 1–2mm overlap to guarantee one connected solid

// -------------------- Helpers --------------------
module rounded_box(size=[10,10,10], r=2, center=true) {
    minkowski() {
        cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), max(0.01,size[2]-2*r)], center=center);
        sphere(r=r);
    }
}

module ring_lip(d_outer, d_inner, h, zc) {
    translate([0,0,zc])
    difference() {
        cylinder(d=d_outer, h=h, center=true);
        cylinder(d=d_inner, h=h+0.2, center=true);
    }
}

// -------------------- Main body with vents --------------------
module body_with_vents() {
    difference() {
        cylinder(d=body_d, h=body_h, center=true);

        for (i = [0:vent_slot_count-1]) {
            rotate([0,0,i*360/vent_slot_count])
                translate([body_d/2 - vent_slot_depth/2, 0, 0])
                    cube([vent_slot_depth, vent_slot_w, vent_slot_h], center=true);
        }

        translate([0,0, body_h/2 - 2])
            cylinder(d1=body_d-2, d2=body_d-8, h=4, center=true);

        translate([0,0,-body_h/2 + 2])
            cylinder(d1=body_d-8, d2=body_d-2, h=4, center=true);
    }
}

// -------------------- Feet / mounting lugs --------------------
module feet() {
    // Attach feet to the bottom flange (intersect by overlap)
    // Bottom flange center: z_flange = -body_h/2 - bottom_flange_h/2 + overlap
    z_flange = -body_h/2 - bottom_flange_h/2 + overlap;

    // Put feet so their TOP face slightly intersects flange BOTTOM face
    // flange_bottom = z_flange - bottom_flange_h/2
    // foot_top = zc + foot_h/2 = flange_bottom + overlap
    flange_bottom = z_flange - bottom_flange_h/2;
    zc = flange_bottom + overlap - foot_h/2;

    for (a = [45, 135, 225, 315]) {
        rotate([0,0,a])
            translate([bottom_flange_d/2 - foot_l/2 + overlap, 0, zc])
                rounded_box([foot_l, foot_w, foot_h], r=2, center=true);
    }
}

// -------------------- Terminal block + lugs --------------------
module terminal_block() {
    // Ensure it intersects the body by overlap
    x = body_d/2 + terminal_block_d/2 - overlap;
    z = -body_h/2 + terminal_block_h/2 + 6;

    union() {
        translate([x, 0, z])
            rounded_box([terminal_block_d, terminal_block_w, terminal_block_h], r=2, center=true);

        lug_x = x + terminal_block_d/2 + lug_h/2 - overlap;
        for (yy = [-terminal_block_w/3, 0, terminal_block_w/3]) {
            translate([lug_x, yy, z])
                rotate([0,90,0])
                    cylinder(d=lug_d, h=lug_h, center=true);
        }

        translate([x + terminal_block_d/2 - 4, 0, z - terminal_block_h/2 + 5])
            sphere(r=4);
    }
}

// -------------------- Top assembly: flange + shaft + dial + knob --------------------
module top_assembly() {
    // FIX: guarantee top flange intersects body (no gap / no floating)
    // Body top face: z = +body_h/2
    // Want flange bottom face = body top face - overlap
    // => z_flange - top_flange_h/2 = body_h/2 - overlap
    // => z_flange = body_h/2 + top_flange_h/2 - overlap
    z_flange = body_h/2 + top_flange_h/2 - overlap;

    // Shaft: bottom slightly into flange top (and thus into body via flange)
    // flange_top = z_flange + top_flange_h/2
    // shaft_bottom = z_shaft - shaft_h/2 = flange_top - overlap
    flange_top = z_flange + top_flange_h/2;
    z_shaft = flange_top - overlap + shaft_h/2;

    // Dial: bottom slightly into shaft top
    shaft_top = z_shaft + shaft_h/2;
    z_dial = shaft_top - overlap + dial_h/2;

    // Knob: bottom slightly into dial top
    dial_top = z_dial + dial_h/2;
    z_knob = dial_top - overlap + knob_h/2;

    union() {
        // Top flange (attached)
        translate([0,0,z_flange])
            cylinder(d=top_flange_d, h=top_flange_h, center=true);

        // Raised ring on top flange (ensure it intersects flange by overlap)
        // Place it so its bottom is slightly below flange top
        ring_h = 2.2;
        z_ring = flange_top - overlap + ring_h/2;
        ring_lip(
            d_outer=top_flange_d-6,
            d_inner=top_flange_d-18,
            h=ring_h,
            zc=z_ring
        );

        // Shaft (attached)
        translate([0,0,z_shaft])
            cylinder(d=shaft_d, h=shaft_h, center=true);

        // Dial plate (attached)
        translate([0,0,z_dial])
            cylinder(d=dial_d, h=dial_h, center=true);

        // Knob (attached)
        translate([0,0,z_knob])
            union() {
                cylinder(d=knob_d, h=knob_h, center=true);

                rib_len = 3.2;
                rib_w   = 2.2;
                for (i=[0:11]) {
                    rotate([0,0,i*360/12])
                        translate([knob_d/2 + rib_len/2 - overlap, 0, 0])
                            cube([rib_len, rib_w, knob_h-2], center=true);
                }

                // Top cap (ensure it intersects knob body)
                translate([0,0,knob_h/2 - 1.2])
                    cylinder(d=knob_d-2, h=2.4, center=true);
            }
    }
}

// -------------------- Bottom flange + center boss --------------------
module bottom_assembly() {
    // FIX: guarantee bottom flange intersects body (no gap / no floating)
    // Body bottom face: z = -body_h/2
    // Want flange top face = body bottom face + overlap
    // => z_flange + bottom_flange_h/2 = -body_h/2 + overlap
    // => z_flange = -body_h/2 - bottom_flange_h/2 + overlap
    z_flange = -body_h/2 - bottom_flange_h/2 + overlap;

    boss_d = 22;
    boss_h = 12;

    // Ensure boss intersects flange by overlap (boss top into flange bottom)
    // flange_bottom = z_flange - bottom_flange_h/2
    // boss_top = z_boss + boss_h/2 = flange_bottom + overlap
    flange_bottom = z_flange - bottom_flange_h/2;
    z_boss = flange_bottom + overlap - boss_h/2;

    union() {
        translate([0,0,z_flange])
            cylinder(d=bottom_flange_d, h=bottom_flange_h, center=true);

        translate([0,0,z_boss])
            cylinder(d=boss_d, h=boss_h, center=true);

        rotate([0,0,20])
            translate([bottom_flange_d/2 - 6, 0, z_flange])
                rounded_box([10, 8, bottom_flange_h-2], r=2, center=true);
    }
}

// -------------------- Complete Variac (ONE connected solid) --------------------
module variac_ravistat_1f1() {
    union() {
        body_with_vents();
        top_assembly();
        bottom_assembly();
        feet();
        terminal_block();
    }
}

variac_ravistat_1f1();