$fn=64;

// Display Module v3.0
// Overall: 84.5mm x 54.5mm

module display_module_v3(
    L=84.5,   // length (X)
    W=54.5,   // width  (Y)
    T=2.0,    // PCB thickness
    corner_r=3.0,

    // Mounting holes (typical 4-corner pattern)
    hole_d=3.2,
    hole_edge_x=3.5,   // hole center offset from X edges
    hole_edge_y=3.5,   // hole center offset from Y edges

    // Display window / cutout (approx)
    window_L=70.0,
    window_W=40.0,
    window_depth=1.2,
    window_offset_x=0.0,
    window_offset_y=0.0,

    // Optional bezel/raised frame around window
    bezel_h=1.2,
    bezel_t=1.6
){
    module rounded_plate(l,w,t,r){
        linear_extrude(height=t)
            offset(r=r)
                square([l-2*r, w-2*r], center=true);
    }

    module holes(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(L/2 - hole_edge_x), sy*(W/2 - hole_edge_y), -0.5])
                cylinder(d=hole_d, h=T+1.0);
        }
    }

    module window_cut(){
        translate([window_offset_x, window_offset_y, T-window_depth])
            linear_extrude(height=window_depth+0.6)
                square([window_L, window_W], center=true);
    }

    module bezel(){
        // A simple raised rectangular frame around the window
        translate([window_offset_x, window_offset_y, T])
        difference(){
            linear_extrude(height=bezel_h)
                square([window_L + 2*bezel_t, window_W + 2*bezel_t], center=true);
            translate([0,0,-0.1])
                linear_extrude(height=bezel_h+0.2)
                    square([window_L, window_W], center=true);
        }
    }

    difference(){
        rounded_plate(L,W,T,corner_r);
        holes();
        window_cut();
    }

    bezel();
}

display_module_v3();