// PCB: 35.56mm x 25.4mm x 1.6mm (single connected solid)
$fn = 64;

pcb_length    = 35.56;
pcb_width     = 25.4;
pcb_thickness = 1.6;

// Small edge chamfer to make the slab visibly "PCB-like" while keeping exact overall size
chamfer = 0.4; // mm (kept small vs thickness)

module pcb_blank(L, W, T, c) {
    // 2D profile with chamfered corners, then extrude to thickness
    linear_extrude(height=T, center=true)
        polygon(points=[
            [ -L/2 + c, -W/2 ],
            [  L/2 - c, -W/2 ],
            [  L/2,     -W/2 + c ],
            [  L/2,      W/2 - c ],
            [  L/2 - c,  W/2 ],
            [ -L/2 + c,  W/2 ],
            [ -L/2,      W/2 - c ],
            [ -L/2,     -W/2 + c ]
        ]);
}

pcb_blank(pcb_length, pcb_width, pcb_thickness, chamfer);