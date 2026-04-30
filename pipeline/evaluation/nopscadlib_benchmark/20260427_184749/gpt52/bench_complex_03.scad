$fn=64;

// Raspberry Pi 4 Case with GPIO slot, ventilation, and port cutouts
// Parametric, centered at origin

// ---------- Parameters ----------
pi_len = 85;
pi_wid = 56;
pi_thk = 17;

wall = 2.4;
floor_thk = 2.4;
lid_thk = 2.2;

inner_len = pi_len + 6;   // clearance
inner_wid = pi_wid + 6;
inner_h   = pi_thk + 10;  // headroom

outer_len = inner_len + 2*wall;
outer_wid = inner_wid + 2*wall;
outer_h   = inner_h + floor_thk + lid_thk;

corner_r = 6;

// Port side mapping (approx):
// +Y: USB/Ethernet side
// -Y: HDMI/USB-C/Audio side
// +X: GPIO side (slot)
// -X: microSD side

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=true) {
    // Minkowski with sphere for rounded edges
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=center);
        sphere(r=r);
    }
}

module vent_slots_x(count=10, slot=[2.2, 18, 1.6], pitch=4.2, z=0, y=0) {
    // slots oriented along Y, arrayed along X
    for (i=[0:count-1]) {
        translate([ (i-(count-1)/2)*pitch, y, z ])
            cube(slot, center=true);
    }
}

module vent_slots_y(count=12, slot=[18, 2.2, 1.6], pitch=4.2, z=0, x=0) {
    // slots oriented along X, arrayed along Y
    for (i=[0:count-1]) {
        translate([ x, (i-(count-1)/2)*pitch, z ])
            cube(slot, center=true);
    }
}

// ---------- Main Case ----------
module rpi4_case() {
    difference() {
        // Outer shell
        rounded_box([outer_len, outer_wid, outer_h], r=corner_r, center=true);

        // Inner cavity (leave floor and lid thickness)
        translate([0,0,(floor_thk - lid_thk)/2])
            rounded_box([inner_len, inner_wid, outer_h - floor_thk - lid_thk + 0.2], r=max(1, corner_r-wall), center=true);

        // Split line / lid gap (optional thin relief around mid-height)
        // (kept minimal to avoid weakening)
        translate([0,0,0])
            cube([outer_len+1, outer_wid+1, 0.6], center=true);

        // ---------- Port Cutouts ----------
        // +Y side: USB (2x) + Ethernet (approx)
        // Place cutouts near one end along X
        y_face = outer_wid/2 + 0.01;
        z_ports = -outer_h/2 + floor_thk + 10.5;

        // Ethernet cutout
        translate([ -outer_len/2 + wall + 18, y_face, z_ports ])
            cube([16.5, wall+2, 14.5], center=true);

        // USB stack cutout (covers both USB2/USB3 area)
        translate([ -outer_len/2 + wall + 40, y_face, z_ports ])
            cube([30, wall+2, 15.5], center=true);

        // -Y side: USB-C power, 2x micro-HDMI, 3.5mm audio
        y_face2 = -outer_wid/2 - 0.01;
        z_ports2 = -outer_h/2 + floor_thk + 8.5;

        // USB-C
        translate([ -outer_len/2 + wall + 10, y_face2, z_ports2 ])
            cube([10.5, wall+2, 6.0], center=true);

        // micro-HDMI 1
        translate([ -outer_len/2 + wall + 26, y_face2, z_ports2 ])
            cube([9.0, wall+2, 5.5], center=true);

        // micro-HDMI 2
        translate([ -outer_len/2 + wall + 40, y_face2, z_ports2 ])
            cube([9.0, wall+2, 5.5], center=true);

        // Audio jack
        translate([ -outer_len/2 + wall + 58, y_face2, z_ports2 ])
            cube([10.0, wall+2, 7.0], center=true);

        // ---------- microSD slot (-X side) ----------
        x_face_sd = -outer_len/2 - 0.01;
        translate([ x_face_sd, 0, -outer_h/2 + floor_thk + 4.0 ])
            cube([wall+2, 16, 3.2], center=true);

        // ---------- GPIO slot (+X side) ----------
        // Long opening near top for ribbon/headers access
        x_face_gpio = outer_len/2 + 0.01;
        translate([ x_face_gpio, 0, outer_h/2 - lid_thk - 8.5 ])
            cube([wall+2, 54, 16], center=true);

        // ---------- Ventilation ----------
        // Top vents
        translate([0, 0, outer_h/2 - lid_thk/2])
            vent_slots_x(count=12, slot=[2.2, outer_wid-18, lid_thk+1.2], pitch=4.2, z=0, y=0);

        // Side vents on +Y (above ports)
        translate([0, outer_wid/2 - wall/2, 6])
            vent_slots_x(count=10, slot=[2.0, wall+1.6, 18], pitch=5.0, z=0, y=0);

        // Side vents on -Y (above ports)
        translate([0, -outer_wid/2 + wall/2, 6])
            vent_slots_x(count=10, slot=[2.0, wall+1.6, 18], pitch=5.0, z=0, y=0);

        // Bottom vents (optional, smaller)
        translate([0, 0, -outer_h/2 + floor_thk/2])
            vent_slots_y(count=10, slot=[outer_len-22, 2.0, floor_thk+1.2], pitch=4.8, z=0, x=0);

        // ---------- Screw holes (4) ----------
        // Through holes from bottom to near top
        hole_r = 1.6;
        post_offset_x = (inner_len/2 - 10);
        post_offset_y = (inner_wid/2 - 10);
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*post_offset_x, sy*post_offset_y, 0])
                cylinder(h=outer_h+2, r=hole_r, center=true);
        }
    }

    // Add internal standoffs (posts) for mounting
    post_r = 3.2;
    post_h = floor_thk + 6.5;
    post_offset_x = (inner_len/2 - 10);
    post_offset_y = (inner_wid/2 - 10);

    union() {
        // Shell already created by difference; add posts as separate unioned solids
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*post_offset_x, sy*post_offset_y, -outer_h/2 + post_h/2])
                difference() {
                    cylinder(h=post_h, r=post_r, center=true);
                    cylinder(h=post_h+1, r=1.6, center=true);
                }
        }

        // Simple internal rails to help lid alignment (inside near top)
        rail_thk = 1.2;
        rail_h = 4.0;
        translate([0,  inner_wid/2 - rail_thk/2, outer_h/2 - lid_thk - rail_h/2])
            cube([inner_len-8, rail_thk, rail_h], center=true);
        translate([0, -inner_wid/2 + rail_thk/2, outer_h/2 - lid_thk - rail_h/2])
            cube([inner_len-8, rail_thk, rail_h], center=true);
        translate([ inner_len/2 - rail_thk/2, 0, outer_h/2 - lid_thk - rail_h/2])
            cube([rail_thk, inner_wid-8, rail_h], center=true);
        translate([-inner_len/2 + rail_thk/2, 0, outer_h/2 - lid_thk - rail_h/2])
            cube([rail_thk, inner_wid-8, rail_h], center=true);
    }
}

rpi4_case();