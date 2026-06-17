$fn=96;

// Sellotape tape roll (adhesive tape on a cardboard core)

outer_d = 95;          // overall outer diameter of tape roll (mm)
inner_d = 38;          // inner diameter of cardboard core (mm)
width   = 50;          // tape width (mm)

core_wall = 2.5;       // cardboard wall thickness (mm)
tape_radial_thickness = (outer_d - inner_d)/2 - core_wall; // remaining radial thickness for tape

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h);
        translate([0,0,-0.2]) cylinder(d=id, h=h+0.4);
    }
}

module sellotape_roll(){
    // Tape body (slightly translucent)
    color([0.98, 0.98, 0.92, 0.35])
        ring(outer_d, inner_d + 2*core_wall, width);

    // Cardboard core
    color([0.78, 0.70, 0.55, 1.0])
        ring(inner_d + 2*core_wall, inner_d, width);

    // Subtle edge bevels for realism
    bevel = 1.2;
    color([0.98, 0.98, 0.92, 0.25])
    difference(){
        // outer bevel
        union(){
            translate([0,0,0]) cylinder(d=outer_d, h=bevel);
            translate([0,0,width-bevel]) cylinder(d=outer_d, h=bevel);
        }
        translate([0,0,-0.2]) cylinder(d=outer_d-2*bevel, h=width+0.4);
        translate([0,0,-0.2]) cylinder(d=inner_d + 2*core_wall, h=width+0.4);
    }
}

sellotape_roll();