$fn = 96;

// Bounding box (X x Y x Z)
W = 16.58;   // X (thickness)
L = 54.99;   // Y (length)
H = 20.11;   // Z (height)

// Hole location (near mid-length)
hole_center_x = 0.0;
hole_center_y = 0.0;
hole_center_z = 0.0;

// Hex through-hole (across flats)
hex_AF = 8.0;
hex_clearance = 0.2;

// Shallow V countersink on both faces (around the hex hole)
csk_depth_each_side = 1.0;
csk_extra_AF = 2.0;

// End corner chamfer/relief
end_chamfer = 2.0;     // chamfer size (mm)
end_chamfer_len = 3.0; // how far from each end along length (mm)

// Optional subtle overall edge chamfer
edge_chamfer = 0.0;

// Robust overlap for boolean ops (keeps cuts from being coplanar)
op_overlap = 1.2;

// --- Helpers ---
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for regular hex given across-flats

module hex_prism_x(af, len_x) {
    // Hex prism oriented along X (transverse through-hole)
    R = hex_R_from_AF(af);
    rotate([0, 90, 0])
        cylinder(h=len_x, r=R, $fn=6, center=true);
}

module v_countersink_x(af_small, af_large, depth_each_side) {
    // Two tapered hex frustums opening out at the +/-X faces
    Rsmall = hex_R_from_AF(af_small);
    Rlarge = hex_R_from_AF(af_large);

    // Make each frustum extend slightly past the face to avoid coplanar artifacts.
    // Place so the OUTER (large) end is at the face (x=±W/2), tapering inward.
    h = depth_each_side + op_overlap;
    inset = depth_each_side/2; // center of frustum measured from face inward

    union() {
        // +X face countersink (large at +X face)
        translate([ +W/2 - inset, 0, 0 ])
            rotate([0, 90, 0])
                cylinder(h=h, r1=Rlarge, r2=Rsmall, $fn=6, center=true);

        // -X face countersink (large at -X face)
        translate([ -W/2 + inset, 0, 0 ])
            rotate([0, 90, 0])
                cylinder(h=h, r1=Rsmall, r2=Rlarge, $fn=6, center=true);
    }
}

module end_corner_chamfers() {
    // Subtract 4 chamfer cuts per end (one per XZ corner), over end_chamfer_len in Y.
    cham = end_chamfer;
    leny = end_chamfer_len;

    // Oversize cutters so they fully intersect the body
    cut_x = 2*cham + 2*op_overlap;
    cut_z = 2*cham + 2*op_overlap;
    cut_y = leny + 2*op_overlap;

    module corner_cut(sx, sz, ysign) {
        // Position the cutter so it intersects the corner region at each end.
        // Rotate about Y so it creates a 45° chamfer in the XZ corner.
        translate([
            sx*(W/2 - cham/2),
            ysign*(L/2 - leny/2),
            sz*(H/2 - cham/2)
        ])
        rotate([0, 45, 0])
            cube([cut_x, cut_y, cut_z], center=true);
    }

    union() {
        // +Y end
        corner_cut(+1, +1, +1);
        corner_cut(+1, -1, +1);
        corner_cut(-1, +1, +1);
        corner_cut(-1, -1, +1);

        // -Y end
        corner_cut(+1, +1, -1);
        corner_cut(+1, -1, -1);
        corner_cut(-1, +1, -1);
        corner_cut(-1, -1, -1);
    }
}

module overall_edge_chamfers() {
    if (edge_chamfer > 0) {
        e = edge_chamfer;

        // Cut along XZ edges (running in Y)
        for (sx = [-1, 1], sz = [-1, 1]) {
            translate([ sx*(W/2 - e/2), 0, sz*(H/2 - e/2) ])
                rotate([0, 45, 0])
                    cube([2*e + 2*op_overlap, L + 2*op_overlap, 2*e + 2*op_overlap], center=true);
        }

        // Cut along XY edges (running in Z)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([ sx*(W/2 - e/2), sy*(L/2 - e/2), 0 ])
                rotate([45, 0, 0])
                    cube([2*e + 2*op_overlap, 2*e + 2*op_overlap, H + 2*op_overlap], center=true);
        }

        // Cut along YZ edges (running in X)
        for (sy = [-1, 1], sz = [-1, 1]) {
            translate([ 0, sy*(L/2 - e/2), sz*(H/2 - e/2) ])
                rotate([0, 0, 45])
                    cube([W + 2*op_overlap, 2*e + 2*op_overlap, 2*e + 2*op_overlap], center=true);
        }
    }
}

// --- Main model ---
module spacer_block() {
    difference() {
        // Main bar
        cube([W, L, H], center=true);

        // End chamfer/relieved corners (both ends)
        end_corner_chamfers();

        // Optional overall edge chamfers
        overall_edge_chamfers();

        // Transverse hex through-hole + shallow V countersinks on both faces
        translate([hole_center_x, hole_center_y, hole_center_z]) {
            // Through-hole: ensure it fully passes through X thickness
            hex_prism_x(hex_AF + hex_clearance, W + 2*op_overlap);

            // V-shaped countersink/counterbore on both +/-X faces
            v_countersink_x(
                hex_AF + hex_clearance,
                hex_AF + hex_clearance + csk_extra_AF,
                csk_depth_each_side
            );
        }
    }
}

spacer_block();