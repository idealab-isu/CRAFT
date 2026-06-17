$fn = 96;

// T-slot nut parameters (mm)
thickness = 3.7;          // overall thickness
across_flats = 6.0;       // hex across flats
screw_d = 5.0;            // screw diameter (clearance-ish)
clearance = 0.3;          // extra clearance for screw hole

// Typical small T-slot nut proportions (adjust if needed)
slot_width = 8.0;         // width to fit slot opening
slot_length = 12.0;       // length along slot
corner_r = 0.8;           // corner rounding
top_chamfer = 0.4;        // slight edge break

module rounded_rect_2d(w, l, r){
    r2 = min(r, min(w,l)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(w/2 - r2), sy*(l/2 - r2)]) circle(r=r2);
    }
}

module tslot_nut(){
    difference(){
        // Body
        linear_extrude(height=thickness)
            rounded_rect_2d(slot_width, slot_length, corner_r);

        // Screw hole
        translate([0,0,-0.2])
            cylinder(h=thickness+0.4, d=screw_d+clearance);

        // Hex recess on top (for 6mm AF nut driver / captive feature)
        // Depth kept modest to preserve strength
        hex_depth = min(2.0, thickness*0.65);
        translate([0,0,thickness-hex_depth])
            cylinder(h=hex_depth+0.01, d=across_flats / cos(30), $fn=6);

        // Small top chamfer (edge break)
        if (top_chamfer > 0){
            translate([0,0,thickness-top_chamfer])
                linear_extrude(height=top_chamfer+0.01, scale=(slot_width-2*top_chamfer)/slot_width)
                    rounded_rect_2d(slot_width, slot_length, max(0, corner_r-top_chamfer));
        }
    }
}

tslot_nut();