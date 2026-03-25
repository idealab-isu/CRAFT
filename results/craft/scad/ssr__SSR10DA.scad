$fn = 64;

// Target envelope (module)
length = 58.0;   // X
width  = 45.0;   // Y
height = 33.0;   // Z

// Rounded rectangle prism (centered)
module rbox(size=[10,10,10], r=1.5, center=true){
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
        linear_extrude(height=z)
            offset(r=r)
                square([x-2*r, y-2*r], center=false);
}

// Simple chamfered cylinder (for corner "screw head" look)
module chamfer_cyl(d=6, h=3, cham=0.8){
    // one connected solid
    union(){
        cylinder(d=d, h=h-cham, center=false);
        translate([0,0,h-cham])
            cylinder(d1=d, d2=d-2*cham, h=cham, center=false);
    }
}

module ssr_module(){
    // Split height into base + top terminal block so total = height
    base_h = 24.0;
    top_h  = height - base_h; // 9.0

    // Base housing
    base_r = 2.2;

    // Top terminal block (smaller footprint, centered)
    top_x = 34.0;
    top_y = 26.0;
    top_r = 1.6;

    // Terminal bosses on top block (4)
    term_count = 4;
    term_pitch = 7.0;
    term_w = 5.2;
    term_d = 6.2;
    term_h = 3.2;

    // Mounting holes (through base)
    hole_d = 4.2;
    hole_z = base_h + 1.0;

    // Place mounting holes near corners (2 holes on one diagonal like the provided views)
    hole_edge_inset_x = 4.5;
    hole_edge_inset_y = 4.5;
    hole_x = length/2 - hole_edge_inset_x;
    hole_y = width/2  - hole_edge_inset_y;

    // Corner "screw head" bosses (visual SSR feature), kept within envelope
    boss_d = 7.2;
    boss_h = 2.2;
    boss_inset = 1.2; // from outer edges
    boss_x = length/2 - boss_inset - boss_d/2;
    boss_y = width/2  - boss_inset - boss_d/2;

    // Side ribs (heatsink-like suggestion), kept within width
    rib_count = 7;
    rib_w = 1.2;
    rib_h = 1.2;
    rib_len = length - 10.0;
    rib_z = -base_h/2 + 3.0 + rib_h/2;
    rib_y_inset = 0.8;

    // Faceplate recess (label area) - no text, just a recessed panel
    panel_inset = 1.0;
    panel_depth = 0.8;
    panel_r = 1.2;
    panel_x = length - 2*6.0;
    panel_y = width  - 2*6.0;

    // Small indicator holes on one side face (4), like the provided renders
    ind_count = 4;
    ind_pitch = 6.0;
    ind_d = 2.2;
    ind_x = length/2 - 6.0; // near right side
    ind_z0 = -2.0;          // centered-ish on base
    ind_span = (ind_count-1)*ind_pitch;

    // Terminal screw recesses (shallow) on bosses
    screw_d = 2.2;
    screw_h = 3.2;

    // Overlap to guarantee connectivity
    overlap = 0.8;

    difference(){
        union(){
            // Base housing
            rbox([length, width, base_h], r=base_r, center=true);

            // Bottom lip (detail)
            lip_h = 1.2;
            lip_inset = 1.2;
            translate([0,0,-base_h/2 + lip_h/2])
                rbox([length-2*lip_inset, width-2*lip_inset, lip_h], r=base_r, center=true);

            // Side ribs (both long sides)
            for(i=[0:rib_count-1]){
                x_pos = -rib_len/2 + (i+0.5)*rib_len/rib_count;
                rib_xlen = rib_len/rib_count*0.75;

                translate([x_pos, -width/2 + rib_y_inset + rib_w/2, rib_z])
                    cube([rib_xlen, rib_w, rib_h], center=true);

                translate([x_pos,  width/2 - rib_y_inset - rib_w/2, rib_z])
                    cube([rib_xlen, rib_w, rib_h], center=true);
            }

            // Top terminal block (connected)
            translate([0, 0, base_h/2 + top_h/2 - overlap])
                rbox([top_x, top_y, top_h], r=top_r, center=true);

            // Raised terminal bosses (connected)
            term_total_w = (term_count-1)*term_pitch;
            term_y = top_y/2 - term_d/2 - 2.0;
            for(t=[0:term_count-1]){
                tx = -term_total_w/2 + t*term_pitch;
                translate([tx, term_y, base_h/2 + top_h - term_h/2 - 0.8])
                    rbox([term_w, term_d, term_h], r=0.9, center=true);
            }

            // Corner screw-head bosses (visual), placed on two opposite corners
            // (matches the "two corners" look in the provided views)
            translate([ boss_x,  boss_y, -base_h/2 + boss_h - 0.2])
                chamfer_cyl(d=boss_d, h=boss_h, cham=0.9);
            translate([-boss_x, -boss_y, -base_h/2 + boss_h - 0.2])
                chamfer_cyl(d=boss_d, h=boss_h, cham=0.9);
        }

        // Faceplate recessed panel on the front face (Y+)
        translate([0, width/2 - panel_depth/2, 0])
            rbox([panel_x, panel_depth + 0.02, panel_y], r=panel_r, center=true);

        // Mounting holes through base (two holes on opposite corners)
        translate([ hole_x,  hole_y, 0])
            cylinder(d=hole_d, h=hole_z, center=true);
        translate([-hole_x, -hole_y, 0])
            cylinder(d=hole_d, h=hole_z, center=true);

        // Terminal screw recesses (shallow) on bosses
        term_total_w = (term_count-1)*term_pitch;
        term_y = top_y/2 - term_d/2 - 2.0;
        for(t=[0:term_count-1]){
            tx = -term_total_w/2 + t*term_pitch;
            translate([tx, term_y, base_h/2 + top_h - 1.6])
                cylinder(d=screw_d, h=screw_h, center=true);
        }

        // Side indicator holes (4) on the right side face (X+)
        for(i=[0:ind_count-1]){
            zpos = ind_z0 + (i*ind_pitch - ind_span/2);
            translate([length/2 - 0.01, 0, zpos])
                rotate([0,90,0])
                    cylinder(d=ind_d, h=2.2, center=true);
        }
    }
}

ssr_module();