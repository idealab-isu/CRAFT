$fn = 64;

size = 15;
length = 40;

bore_d = 3.3;

inner_chamber = 5.5;          // square
slot_opening = 6.2;           // at outer face
slot_channel = 9.5;           // internal channel width
lip_thickness = 1.0;          // depth from face to open up to channel
spar_thickness = 0.9;         // thickness between inner chamber and channel
corner_fillet = 0.5;

eps = 0.01;

module rounded_square_2d(w, r){
    // r-clamped
    rr = min(r, w/2 - eps);
    minkowski(){
        square([w-2*rr, w-2*rr], center=true);
        circle(r=rr);
    }
}

module profile_2d(){
    difference(){
        // Outer body with corner fillet
        rounded_square_2d(size, corner_fillet);

        // Central square inner chamber
        square([inner_chamber, inner_chamber], center=true);

        // Central round bore
        circle(d=bore_d);

        // 4 T-slots (N, E, S, W)
        for (a = [0, 90, 180, 270]){
            rotate(a){
                // Slot internal channel (starts after lip thickness from outer face)
                translate([0, size/2 - lip_thickness - ( (size/2 - lip_thickness) - (inner_chamber/2 + spar_thickness) )/2])
                    square([slot_channel, (size/2 - lip_thickness) - (inner_chamber/2 + spar_thickness)], center=true);

                // Slot opening (through lip region up to outer face)
                translate([0, size/2 - lip_thickness/2])
                    square([slot_opening, lip_thickness + eps], center=true);
            }
        }
    }
}

module extrusion(len){
    linear_extrude(height=len, center=true, convexity=10)
        profile_2d();
}

extrusion(length);