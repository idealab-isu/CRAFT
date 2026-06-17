$fn=96;

// IEC switched fused inlet module (approximate external model)
// Overall faceplate: 40 x 27 mm
// Includes: faceplate, inlet body, switch rocker, fuse drawer, and simplified pins

// ---------- Parameters ----------
plate_w = 40.0;
plate_h = 27.0;
plate_t = 2.2;

corner_r = 2.0;

body_w = 34.0;
body_h = 22.0;
body_d = 28.0;   // depth behind panel

bezel_lip = 0.6; // slight lip around plate edge

// IEC C14 opening (approx)
iec_w = 27.5;
iec_h = 20.0;
iec_round = 2.0;

// Switch rocker (approx)
sw_w = 12.5;
sw_h = 18.0;
sw_t = 3.2;
sw_offset_x = -11.0; // left side

// Fuse drawer (approx)
fuse_w = 12.5;
fuse_h = 18.0;
fuse_t = 2.8;
fuse_offset_x = 11.0; // right side

// Pins
pin_w = 6.3;
pin_t = 0.8;
pin_len = 10.0;
pin_spacing_x = 10.0;
pin_spacing_y = 7.0;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_box(w,h,d,r){
    linear_extrude(height=d)
        rounded_rect_2d(w,h,r);
}

module screw_boss(x,y,od=5.0,id=3.2,h=6.0){
    translate([x,y,-h])
    difference(){
        cylinder(d=od,h=h);
        translate([0,0,-0.1]) cylinder(d=id,h=h+0.2);
    }
}

module spade_pin(x,y,z0){
    translate([x,y,z0])
    cube([pin_w,pin_t,pin_len], center=true);
}

// ---------- Model ----------
module iec_inlet_module(){
    union(){
        // Faceplate with slight lip
        difference(){
            // plate
            translate([0,0,0])
            linear_extrude(height=plate_t)
                rounded_rect_2d(plate_w, plate_h, corner_r);

            // main IEC opening (center)
            translate([0,0,-0.1])
            linear_extrude(height=plate_t+0.2)
                rounded_rect_2d(iec_w, iec_h, iec_round);

            // switch opening (left)
            translate([sw_offset_x,0,-0.1])
            linear_extrude(height=plate_t+0.2)
                rounded_rect_2d(sw_w+0.6, sw_h+0.6, 1.2);

            // fuse opening (right)
            translate([fuse_offset_x,0,-0.1])
            linear_extrude(height=plate_t+0.2)
                rounded_rect_2d(fuse_w+0.6, fuse_h+0.6, 1.2);
        }

        // Bezel lip (very subtle raised rim)
        translate([0,0,plate_t])
        difference(){
            linear_extrude(height=bezel_lip)
                rounded_rect_2d(plate_w, plate_h, corner_r);
            translate([0,0,-0.1])
            linear_extrude(height=bezel_lip+0.2)
                rounded_rect_2d(plate_w-1.2, plate_h-1.2, max(0.1,corner_r-0.6));
        }

        // Body behind panel
        translate([0,0,-body_d])
        difference(){
            rounded_box(body_w, body_h, body_d, 1.5);

            // hollow cavity (simplified)
            translate([0,0,1.5])
            rounded_box(body_w-2.4, body_h-2.4, body_d-3.0, 1.2);

            // IEC throat opening into body
            translate([0,0,body_d-10])
            rounded_box(iec_w+1.0, iec_h+1.0, 12.0, 2.0);
        }

        // Switch rocker (front protrusion)
        translate([sw_offset_x,0,plate_t+0.2])
        rounded_box(sw_w, sw_h, sw_t, 1.2);

        // Fuse drawer (front protrusion)
        translate([fuse_offset_x,0,plate_t+0.2])
        rounded_box(fuse_w, fuse_h, fuse_t, 1.2);

        // Simplified IEC inlet inner frame (front recess)
        translate([0,0,0.6])
        difference(){
            linear_extrude(height=1.2)
                rounded_rect_2d(iec_w+2.0, iec_h+2.0, 2.2);
            translate([0,0,-0.1])
            linear_extrude(height=1.4)
                rounded_rect_2d(iec_w, iec_h, 2.0);
        }

        // Mounting screw bosses (approx positions)
        screw_boss(-15.5, 0, od=5.2, id=3.2, h=7.0);
        screw_boss( 15.5, 0, od=5.2, id=3.2, h=7.0);

        // Spade pins (rear)
        // Arrange 3 pins in IEC pattern (L, N, E) simplified
        // Place near rear end of body
        zpin = -body_d - pin_len/2 + 2.0;
        // Earth (top center)
        spade_pin(0, pin_spacing_y/2, zpin);
        // Neutral (bottom left)
        spade_pin(-pin_spacing_x/2, -pin_spacing_y/2, zpin);
        // Live (bottom right)
        spade_pin(pin_spacing_x/2, -pin_spacing_y/2, zpin);

        // Extra pins for switch/fuse (simplified)
        spade_pin(sw_offset_x,  pin_spacing_y/2, zpin);
        spade_pin(sw_offset_x, -pin_spacing_y/2, zpin);
        spade_pin(fuse_offset_x,  pin_spacing_y/2, zpin);
        spade_pin(fuse_offset_x, -pin_spacing_y/2, zpin);
    }
}

iec_inlet_module();