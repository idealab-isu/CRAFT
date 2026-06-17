$fn=64;

// LCD 2004A Display Module (approx. 97.0mm x 39.5mm)
// Simple, renderable representation: PCB + bezel + viewing window + mounting holes

module lcd2004a(
    pcb_x=97.0,
    pcb_y=39.5,
    pcb_t=1.6,

    hole_d=3.2,
    hole_edge_x=2.5,   // distance from left/right edge to hole center
    hole_edge_y=2.5,   // distance from bottom/top edge to hole center

    bezel_x=76.0,
    bezel_y=25.0,
    bezel_t=3.0,

    window_x=70.0,
    window_y=18.0,
    window_depth=2.2,

    glass_t=1.0
){
    module rounded_rect_2d(x,y,r){
        r2 = min(r, min(x,y)/2);
        hull(){
            translate([ x/2-r2,  y/2-r2]) circle(r=r2);
            translate([-x/2+r2,  y/2-r2]) circle(r=r2);
            translate([ x/2-r2, -y/2+r2]) circle(r=r2);
            translate([-x/2+r2, -y/2+r2]) circle(r=r2);
        }
    }

    difference(){
        // PCB
        color([0.05,0.35,0.12])
        linear_extrude(height=pcb_t)
            rounded_rect_2d(pcb_x, pcb_y, 1.5);

        // Mounting holes
        for (sx=[-1,1], sy=[-1,1]){
            translate([ sx*(pcb_x/2 - hole_edge_x), sy*(pcb_y/2 - hole_edge_y), -0.5 ])
                cylinder(d=hole_d, h=pcb_t+1.0);
        }
    }

    // Bezel/frame on top of PCB
    translate([0,0,pcb_t])
    difference(){
        color([0.12,0.12,0.12])
        linear_extrude(height=bezel_t)
            rounded_rect_2d(bezel_x, bezel_y, 1.2);

        // Viewing window cutout
        translate([0,0,-0.1])
        linear_extrude(height=bezel_t+0.2)
            rounded_rect_2d(window_x, window_y, 0.8);
    }

    // Glass (slightly recessed)
    translate([0,0,pcb_t + (bezel_t - window_depth)])
    color([0.15,0.25,0.35,0.65])
    linear_extrude(height=glass_t)
        rounded_rect_2d(window_x-1.0, window_y-1.0, 0.6);

    // Optional: simple pin header block (approx) on back edge
    // Comment out if undesired
    header_pins = 16;
    pin_pitch = 2.54;
    header_len = (header_pins-1)*pin_pitch + 2.54;
    header_w = 5.0;
    header_h = 8.0;

    translate([0, -(pcb_y/2 - 6.0), -header_h])
    color([0.05,0.05,0.05])
    cube([header_len, header_w, header_h], center=true);
}

lcd2004a();