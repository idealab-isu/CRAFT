// Dimension-calibrated (target: 0.08 x 0.09 x 0.09 mm)
scale([0.727273, 0.710744, 0.669421])
{
// Textured studded micro-cube with pyramidal/diamond bosses on each face
// Bounding box target: 0.1 x 0.1 x 0.1 mm

$fn = 4; // faceted "diamond" look for pyramids

// Overall size (exact 0.1mm cube)
block_x = 0.1;
block_y = 0.1;
block_z = 0.1;

// Boss geometry
boss_h = 0.012;
boss_base = 0.020;
boss_top  = 0.001;   // near-point apex
boss_offset_xy = 0.030; // corner-adjacent placement on faces
center_boss_scale = 0.65;

// Extra small edge/corner protrusions (subtle)
edge_boss_scale = 0.45;
edge_boss_h_scale = 0.75;

// Connectivity / overlap (ensures one connected solid)
boss_overlap = 0.0015;

// Small edge chamfer (keeps cube-like but slightly softened)
edge_chamfer = 0.0015;

// ---------- Helpers ----------
module pyramid_boss(h, base, top) {
    // 4-sided pyramid/frustum (diamond-like)
    cylinder(h=h, r1=base/2, r2=top/2, center=true, $fn=4);
}

module chamfered_block(size=[block_x, block_y, block_z], c=edge_chamfer) {
    // Chamfer by subtracting small corner cubes (keeps single solid)
    difference() {
        cube(size, center=true);
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]) {
            translate([sx*(size[0]/2 - c), sy*(size[1]/2 - c), sz*(size[2]/2 - c)])
                rotate([45,45,45])
                    cube([2*c,2*c,2*c], center=true);
        }
    }
}

// Place a boss on a given face with correct outward normal and guaranteed overlap
module place_boss_on_face(face="zp", u=0, v=0, s=1.0, h=boss_h, base=boss_base, top=boss_top) {
    // face: zp, zm, xp, xm, yp, ym
    // u,v are in-plane offsets (x/y for z faces, y/z for x faces, x/z for y faces)
    if (face=="zp") {
        translate([u, v, block_z/2 + h/2 - boss_overlap])
            scale([s,s,s]) pyramid_boss(h, base, top);
    } else if (face=="zm") {
        translate([u, v, -block_z/2 - h/2 + boss_overlap])
            rotate([180,0,0])
                scale([s,s,s]) pyramid_boss(h, base, top);
    } else if (face=="xp") {
        translate([block_x/2 + h/2 - boss_overlap, u, v])
            rotate([0,-90,0])
                scale([s,s,s]) pyramid_boss(h, base, top);
    } else if (face=="xm") {
        translate([-block_x/2 - h/2 + boss_overlap, u, v])
            rotate([0,90,0])
                scale([s,s,s]) pyramid_boss(h, base, top);
    } else if (face=="yp") {
        translate([u, block_y/2 + h/2 - boss_overlap, v])
            rotate([90,0,0])
                scale([s,s,s]) pyramid_boss(h, base, top);
    } else if (face=="ym") {
        translate([u, -block_y/2 - h/2 + boss_overlap, v])
            rotate([-90,0,0])
                scale([s,s,s]) pyramid_boss(h, base, top);
    }
}

module face_pattern(face) {
    // 4 corner-adjacent bosses + smaller central boss
    union() {
        // central boss
        place_boss_on_face(face, 0, 0, center_boss_scale);

        // four corner-adjacent bosses
        for (a=[-1,1], b=[-1,1])
            place_boss_on_face(face, a*boss_offset_xy, b*boss_offset_xy, 1.0);
    }
}

module extra_edge_protrusions() {
    // Small additional protrusions near some edges/corners (subtle, not star-like)
    // Put them on a subset of edges to mimic "additional protrusions visible near some edges/corners"
    eh = boss_h * edge_boss_h_scale;
    eb = boss_base * edge_boss_scale;
    et = boss_top;

    // Along +Z top edges (midpoints)
    place_boss_on_face("zp",  block_x*0.25, 0, 0.55, eh, eb, et);
    place_boss_on_face("zp", -block_x*0.25, 0, 0.55, eh, eb, et);
    place_boss_on_face("zp", 0,  block_y*0.25, 0.55, eh, eb, et);
    place_boss_on_face("zp", 0, -block_y*0.25, 0.55, eh, eb, et);

    // Along -Z bottom edges (fewer)
    place_boss_on_face("zm",  block_x*0.25, 0, 0.50, eh, eb, et);
    place_boss_on_face("zm", 0, -block_y*0.25, 0.50, eh, eb, et);

    // A couple on side faces near edges
    place_boss_on_face("xp", 0,  block_z*0.25, 0.50, eh, eb, et);
    place_boss_on_face("ym", -block_x*0.25, 0, 0.50, eh, eb, et);
}

// ---------- Final solid ----------
union() {
    chamfered_block([block_x, block_y, block_z], edge_chamfer);

    // Boss patterns on all 6 faces (includes central boss on each face)
    face_pattern("zp");
    face_pattern("zm");
    face_pattern("xp");
    face_pattern("xm");
    face_pattern("yp");
    face_pattern("ym");

    // Additional subtle edge/corner protrusions
    extra_edge_protrusions();
}
}
