// 20x80 aluminium extrusion profile (T-slot style), 100mm long
// One connected solid with visible side T-slots and an internal cavity.

$fn = 64;

// Overall dimensions
profile_W = 20.0;   // X (mm)
profile_H = 80.0;   // Y (mm)
length_L  = 100.0;  // Z (mm)

// Feature dimensions (kept conservative to ensure a connected shell)
wall_t        = 2.0;   // outer wall thickness
slot_open_w   = 6.0;   // slot mouth width at surface
slot_depth    = 2.5;   // depth of narrow mouth section
slot_inner_w  = 12.0;  // inner pocket width
slot_inner_d  = 7.0;   // total depth from surface to end of pocket

core_void_w   = 10.0;  // central void width
core_void_h   = 60.0;  // central void height

eps = 0.05;

// 2D cut shape for one T-slot, defined pointing outward along +X.
// IMPORTANT: It starts at x=0 (surface) and extends inward to +x.
module tslot_cut_2d() {
    polygon(points=[
        [0,            -slot_open_w/2],
        [slot_depth,   -slot_open_w/2],
        [slot_depth,   -slot_inner_w/2],
        [slot_inner_d, -slot_inner_w/2],
        [slot_inner_d,  slot_inner_w/2],
        [slot_depth,    slot_inner_w/2],
        [slot_depth,    slot_open_w/2],
        [0,             slot_open_w/2]
    ]);
}

// 2D cross-section of the extrusion
module extrusion_profile_2d() {
    difference() {
        // Outer boundary
        square([profile_W, profile_H], center=true);

        // Central cavity (keeps a connected shell)
        square([core_void_w, core_void_h], center=true);

        // Side T-slots: place the cut so its x=0 edge lies on the outer surface.
        // Right (+X): surface at x = +profile_W/2
        translate([profile_W/2 - slot_inner_d + eps, 0])
            tslot_cut_2d();

        // Left (-X): mirror and place on x = -profile_W/2
        mirror([1,0,0])
            translate([profile_W/2 - slot_inner_d + eps, 0])
                tslot_cut_2d();

        // Top (+Y): rotate so it points outward along +Y, then place on y = +profile_H/2
        rotate(90)
            translate([profile_H/2 - slot_inner_d + eps, 0])
                tslot_cut_2d();

        // Bottom (-Y)
        rotate(90)
            mirror([1,0,0])
                translate([profile_H/2 - slot_inner_d + eps, 0])
                    tslot_cut_2d();
    }
}

// 3D extrusion
color("Silver")
linear_extrude(height=length_L, center=true, convexity=10)
    extrusion_profile_2d();