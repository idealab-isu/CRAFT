$fn=64;

// LCD 2004A display module (approx) 97.0mm x 39.5mm
// Simple renderable model: PCB + bezel/frame + display window + 16-pin header

module lcd2004a(
    pcb_x=97.0,
    pcb_y=39.5,
    pcb_t=1.6,

    bezel_x=76.0,
    bezel_y=25.0,
    bezel_t=6.0,
    bezel_z=pcb_t,

    window_x=61.0,
    window_y=14.0,
    window_depth=2.0,

    hole_d=3.2,
    hole_edge_x=2.5,
    hole_edge_y=2.5,

    header_pins=16,
    header_pitch=2.54,
    header_pin_d=0.64,
    header_pin_h=6.0,
    header_body_h=2.5,
    header_body_t=2.5
){
    module pcb(){
        color([0.05,0.35,0.12])
        translate([-pcb_x/2,-pcb_y/2,0])
            cube([pcb_x,pcb_y,pcb_t], center=false);
    }

    module mounting_holes(){
        for (sx=[-1,1], sy=[-1,1]) {
            translate([sx*(pcb_x/2 - hole_edge_x), sy*(pcb_y/2 - hole_edge_y), -0.1])
                cylinder(d=hole_d, h=pcb_t+0.2);
        }
    }

    module bezel(){
        // Bezel centered on PCB
        color([0.15,0.15,0.15])
        translate([0,0,bezel_z])
        difference(){
            translate([-bezel_x/2,-bezel_y/2,0])
                cube([bezel_x,bezel_y,bezel_t], center=false);

            // Window cutout
            translate([-window_x/2,-window_y/2,bezel_t-window_depth])
                cube([window_x,window_y,window_depth+0.2], center=false);
        }

        // "Glass" in window
        color([0.05,0.25,0.35,0.6])
        translate([0,0,bezel_z + bezel_t - window_depth + 0.2])
            translate([-window_x/2,-window_y/2,0])
                cube([window_x,window_y,window_depth-0.4], center=false);
    }

    module header(){
        // Place header along bottom edge, centered
        header_len = (header_pins-1)*header_pitch;
        y_pos = -pcb_y/2 + 6.0; // typical inset from edge
        z0 = pcb_t;

        // Plastic body
        color([0.05,0.05,0.05])
        translate([-header_len/2 - header_pitch/2, y_pos - header_body_t/2, z0])
            cube([header_len + header_pitch, header_body_t, header_body_h], center=false);

        // Pins
        color([0.8,0.7,0.2])
        for (i=[0:header_pins-1]){
            x = -header_len/2 + i*header_pitch;
            translate([x, y_pos, z0 - header_pin_h])
                cylinder(d=header_pin_d, h=header_pin_h + header_body_h);
        }
    }

    difference(){
        union(){
            pcb();
            bezel();
            header();
        }
        mounting_holes();
    }
}

lcd2004a();