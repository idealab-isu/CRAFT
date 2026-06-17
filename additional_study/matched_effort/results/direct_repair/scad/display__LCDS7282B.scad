$fn=64;

// LCD Display Module S-7282B (approximate)
// Overall: 73.6mm x 28.7mm
// Includes: PCB, bezel/frame, viewing window, 4 mounting holes

module lcd_s7282b(
    pcb_len=73.6,
    pcb_wid=28.7,
    pcb_thk=1.6,

    bezel_margin=1.8,
    bezel_thk=2.4,

    window_len=56.0,
    window_wid=16.0,
    window_inset=0.6,   // how far down the window recess starts from bezel top
    window_depth=1.6,   // recess depth into bezel

    hole_d=3.2,
    hole_edge_x=3.5,    // hole center offset from left/right edge
    hole_edge_y=3.5     // hole center offset from bottom/top edge
){
    module pcb(){
        color([0.05,0.35,0.12])
            cube([pcb_len, pcb_wid, pcb_thk], center=false);
    }

    module bezel(){
        // Bezel sits on top of PCB, centered
        bezel_len = pcb_len - 2*bezel_margin;
        bezel_wid = pcb_wid - 2*bezel_margin;

        translate([bezel_margin, bezel_margin, pcb_thk])
        difference(){
            color([0.08,0.08,0.08])
                cube([bezel_len, bezel_wid, bezel_thk], center=false);

            // Viewing window recess
            translate([(bezel_len-window_len)/2, (bezel_wid-window_wid)/2, bezel_thk - window_inset - window_depth])
                cube([window_len, window_wid, window_depth + 0.01], center=false);
        }

        // "Glass" in the window (slightly below top surface)
        translate([bezel_margin + (bezel_len-window_len)/2,
                   bezel_margin + (bezel_wid-window_wid)/2,
                   pcb_thk + bezel_thk - window_inset - 0.8])
            color([0.15,0.25,0.35, 0.6])
                cube([window_len, window_wid, 0.8], center=false);
    }

    module holes(){
        for (sx=[hole_edge_x, pcb_len-hole_edge_x])
            for (sy=[hole_edge_y, pcb_wid-hole_edge_y])
                translate([sx, sy, -0.1])
                    cylinder(d=hole_d, h=pcb_thk + bezel_thk + 0.2);
    }

    difference(){
        union(){
            pcb();
            bezel();

            // Simple connector pad area (approx) on back edge
            translate([pcb_len-18, (pcb_wid-10)/2, 0])
                color([0.75,0.65,0.15])
                    cube([16, 10, 0.2], center=false);
        }
        holes();
    }
}

lcd_s7282b();