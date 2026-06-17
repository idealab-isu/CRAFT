$fn=96;

// Bi-metal saw blade (sheet model)
blade_len = 300;          // mm
blade_height = 20;        // mm
blade_thickness = 0.9;    // mm (sheet thickness)

tooth_pitch = 3.0;        // mm (distance between tooth tips)
tooth_height = 3.0;       // mm (from gullet to tip)
tooth_set = 0.25;         // mm (alternating lateral set)
tooth_tip_flat = 0.35;    // mm (flat at tooth tip)

back_radius = 2.0;        // mm (rounded back edge)
end_round = 6.0;          // mm (rounded ends)

bimetal_edge_height = 4.0; // mm (hardened tooth strip height)
bimetal_offset = 0.0;      // mm (offset from bottom edge)

// Small mounting holes (optional, typical hacksaw blade)
holes_enabled = true;
hole_d = 6.5;
hole_edge_margin = 12;     // from ends
hole_y = blade_height*0.55; // vertical position

module rounded_rect_2d(L, H, r){
    r2 = min(r, min(L,H)/2);
    hull(){
        translate([r2, r2]) circle(r=r2);
        translate([L-r2, r2]) circle(r=r2);
        translate([r2, H-r2]) circle(r=r2);
        translate([L-r2, H-r2]) circle(r=r2);
    }
}

module blade_outline_2d(){
    // Base body with rounded ends and rounded back
    // We'll create a rounded rectangle then carve the tooth edge later.
    rounded_rect_2d(blade_len, blade_height, end_round);
}

module tooth_profile_2d(pitch, h, tip_flat){
    // A single tooth as a trapezoid/triangle with a flat tip.
    // Local coordinates: x in [0,pitch], y from 0 (gullet line) to h (tip)
    // Tooth leans slightly forward by shifting tip.
    lean = pitch*0.18;
    tipw = min(tip_flat, pitch*0.6);
    polygon(points=[
        [0,0],
        [pitch,0],
        [pitch - lean - tipw/2, h],
        [pitch - lean + tipw/2, h]
    ]);
}

module teeth_cutout_2d(){
    // Create a sawtooth cutout along the bottom edge by subtracting triangles
    n = floor(blade_len/tooth_pitch);
    for(i=[0:n-1]){
        x0 = i*tooth_pitch;
        translate([x0, 0])
            tooth_profile_2d(tooth_pitch, tooth_height, tooth_tip_flat);
    }
}

module blade_2d(){
    difference(){
        blade_outline_2d();

        // Round the back edge slightly by subtracting a thin strip with fillet effect
        // (approximate by subtracting a rounded rectangle inset from top)
        // Actually, create a back radius by intersecting with a rounded rect inset.
        // We'll do it via intersection outside this module; keep simple here.

        // Teeth: subtract from bottom edge to create gullets
        // We subtract the tooth shapes from the body, leaving tooth tips at y=tooth_height.
        // To make teeth protrude, we instead subtract gullets above the bottom line:
        // We'll subtract inverted teeth starting at y=tooth_height, leaving tips at y=0.
    }
}

module blade_with_teeth_2d(){
    // Build body then carve gullets so teeth protrude downward.
    // Define a "tooth band" region at bottom where teeth exist.
    difference(){
        blade_outline_2d();

        // Carve gullets: subtract triangles that start at y=tooth_height and go down to y=0
        // This leaves material below y=tooth_height shaped as teeth.
        n = floor(blade_len/tooth_pitch);
        for(i=[0:n-1]){
            x0 = i*tooth_pitch;
            // Gullet shape: triangle/trapezoid removed from the band above the tooth tips
            // We'll remove a mirrored tooth profile positioned so its tip is at y=tooth_height.
            translate([x0, tooth_height])
                mirror([0,1,0])
                    tooth_profile_2d(tooth_pitch, tooth_height, tooth_tip_flat);
        }

        // Optional mounting holes
        if(holes_enabled){
            translate([hole_edge_margin, hole_y]) circle(d=hole_d);
            translate([blade_len-hole_edge_margin, hole_y]) circle(d=hole_d);
        }
    }
}

module bimetal_strip_2d(){
    // Strip along the toothed edge (bottom), representing bi-metal welded edge
    translate([0, bimetal_offset])
        square([blade_len, bimetal_edge_height], center=false);
}

module blade_3d(){
    // Main blade body
    linear_extrude(height=blade_thickness, center=true, convexity=10)
        blade_with_teeth_2d();
}

module bimetal_3d(){
    // Slightly proud strip (very small thickness difference)
    strip_th = blade_thickness*0.15;
    translate([0,0,blade_thickness/2 - strip_th/2])
        linear_extrude(height=strip_th, center=true, convexity=5)
            intersection(){
                blade_with_teeth_2d();
                bimetal_strip_2d();
            }
}

module tooth_set_warp(){
    // Approximate alternating tooth set by adding tiny lateral wedges at tooth tips.
    // This is a visual cue; not physically accurate.
    n = floor(blade_len/tooth_pitch);
    for(i=[0:n-1]){
        dir = (i%2==0) ? 1 : -1;
        x0 = i*tooth_pitch;
        // Place a small prism near the tooth tip region (bottom)
        tip_len = tooth_pitch*0.55;
        tip_h = tooth_height*0.75;
        translate([x0 + tooth_pitch*0.25, tooth_height*0.15, 0])
            rotate([0,0,0])
                linear_extrude(height=blade_thickness, center=true, convexity=3)
                    polygon(points=[
                        [0,0],
                        [tip_len,0],
                        [tip_len, tip_h],
                        [0, tip_h]
                    ]);
        // Then shear it sideways by scaling in X with Y?  lacks shear; emulate by hull of shifted copies.
        // We'll instead create a tiny offset "cap" at the very bottom edge.
        translate([x0 + tooth_pitch*0.35, 0.0, dir*(tooth_set)])
            cube([tooth_pitch*0.3, tooth_height*0.35, blade_thickness], center=false);
    }
}

module model(){
    // Base blade + bimetal strip
    color([0.75,0.75,0.78]) blade_3d();
    color([0.55,0.55,0.58]) bimetal_3d();

    // Optional subtle tooth set cue (comment out if undesired)
    // color([0.70,0.70,0.72,0.35]) tooth_set_warp();
}

model();