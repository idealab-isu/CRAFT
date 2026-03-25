// Dimension-calibrated (target: 0.15 x 0.13 x 0.08 mm)
scale([0.689371, 1.206502, 1.380693])
{
// Compact offset mounting bracket with rounded-rectangle base and smooth curved elbow arm
// Units: mm (very small part; bbox target ~0.2 x 0.1 x 0.1)

// ---------- Parameters ----------
bbox_L = 0.20;
bbox_W = 0.10;
bbox_H = 0.10;

base_L = 0.085;
base_W = 0.060;
base_H = 0.030;
base_corner_r = 0.012;

arm_thk = 0.018;      // Z thickness of arm
arm_width = 0.030;    // Y width of arm
elbow_R = 0.030;      // bend radius (centerline-ish)

arm_rise_Z = 0.050;   // vertical rise from base top to arm top run center
arm_reach_X = 0.060;  // horizontal reach from base side to pad

pad_L = 0.030;
pad_W = 0.040;
pad_H = 0.020;

boss1_L = 0.020;
boss1_W = 0.030;
boss1_H = 0.010;

boss2_L = 0.018;
boss2_W = 0.028;
boss2_H = 0.010;

overlap = 0.001;
micro_fillet_r = 0.0015;

$fn = 48;

// ---------- Helpers ----------
module rounded_rect_prism(L, W, H, r) {
    // Robust rounded rectangle via hull of 4 cylinders
    r2 = min(r, min(L, W)/2 - 0.0001);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r2), sy*(W/2 - r2), 0])
                cylinder(r=r2, h=H, center=false);
    }
}

module arm_path_2d() {
    // 2D centerline path in XZ plane: vertical up, quarter-arc, horizontal out
    // Start at (0,0) at base top surface.
    // End at (elbow_R + arm_reach_X, arm_rise_Z)
    // Ensure rise is compatible with elbow_R
    rise = max(arm_rise_Z, elbow_R + 0.0001);
    vlen = rise - elbow_R;

    // Build a polyline with arc approximation
    pts = concat(
        [[0, 0], [0, vlen]],
        [for (a = [0:6:90]) [elbow_R*(1 - cos(a)), vlen + elbow_R*sin(a)]],
        [[elbow_R + arm_reach_X, rise]]
    );

    polygon(points=pts);
}

module arm_solid() {
    // Sweep a rectangle (arm_width x arm_thk) along the 2D path by linear_extrude in Y,
    // then thicken in Z by offsetting the 2D path and extruding.
    // Approach: create 2D "tube" in XZ by offsetting the centerline path, then extrude in Y.
    rise = max(arm_rise_Z, elbow_R + 0.0001);
    vlen = rise - elbow_R;

    // Centerline polyline points (XZ)
    pts = concat(
        [[0, 0], [0, vlen]],
        [for (a = [0:6:90]) [elbow_R*(1 - cos(a)), vlen + elbow_R*sin(a)]],
        [[elbow_R + arm_reach_X, rise]]
    );

    // Make a 2D thickened path by hulling circles along the polyline
    module thick_path_2d(r) {
        hull() {
            for (p = pts)
                translate([p[0], p[1]]) circle(r=r);
        }
    }

    // Extrude along Y to get arm width; place so Y is centered at 0
    translate([0, 0, base_H])  // start at base top
        translate([0, 0, 0])
            rotate([90, 0, 0])  // extrude in Y by rotating XZ->XY then extruding Z
                linear_extrude(height=arm_width, center=true)
                    thick_path_2d(arm_thk/2);
}

module end_pad() {
    // Pad at end of arm, connected with slight overlap
    rise = max(arm_rise_Z, elbow_R + 0.0001);
    end_x = elbow_R + arm_reach_X;

    // Place pad so its top roughly aligns with arm top run; overlap into arm
    translate([ (base_L/2) + end_x - pad_L/2 + overlap, 0, base_H + rise - arm_thk/2 - pad_H/2 + overlap ])
        cube([pad_L, pad_W, pad_H], center=true);
}

module bosses() {
    rise = max(arm_rise_Z, elbow_R + 0.0001);
    end_x = elbow_R + arm_reach_X;

    // Boss near junction (on base top, at base right edge)
    translate([ base_L/2 - boss1_L/2 + overlap, 0, base_H + boss1_H/2 - overlap ])
        cube([boss1_L, boss1_W, boss1_H], center=true);

    // Boss near end pad (on top of arm near pad)
    translate([ base_L/2 + end_x - pad_L + boss2_L/2, 0, base_H + rise - arm_thk/2 - boss2_H/2 + overlap ])
        cube([boss2_L, boss2_W, boss2_H], center=true);
}

module base_block() {
    // Rounded-rectangle base block, centered at origin in XY, sitting on Z=0
    translate([0, 0, 0])
        rounded_rect_prism(base_L, base_W, base_H, base_corner_r);
}

module bracket_raw() {
    // Place arm so it starts at base right face, centered in Y, from base top
    // Arm path starts at X=0; shift to base right face with overlap
    translate([base_L/2 - overlap, 0, 0]) {
        arm_solid();
        end_pad();
        bosses();
    }

    base_block();
}

// Micro fillet via Minkowski (kept small to avoid bloating bbox too much)
minkowski() {
    bracket_raw();
    sphere(r=micro_fillet_r);
}
}
