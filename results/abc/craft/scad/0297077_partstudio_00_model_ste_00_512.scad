// Flanged cylindrical hub/bushing with central hex through-bore and 4 diamond recesses
// Bounding box target: 0.1 x 0.1 x 0.1 mm

$fn = 128;

// --- Bounding box (fixed) ---
bbox_X = 0.1;
bbox_Y = 0.1;
bbox_Z = 0.1;

// --- Main dimensions (must fit within bbox) ---
flange_D      = bbox_X;   // 0.1
flange_t      = 0.02;

body_D_major  = 0.06;     // near flange
body_D_minor  = 0.05;     // toward far end
body_L        = bbox_Z - flange_t; // 0.08 so total = 0.1

step_L        = 0.03;     // major OD length from flange side

// Small circumferential collar near far end (NOT a full flange)
collar_D      = 0.06;     // slightly larger than minor OD, smaller than flange
collar_L      = 0.01;

hex_AF        = 0.03;     // across flats
lead_in_h     = 0.004;

diamond_count      = 4;
diamond_radial_pos = 0.035;
diamond_w          = 0.012;
diamond_h          = 0.006;
diamond_depth      = 0.006;

eps = 0.0005; // small overlap/robustness

// --- Derived ---
total_H = flange_t + body_L;                 // = 0.1
hex_r   = hex_AF / sqrt(3);                  // circumradius for pointy-top hex
z0      = -total_H/2;                        // bottom of part
z_fl0   = z0;
z_fl1   = z0 + flange_t;
z_bd0   = z_fl1;
z_bd1   = z0 + total_H;

// --- Helpers ---
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

module diamond2d(w,h){
    polygon(points=[
        [ w/2, 0],
        [ 0,   h/2],
        [-w/2, 0],
        [ 0,  -h/2]
    ]);
}

// --- Solid outer shape (single wide flange on one end + stepped body + small collar) ---
module outer_solid(){
    union(){
        // Wide flange (one end only) at bottom
        translate([0,0,(z_fl0+z_fl1)/2])
            cylinder(d=flange_D, h=flange_t, center=true);

        // Major OD section (near flange) - overlaps flange slightly for robust union
        translate([0,0, z_bd0 + step_L/2 - eps/2])
            cylinder(d=body_D_major, h=step_L + eps, center=true);

        // Minor OD section (rest of body) - overlaps major section slightly
        translate([0,0, z_bd0 + step_L + (body_L-step_L)/2])
            cylinder(d=body_D_minor, h=(body_L-step_L) + eps, center=true);

        // Small circumferential collar near far end (a ring/step, not a flange)
        // Positioned to intersect the minor OD section by eps for a single solid.
        translate([0,0, z_bd1 - collar_L/2])
            cylinder(d=collar_D, h=collar_L + eps, center=true);
    }
}

// --- Subtractions ---
module hex_bore(){
    union(){
        // Through hex
        linear_extrude(height=total_H + 2*eps, center=true)
            hex2d(hex_r);

        // Lead-ins (simple conical chamfers) at both ends (cuts open to ends)
        translate([0,0, z_bd1 - lead_in_h/2])
            cylinder(h=lead_in_h + 2*eps, r1=hex_r*1.15, r2=0, center=true);

        translate([0,0, z_fl0 + lead_in_h/2])
            cylinder(h=lead_in_h + 2*eps, r1=hex_r*1.15, r2=0, center=true);
    }
}

module flange_diamond_recesses(){
    // Four diamond recesses on the OUTER flange face (bottom face at z_fl0),
    // cut upward into the flange by diamond_depth.
    recess_h = min(diamond_depth, flange_t - 2*eps);
    z_center = z_fl0 + recess_h/2 + eps; // inside flange, not coplanar

    for(i=[0:diamond_count-1]){
        rotate([0,0,i*360/diamond_count])
            translate([diamond_radial_pos, 0, z_center])
                linear_extrude(height=recess_h + 2*eps, center=true)
                    diamond2d(diamond_w, diamond_h);
    }
}

// --- Final ---
difference(){
    outer_solid();
    union(){
        hex_bore();
        flange_diamond_recesses();
    }
}