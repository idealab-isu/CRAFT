$fn = 96;

// Target: linear bearing block for 8.0mm shaft
// Block size: 42.0mm x 36.0mm (X x Y)

// ---------------- Parameters ----------------
shaft_d = 8.0;                 // shaft bore
clearance = 0.4;               // bore clearance
bore_d = shaft_d + clearance;

block_x = 42.0;
block_y = 36.0;
block_z = 20.0;

mount_d = 4.0;
edge_offset_x = 8.0;           // from X edges
edge_offset_y = 8.0;           // from Y edges

// Bearing housing features (typical look)
boss_d = 18.0;                 // raised circular boss around bore
boss_h = 4.0;

counterbore_d = 7.5;           // shallow counterbore for screw heads
counterbore_h = 3.0;

fillet_r = 2.0;                // simple corner rounding via hull of cylinders

// Visual/structural inserts (must be physically attached)
insert_overlap = 1.2;          // 1–2mm overlap to guarantee fusion
center_insert_d = 16.0;        // visual "bearing insert" OD (blue)
center_insert_h = 6.0;         // height of blue insert above top face

corner_insert_od = 10.0;       // visual bushing OD (orange)
corner_insert_h  = 4.0;        // height of orange bushing above top face

// ---------------- Helpers ----------------
module rounded_block(size=[10,10,10], r=1) {
    x = size[0]; y = size[1]; z = size[2];
    r2 = min(r, min(x,y)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(x/2 - r2), sy*(y/2 - r2), 0])
                cylinder(h=z, r=r2, center=true);
    }
}

// ---------------- Model ----------------
module bearing_block() {

    // Precompute top face Z for consistent attachment math
    top_z = block_z/2;

    difference() {
        // ONE connected solid: base + top boss + inserts all fused via overlap
        union() {
            // Main body
            rounded_block([block_x, block_y, block_z], fillet_r);

            // Top boss (connected by overlap into main body)
            translate([0, 0, top_z + boss_h/2 - insert_overlap])
                cylinder(h=boss_h, d=boss_d, center=true);

            // Central cylindrical bearing insert (blue) - MUST be attached
            // Overlaps into boss/body by insert_overlap
            translate([0, 0, top_z + center_insert_h/2 - insert_overlap])
                cylinder(h=center_insert_h, d=center_insert_d, center=true);

            // Four corner bushings/fastener inserts (orange) - MUST be attached
            // Overlap into top face by insert_overlap
            for (sx = [-1, 1], sy = [-1, 1]) {
                x_pos = sx * (block_x/2 - edge_offset_x);
                y_pos = sy * (block_y/2 - edge_offset_y);

                translate([x_pos, y_pos, top_z + corner_insert_h/2 - insert_overlap])
                    cylinder(h=corner_insert_h, d=corner_insert_od, center=true);
            }
        }

        // Shaft bore through entire block + boss + central insert (Z axis)
        cylinder(h=block_z + boss_h + center_insert_h + 4, d=bore_d, center=true);

        // Mounting through-holes + top counterbores (cut through inserts too)
        for (sx = [-1, 1], sy = [-1, 1]) {
            x_pos = sx * (block_x/2 - edge_offset_x);
            y_pos = sy * (block_y/2 - edge_offset_y);

            // Through hole
            translate([x_pos, y_pos, 0])
                cylinder(h=block_z + boss_h + corner_insert_h + 4, d=mount_d, center=true);

            // Counterbore from top face (ensure it reaches into the orange insert)
            translate([x_pos, y_pos, top_z - counterbore_h/2 + 0.01])
                cylinder(h=counterbore_h + 0.02, d=counterbore_d, center=true);
        }
    }
}

bearing_block();