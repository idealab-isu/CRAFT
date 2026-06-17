$fn=96;

// IEC-style lugless connector (male inlet-like) with visible front shroud,
// keying notch, and 3 protruding pins. One connected solid.
module iec_lugless(
    body_w=28,
    body_h=20,
    body_d=16,

    corner_r=2.0,

    // Front shroud / nose
    shroud_depth=3.2,
    shroud_margin=1.6,
    shroud_corner_r=1.4,

    // Front face recess (around pins)
    face_recess=1.2,
    face_margin=1.2,

    // Key notch (top center)
    key_notch_w=6.0,
    key_notch_h=3.0,
    key_notch_depth=2.2,

    // Pins
    pin_pitch=10.0,
    pin_w=4.8,
    pin_h=1.6,
    pin_len=6.5,          // protrusion out of front
    pin_inset=1.0,        // how far pin base sits behind front face
    pin_round=0.55,

    // Small overlap to guarantee watertight unions
    overlap=0.4
){
    // Rounded rectangle prism, centered in XY, extruded along +Z from z=0..d
    module rounded_box(w,h,d,r){
        r2 = min(r, min(w,h)/2);
        linear_extrude(height=d, center=false)
            offset(r=r2)
                square([w-2*r2, h-2*r2], center=true);
    }

    // Rounded rectangular pin (with slight fillet)
    module pin3d(){
        minkowski(){
            cube([max(0.01,pin_w-2*pin_round), max(0.01,pin_h-2*pin_round), max(0.01,pin_len-2*pin_round)], center=true);
            sphere(r=pin_round);
        }
    }

    // Main body with front recess and key notch cut
    module body(){
        difference(){
            // Outer body: z=0..body_d (front face at z=0)
            rounded_box(body_w, body_h, body_d, corner_r);

            // Front face recess: cut into front face (z=0..face_recess)
            translate([0,0,0])
                rounded_box(body_w-2*face_margin, body_h-2*face_margin, face_recess, max(0,corner_r-0.8));

            // Key notch cut into the front top edge (also into front face)
            translate([0, body_h/2 - face_margin - key_notch_h/2, key_notch_depth/2])
                cube([key_notch_w, key_notch_h, key_notch_depth], center=true);
        }
    }

    // Front shroud that protrudes out of the front face (negative Z), connected with overlap
    module shroud(){
        sh_w = body_w - 2*shroud_margin;
        sh_h = body_h - 2*shroud_margin;

        // Shroud spans z = -(shroud_depth) .. overlap (slightly into body)
        translate([0,0,-shroud_depth])
            rounded_box(sh_w, sh_h, shroud_depth + overlap, shroud_corner_r);
    }

    // Pins protruding from front (negative Z), with base slightly inside shroud/body for connection
    module pins(){
        // Ensure pins connect: their back end reaches into shroud by overlap
        // Pin center z so that: back_end = cz + pin_len/2 = overlap
        pin_cz = overlap - pin_len/2;

        // Slight vertical offset (IEC-ish)
        pin_cy = -body_h*0.10;

        for (x = [-pin_pitch, 0, pin_pitch]){
            translate([x, pin_cy, pin_cz])
                pin3d();
        }
    }

    union(){
        body();
        shroud();
        pins();
    }
}

// Render
iec_lugless();