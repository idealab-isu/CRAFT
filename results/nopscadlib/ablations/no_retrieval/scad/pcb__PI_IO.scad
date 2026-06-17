// PCB parameters (mm)
pcb_length    = 35.56;
pcb_width     = 25.4;
pcb_thickness = 1.6;

// Small edge bevel to look more like a PCB while keeping exact overall size
edge_bevel = min(0.6, pcb_thickness/2);

// PCB module (single connected solid)
module pcb(len=pcb_length, wid=pcb_width, th=pcb_thickness, b=edge_bevel) {
    color([0.0, 0.4, 0.2])
    hull() {
        // 4 corner posts, inset by bevel amount; hull creates beveled sides
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(len/2 - b), sy*(wid/2 - b), 0])
                cylinder(h=th, r=b, center=true, $fn=48);
        }
    }
}

// Final output
pcb();