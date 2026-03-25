// Dimension-calibrated (target: 0.06 x 0.01 x 0.07 mm)
scale([1.066677, 1.354454, 1.300218])
{
// U-shaped bent strap with two cylindrical end bosses and recessed hex sockets
// All dimensions in mm (very small part as requested)

$fn = 96;

// ---------------- Parameters ----------------
strap_thk = 0.01;           // Z thickness of strap
strap_w   = 0.006;          // strap width (in Y for legs, radial for bend)

leg_center_spacing = 0.048; // distance between leg centerlines (Y)
u_inner_R = 0.012;          // inner bend radius (to inner edge of strap)
leg_len   = 0.02;           // straight leg length from tangent to boss transition

boss_d   = 0.012;           // boss diameter
boss_len = 0.006;           // boss length along X

boss_transition_len = 0.002; // transition length from strap to boss

hex_AF    = 0.006;          // hex across flats
hex_depth = 0.004;          // socket depth into boss (along X from end face)
socket_lead_in = 0.001;     // small lead-in depth
chamfer_scale = 1.15;       // lead-in hex scale

overlap = 0.001;            // overlap to ensure connectivity / robust booleans

// Derived
hex_R = hex_AF / sqrt(3);        // circumradius for regular hex with given AF
u_center_R = u_inner_R + strap_w/2;

// ---------------- Helpers ----------------
module hex2d(r){
    polygon(points=[
        [ r, 0],
        [ r/2,  r*sqrt(3)/2],
        [-r/2,  r*sqrt(3)/2],
        [-r, 0],
        [-r/2, -r*sqrt(3)/2],
        [ r/2, -r*sqrt(3)/2]
    ]);
}

// U-bend: 180° ring sector (in XY) with rectangular cross-section (strap_w x strap_thk), centered at origin
module u_bend_flat(){
    // Make a 2D U-shaped band (annulus sector) then extrude to strap_thk
    linear_extrude(height=strap_thk, center=true)
    difference(){
        // outer half-disk
        intersection(){
            circle(r=u_inner_R + strap_w);
            // keep only y >= 0 half (U bend at +Y)
            translate([0, (u_inner_R + strap_w)/2, 0])
                square([2*(u_inner_R + strap_w) + 2*overlap, (u_inner_R + strap_w) + 2*overlap], center=true);
        }
        // inner half-disk
        intersection(){
            circle(r=u_inner_R);
            translate([0, u_inner_R/2, 0])
                square([2*u_inner_R + 2*overlap, u_inner_R + 2*overlap], center=true);
        }
    }
}

// Straight legs (rectangular strap) from bend tangent at y=0 to bosses at y = -(leg_len + transition + boss_len/2)
module legs_flat(){
    leg_total = leg_len + boss_transition_len + overlap;
    // Legs run along -Y from y=0
    translate([ leg_center_spacing/2, -leg_total/2 + overlap/2, 0])
        cube([strap_w, leg_total, strap_thk], center=true);
    translate([-leg_center_spacing/2, -leg_total/2 + overlap/2, 0])
        cube([strap_w, leg_total, strap_thk], center=true);
}

// Transition block to boss (widen in X to boss_d, keep strap_thk in Z)
module boss_transitions(){
    // Transition occupies last boss_transition_len of the leg near the boss
    y0 = -leg_len - boss_transition_len/2 + overlap/2;
    translate([ leg_center_spacing/2, y0, 0])
        cube([boss_d, boss_transition_len + overlap, strap_thk], center=true);
    translate([-leg_center_spacing/2, y0, 0])
        cube([boss_d, boss_transition_len + overlap, strap_thk], center=true);
}

// Boss cylinders at ends, axis along Y (end axis)
module bosses_raw(){
    y_boss_center = -(leg_len + boss_transition_len + boss_len/2 - overlap);
    translate([ leg_center_spacing/2, y_boss_center, 0])
        cylinder(r=boss_d/2, h=boss_len, center=true);
    translate([-leg_center_spacing/2, y_boss_center, 0])
        cylinder(r=boss_d/2, h=boss_len, center=true);
}

// Hex socket cut: recessed from the OUTER end face of each boss (negative Y end)
module hex_socket_cut(xpos){
    y_end = -(leg_len + boss_transition_len + boss_len - overlap); // outer end face (more negative)
    y_socket_center = y_end + hex_depth/2 - overlap/2;

    union(){
        // main hex prism (along Y)
        translate([xpos, y_socket_center, 0])
            linear_extrude(height=hex_depth + overlap, center=true)
                hex2d(hex_R);

        // lead-in at the mouth (slightly larger)
        translate([xpos, y_end + socket_lead_in/2 - overlap/2, 0])
            linear_extrude(height=socket_lead_in + overlap, center=true)
                scale([chamfer_scale, chamfer_scale]) hex2d(hex_R);
    }
}

// Full part (one connected solid)
module u_bracket(){
    difference(){
        union(){
            u_bend_flat();
            legs_flat();
            boss_transitions();
            bosses_raw();
        }
        // sockets in both bosses
        hex_socket_cut( leg_center_spacing/2);
        hex_socket_cut(-leg_center_spacing/2);
    }
}

u_bracket();
}
