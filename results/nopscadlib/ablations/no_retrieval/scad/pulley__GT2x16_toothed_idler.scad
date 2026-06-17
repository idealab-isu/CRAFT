// Timing pulley (simplified): 16 teeth, 9.75mm pitch diameter
// Structural fix: add a clearly toothed outer profile (16 teeth) around the circumference,
// keep everything as one connected solid, and keep pitch diameter as a verifiable parameter.
//
// Notes:
// - Teeth are simple trapezoidal protrusions (blocky timing-pulley look).
// - Pitch diameter is the circle passing through the tooth mid-height (approx by construction).
// - All translate() values are formula-based; overlaps ensure watertight unions.

$fn = 220;

// -------------------- Parameters --------------------
tooth_count     = 16;     // required
pitch_diameter  = 9.75;   // required (pitch circle diameter)
pulley_width    = 10;

tooth_height    = 1.5;    // radial height of tooth
tooth_tip_width = 0.9;    // tangential width at tooth tip
tooth_root_width= 1.6;    // tangential width at tooth root
tooth_overlap   = 1.0;    // sinks into body to guarantee union (1-2mm)

bore_diameter   = 5;

hub_diameter    = 14;
hub_length      = 12;

flange_diameter = 16;
flange_thickness= 1;

set_screw_diameter = 3;
set_screw_z_offset = 0;

keyway_width    = 2;
keyway_depth    = 1;
keyway_length   = 10;

chamfer_size    = 0.6;

// -------------------- Derived --------------------
eps = 0.15;

pitch_r = pitch_diameter/2;
tooth_pitch = PI * pitch_diameter / tooth_count;

// Keep tooth widths from overlapping at small diameters
tooth_root_w = min(tooth_root_width, 0.90 * tooth_pitch);
tooth_tip_w  = min(tooth_tip_width,  0.75 * tooth_pitch);

// Construct body radius so that the pitch circle lies ~mid-tooth height.
// Tooth spans [base .. base+tooth_height], pitch at base + tooth_height/2.
// Base radius is (body_r - tooth_overlap) because tooth is sunk into body by tooth_overlap.
body_r = max(0.1, pitch_r - (tooth_height/2) + tooth_overlap);

// -------------------- Modules --------------------
module pulley_body() {
    cylinder(h=pulley_width, r=body_r, center=true);
}

module hub() {
    cylinder(h=hub_length, r=hub_diameter/2, center=true);
}

module flange(zsign=1) {
    // Flange touches pulley body with slight overlap (eps)
    translate([0,0, zsign*(pulley_width/2 + flange_thickness/2 - eps)])
        cylinder(h=flange_thickness, r=flange_diameter/2, center=true);
}

module tooth_2d() {
    // Trapezoid with height in +Y (radial outward after placement)
    polygon(points=[
        [-tooth_root_w/2, 0],
        [ tooth_root_w/2, 0],
        [ tooth_tip_w/2,  tooth_height],
        [-tooth_tip_w/2,  tooth_height]
    ]);
}

module tooth_3d() {
    // Place tooth so its base starts inside the body by tooth_overlap.
    // Base radius = body_r - tooth_overlap
    // Tip radius  = body_r - tooth_overlap + tooth_height
    rotate([0,0,90])  // make +Y point along +X after translate (radial)
        translate([body_r - tooth_overlap, 0, 0])
            linear_extrude(height=pulley_width + 2*eps, center=true)
                tooth_2d();
}

module teeth() {
    for (i=[0:tooth_count-1])
        rotate([0,0, i*360/tooth_count])
            tooth_3d();
}

module center_bore() {
    // Ensure bore clears entire union stack
    cylinder(h=max(hub_length, pulley_width) + 6*eps, r=bore_diameter/2, center=true);
}

module set_screw_hole() {
    // Through hub (X direction), centered in Z by offset
    translate([0,0,set_screw_z_offset])
        rotate([0,90,0])
            cylinder(h=hub_diameter + 6*eps, r=set_screw_diameter/2, center=true);
}

module keyway() {
    // Cut starts at bore radius and extends outward by keyway_depth
    translate([bore_diameter/2 + keyway_depth/2, 0, 0])
        cube([keyway_depth + 4*eps, keyway_width, keyway_length], center=true);
}

module chamfer_cone(zsign=1) {
    // Simple subtractive chamfer at hub ends
    translate([0,0, zsign*(hub_length/2 - chamfer_size/2)])
        cylinder(
            h=chamfer_size + 4*eps,
            r1=hub_diameter/2 + chamfer_size,
            r2=hub_diameter/2 - chamfer_size,
            center=true
        );
}

module pulley_solid() {
    union() {
        // One connected solid: hub overlaps pulley body; teeth overlap body; flanges overlap body.
        hub();
        pulley_body();
        teeth();
        flange(1);
        flange(-1);
    }
}

// -------------------- Final --------------------
difference() {
    pulley_solid();

    // Subtractions
    center_bore();
    set_screw_hole();
    keyway();
    chamfer_cone(1);
    chamfer_cone(-1);
}