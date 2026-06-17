$fn=96;

// Basic parametric component (mounting plate with two holes and a central boss)
plate_len = 80;
plate_wid = 40;
plate_thk = 6;

corner_r = 6;

hole_d = 6.5;
hole_edge_offset = 12;

boss_d = 22;
boss_h = 10;

center_hole_d = 10;

module rounded_plate(l, w, t, r){
    linear_extrude(height=t)
        offset(r=r)
            square([l-2*r, w-2*r], center=true);
}

difference(){
    union(){
        // Plate
        rounded_plate(plate_len, plate_wid, plate_thk, corner_r);

        // Central boss
        translate([0,0,plate_thk])
            cylinder(d=boss_d, h=boss_h);
    }

    // Two mounting holes through plate
    for (x = [-plate_len/2 + hole_edge_offset, plate_len/2 - hole_edge_offset])
        translate([x, 0, -1])
            cylinder(d=hole_d, h=plate_thk + boss_h + 2);

    // Center hole through boss and plate
    translate([0,0,-1])
        cylinder(d=center_hole_d, h=plate_thk + boss_h + 2);
}