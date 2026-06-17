$fn = 64;

// IEC filtered inlet module (approximate) - overall front flange 40 x 29 mm
// Coordinate system: Front face at z=0, body extends to negative z.

flange_w = 40.0;
flange_h = 29.0;
flange_t = 2.4;

body_w = 34.0;
body_h = 24.0;
body_d = 28.0;          // main inlet body depth behind flange

filter_w = 34.0;
filter_h = 24.0;
filter_d = 22.0;        // filter housing depth behind body

// Front IEC C14 opening (outer shroud opening)
iec_open_w = 27.0;
iec_open_h = 20.0;
iec_open_d = 18.0;      // cut depth into body

// Inner recess to suggest C14 cavity
iec_recess_w = 23.0;
iec_recess_h = 16.0;
iec_recess_d = 12.0;

// Pin openings (3 rectangular slots)
pin_slot_w = 6.2;
pin_slot_h = 3.2;
pin_slot_d = 22.0;      // cut through body into filter area
pin_pitch_x = 10.0;     // L-N spacing
pin_y = -2.0;           // slightly below center like many C14 inlets

// Ground pin above
gnd_slot_w = 6.2;
gnd_slot_h = 3.2;
gnd_y = 6.0;

// Mounting holes on flange
screw_d = 3.2;
screw_head_clear_d = 6.0;
screw_x = 16.0;
screw_y = 11.0;

// Front bezel lip around opening (adds characteristic inlet frame)
bezel_lip = 1.6;        // thickness of raised frame around opening
bezel_raise = 1.2;      // how far it protrudes forward from flange front
bezel_corner_r = 2.0;   // rounded corners for bezel opening

// Side snap/retention ears on body sides (approx)
ear_w = 2.2;
ear_h = 10.0;
ear_d = 8.0;
ear_inset_z = 10.0;     // distance from flange into body

// Rear spade terminals (3)
term_w = 6.3;
term_h = 0.8;
term_d = 12.0;
term_z_overlap = 1.2;   // overlap into filter housing to ensure connectivity
term_y_offset = 0.0;
term_x_pitch = 10.0;

// ---------- helpers ----------
module rounded_rect_2d(w, h, r) {
    rr = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2-rr), sy*(h/2-rr)]) circle(r=rr);
    }
}

module rounded_box(size=[10,10,10], r=1.0, center=true) {
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, min(x,y)/2);
    linear_extrude(height=z, center=center)
        rounded_rect_2d(x, y, rr);
}

module iec_filtered_inlet_40x29() {

    // Derived Z positions (front at z=0)
    body_z0   = -body_d;                 // body spans [body_z0, 0]
    filter_z0 = -(body_d + filter_d);    // filter spans [filter_z0, body_z0]

    // Bezel outer dims (frame around IEC opening)
    bezel_outer_w = iec_open_w + 2*bezel_lip;
    bezel_outer_h = iec_open_h + 2*bezel_lip;

    // Z placement for bezel: sits on flange front and protrudes forward
    flange_front_z = flange_t; // flange spans [0..flange_t]
    bezel_center_z = flange_front_z + bezel_raise/2 - 0.2; // slight overlap into flange

    union() {
        difference() {
            union() {
                // Flange (front plate) from z=0 to z=flange_t
                translate([0,0, flange_t/2])
                    rounded_box([flange_w, flange_h, flange_t], r=1.2, center=true);

                // Raised bezel/frame around IEC opening (characteristic inlet face)
                translate([0,0, bezel_center_z])
                    difference() {
                        rounded_box([bezel_outer_w, bezel_outer_h, bezel_raise], r=2.2, center=true);
                        // inner opening of bezel (slightly larger than cutout to show frame)
                        rounded_box([iec_open_w, iec_open_h, bezel_raise + 0.4], r=bezel_corner_r, center=true);
                    }

                // Main body behind flange (slightly inset to show flange lip)
                translate([0,0, body_z0/2])
                    rounded_box([body_w, body_h, body_d], r=1.0, center=true);

                // Filter housing behind body
                translate([0,0, (filter_z0 + body_z0)/2])
                    rounded_box([filter_w, filter_h, filter_d], r=1.0, center=true);

                // Side snap/retention ears (connected to body sides)
                for (sx = [-1, 1]) {
                    translate([
                        sx*(body_w/2 + ear_w/2 - 0.6), // overlap into body by 0.6
                        0,
                        -(ear_inset_z + ear_d/2)
                    ])
                        cube([ear_w, ear_h, ear_d], center=true);
                }

                // Rear spade terminals (3), connected into filter housing
                rear_face_z = filter_z0; // most negative face of filter
                for (i = [-1, 0, 1]) {
                    translate([
                        i*term_x_pitch,
                        term_y_offset,
                        rear_face_z - term_d/2 + term_z_overlap
                    ])
                        cube([term_w, term_h, term_d], center=true);
                }
            }

            // --- CUTOUTS ---

            // Outer IEC opening: rounded rectangle through flange and into body
            // Centered so its front face starts at z=0 and extends into negative z.
            translate([0,0, -iec_open_d/2 + 0.01])
                linear_extrude(height=iec_open_d + 0.02, center=true)
                    rounded_rect_2d(iec_open_w, iec_open_h, bezel_corner_r);

            // Inner recess (smaller) deeper into body to suggest cavity
            translate([0,0, -(flange_t + iec_recess_d/2)])
                linear_extrude(height=iec_recess_d, center=true)
                    rounded_rect_2d(iec_recess_w, iec_recess_h, 1.6);

            // Pin slots (cut from front into body/filter region)
            for (px = [-pin_pitch_x/2, pin_pitch_x/2]) {
                translate([px, pin_y, -(flange_t + pin_slot_d/2)])
                    cube([pin_slot_w, pin_slot_h, pin_slot_d], center=true);
            }
            translate([0, gnd_y, -(flange_t + pin_slot_d/2)])
                cube([gnd_slot_w, gnd_slot_h, pin_slot_d], center=true);

            // Mounting screw holes through flange
            for (x = [-screw_x, screw_x])
                for (y = [-screw_y, screw_y]) {
                    translate([x, y, flange_t/2])
                        cylinder(h=flange_t + 0.6, d=screw_d, center=true);
                    translate([x, y, flange_t - 0.6])
                        cylinder(h=1.4, d=screw_head_clear_d, center=true);
                }
        }
    }
}

iec_filtered_inlet_40x29();