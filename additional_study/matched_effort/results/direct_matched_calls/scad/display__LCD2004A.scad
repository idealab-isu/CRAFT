$fn=64;

// LCD 2004A display module (approx) 97.0mm x 39.5mm
// Simple renderable model: PCB + bezel + viewing window + 4 mounting holes

module lcd2004a_module(
    pcb_x=97.0,
    pcb_y=39.5,
    pcb_t=1.6,
    hole_d=3.2,
    hole_edge_x=3.5,   // distance from left/right edge to hole center
    hole_edge_y=3.5,   // distance from bottom/top edge to hole center
    bezel_x=76.0,
    bezel_y=25.0,
    bezel_t=3.0,
    window_x=70.0,
    window_y=18.0,
    window_depth=1.6
){
    module pcb(){
        difference(){
            color([0.05,0.35,0.12]) translate([-pcb_x/2,-pcb_y/2,0]) cube([pcb_x,pcb_y,pcb_t], center=false);
            for (sx=[-1,1], sy=[-1,1]){
                translate([sx*(pcb_x/2 - hole_edge_x), sy*(pcb_y/2 - hole_edge_y), -0.1])
                    cylinder(d=hole_d, h=pcb_t+0.2);
            }
        }
    }

    module bezel(){
        // Raised bezel centered on PCB
        difference(){
            color([0.15,0.15,0.15])
                translate([-bezel_x/2,-bezel_y/2,pcb_t])
                    cube([bezel_x,bezel_y,bezel_t], center=false);

            // Viewing window cutout
            translate([-window_x/2,-window_y/2,pcb_t + bezel_t - window_depth])
                cube([window_x,window_y,window_depth+0.2], center=false);
        }

        // Dark "glass" inset
        color([0.02,0.08,0.10,0.85])
            translate([-window_x/2,-window_y/2,pcb_t + bezel_t - window_depth])
                cube([window_x,window_y,window_depth], center=false);
    }

    pcb();
    bezel();
}

lcd2004a_module();