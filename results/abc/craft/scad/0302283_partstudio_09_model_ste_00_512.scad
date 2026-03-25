// Dimension-calibrated (target: 0.25 x 0.07 x 0.09 mm)
scale([0.840000, 1.112500, 0.797623])
{
$fn = 64;

// Target bounding box (approx, in mm)
bbox_L = 0.30;
bbox_W = 0.10;
bbox_H = 0.10;

// Sheet metal + bracket geometry
t        = 0.006;   // sheet thickness
leg_L    = bbox_L;  // length along X
leg_H    = 0.084;   // vertical plate height along Z
flange_W = 0.030;   // flange depth along Y
bend_r   = 0.010;   // bend radius (visual)

// Pair spacing and connection bridge (to ensure ONE connected solid)
bracket_gap = 0.010;  // clear gap between inner faces of the two vertical plates
bridge_t    = 0.002;  // thin connector thickness (kept small)

// Holes (4-hole rectangular pattern on each vertical plate)
hole_d       = 0.008;
hole_pitch_x = 0.060;
hole_pitch_z = 0.030;
hole_edge_x  = 0.030;
hole_edge_z  = 0.020;

// Flange slot near bend (centered in X, near bend in Y)
slot_L = 0.020;
slot_W = 0.008;
slot_offset_from_bend = 0.004;

// Robust boolean overlap (small, relative to tiny model)
overlap = 0.001;

// --- Derived placement (recalculated so parts TOUCH with slight overlap) ---
// Coordinate convention:
// X = long axis (elongated)
// Y = bracket-to-bracket separation (mirrored pair)
// Z = vertical plate height

// Vertical plates: inner faces separated by bracket_gap
y_plate_center_L =  (bracket_gap/2 + t/2);
y_plate_center_R = -(bracket_gap/2 + t/2);

// Flanges are perpendicular to plates and extend OUTWARD from each plate.
// Place flange so its inner edge slightly overlaps the plate outer face.
y_flange_center_L =  y_plate_center_L + (t/2 + flange_W/2) - overlap;
y_flange_center_R =  y_plate_center_R - (t/2 + flange_W/2) + overlap;

// Bend cylinder center: at inside corner between plate outer face and flange inner edge
y_bend_center_L =  y_plate_center_L + (t/2) + (bend_r - overlap);
y_bend_center_R =  y_plate_center_R - (t/2) - (bend_r - overlap);
z_bend_center   =  (t/2) + (bend_r - overlap);

// --- Geometry modules ---
module vertical_plate(yc) {
    // Plate lies in XZ, thickness along Y
    translate([0, yc, leg_H/2])
        cube([leg_L, t, leg_H], center=true);
}

module horizontal_flange(yc) {
    // Flange lies in XY, thickness along Z
    translate([0, yc, t/2])
        cube([leg_L, flange_W, t], center=true);
}

module bend_radius(yc) {
    // Visual fillet along X at the inside corner
    translate([0, yc, z_bend_center])
        rotate([0, 90, 0])
            cylinder(r=bend_r, h=leg_L, center=true);
}

module hole_at(xc, yc, zc) {
    // Drill through the vertical plate thickness (along Y)
    translate([xc, yc, zc])
        rotate([90, 0, 0])
            cylinder(d=hole_d, h=t + 6*overlap, center=true);
}

module flange_slot(yc, side=1) {
    // side=+1 for left (positive Y), side=-1 for right (negative Y)
    // Slot near bend: close to inner edge of flange (toward plate)
    y_inner_edge   = yc - side*(flange_W/2);
    y_slot_center  = y_inner_edge + side*(slot_offset_from_bend + slot_W/2);

    translate([0, y_slot_center, t/2])
        cube([slot_L, slot_W, t + 6*overlap], center=true);
}

module bracket_one(yc_plate, yc_flange, yc_bend, side=1) {
    difference() {
        union() {
            // Clear L-profile: vertical plate + perpendicular flange + bend radius
            vertical_plate(yc_plate);
            horizontal_flange(yc_flange);
            bend_radius(yc_bend);
        }

        // 4 through-holes on vertical plate (2x2 rectangular pattern)
        // Centered in Z within the plate height, and inset from X ends.
        x0 = -leg_L/2 + hole_edge_x;
        x1 = x0 + hole_pitch_x;

        z0 = hole_edge_z;
        z1 = z0 + hole_pitch_z;

        hole_at(x0, yc_plate, z0);
        hole_at(x1, yc_plate, z0);
        hole_at(x0, yc_plate, z1);
        hole_at(x1, yc_plate, z1);

        // Central slot on flange near bend
        flange_slot(yc_flange, side);
    }
}

module connector_bridge() {
    // Thin bridge inside the gap, near the bend region, to make the whole model ONE connected solid.
    // It must overlap both plates in Y and overlap the flange plane in Z.
    bridge_x = slot_L;                         // small in X, centered
    bridge_y = bracket_gap + 2*t + 8*overlap;  // spans gap + overlaps into both plates
    bridge_z = bridge_t + 4*overlap;           // ensure overlap into flange/plate region

    // Place at the inside corner region (near bend), slightly above flange plane for overlap
    translate([0, 0, t/2 + bridge_z/2 - 2*overlap])
        cube([bridge_x, bridge_y, bridge_z], center=true);
}

module complete_model() {
    // Build pair + connector, then clip to bounding box
    intersection() {
        union() {
            // Pair of mirrored L-shaped brackets (two distinct parts)
            bracket_one(y_plate_center_L, y_flange_center_L, y_bend_center_L, side=+1);
            bracket_one(y_plate_center_R, y_flange_center_R, y_bend_center_R, side=-1);

            // Connector to keep as ONE connected solid
            connector_bridge();
        }

        // Bounding box clip (centered)
        translate([0, 0, bbox_H/2])
            cube([bbox_L, bbox_W, bbox_H], center=true);
    }
}

complete_model();
}
