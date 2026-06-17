$fn=96;

// Parameters
pin_d = 2.2;          // pin diameter
pin_len = 12;         // pin length protruding
pin_spacing = 2.54;   // spacing between pins
rows = 2;
cols = 4;

body_w = (cols-1)*pin_spacing + 8;   // overall width
body_h = (rows-1)*pin_spacing + 8;   // overall height
body_t = 6;                          // thickness

flange_w = body_w + 14;
flange_h = body_h + 10;
flange_t = 3;

hole_d = 3.2;         // mounting hole diameter
hole_offset_x = flange_w/2 - 6;
hole_offset_y = 0;

key_w = 6;
key_h = 3;
key_t = 2;

module d_sub_body(){
    difference(){
        // Main body (rounded rectangle)
        minkowski(){
            cube([body_w-2, body_h-2, body_t-1], center=true);
            cylinder(r=1, h=1, center=true);
        }

        // Pin holes through body
        for(r=[0:rows-1])
            for(c=[0:cols-1]){
                x = (c-(cols-1)/2)*pin_spacing;
                y = (r-(rows-1)/2)*pin_spacing;
                translate([x,y,0])
                    cylinder(d=pin_d+0.4, h=body_t+2, center=true);
            }

        // Key notch on top edge
        translate([0, body_h/2 - key_h/2, body_t/2 - key_t/2])
            cube([key_w, key_h, key_t+0.5], center=true);
    }
}

module flange(){
    difference(){
        // Flange plate
        minkowski(){
            cube([flange_w-2, flange_h-2, flange_t-1], center=true);
            cylinder(r=1, h=1, center=true);
        }

        // Mounting holes
        translate([ hole_offset_x, hole_offset_y, 0])
            cylinder(d=hole_d, h=flange_t+2, center=true);
        translate([-hole_offset_x, hole_offset_y, 0])
            cylinder(d=hole_d, h=flange_t+2, center=true);

        // Clearance for body
        translate([0,0,0.5])
            cube([body_w+1, body_h+1, flange_t+2], center=true);
    }
}

module pins(){
    for(r=[0:rows-1])
        for(c=[0:cols-1]){
            x = (c-(cols-1)/2)*pin_spacing;
            y = (r-(rows-1)/2)*pin_spacing;
            translate([x,y,-(body_t/2 + pin_len/2)])
                cylinder(d=pin_d, h=pin_len, center=true);
        }
}

module d_connector(){
    union(){
        // Flange behind body
        translate([0,0, body_t/2 - flange_t/2])
            flange();

        // Body
        d_sub_body();

        // Pins
        pins();
    }
}

d_connector();