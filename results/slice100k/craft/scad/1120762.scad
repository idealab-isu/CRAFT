// Solid star-like hub with radial rectangular arms and smooth fillets
// Target bounding box: 13.2 x 12.0 x 6.3 mm

$fn = 64;

// Bounding box (mm)
bbox_x = 13.2;
bbox_y = 12.0;
bbox_z = 6.3;

// Core hub (mm)
hub_x = 6.2;
hub_y = 6.2;
hub_z = bbox_z;

// Arms (mm)
arm_w = 3.2;
arm_z = bbox_z;

// Arm lengths chosen to hit the requested overall bbox exactly:
// overall X = hub_x + 2*arm_len_x_each = bbox_x
// overall Y = hub_y + 2*arm_len_y_each = bbox_y
arm_len_x_each = (bbox_x - hub_x)/2;  // 3.5
arm_len_y_each = (bbox_y - hub_y)/2;  // 2.9

// Diagonal arms (kept inside bbox; purely for the star-like silhouette)
diag_arm_len = 1.2;
diag_arm_w   = 1.6;

// Fillet/softening (mm)
global_soft_r = 0.35;   // smooth molded look
connect_overlap = 0.6;  // ensures watertight unions

// ---------- helpers ----------
module core_and_arms_2d() {
    union() {
        // central hub footprint
        square([hub_x, hub_y], center=true);

        // +X / -X arms
        translate([hub_x/2 + arm_len_x_each/2 - connect_overlap/2, 0])
            square([arm_len_x_each + connect_overlap, arm_w], center=true);
        translate([-(hub_x/2 + arm_len_x_each/2 - connect_overlap/2), 0])
            square([arm_len_x_each + connect_overlap, arm_w], center=true);

        // +Y / -Y arms
        translate([0, hub_y/2 + arm_len_y_each/2 - connect_overlap/2])
            square([arm_w, arm_len_y_each + connect_overlap], center=true);
        translate([0, -(hub_y/2 + arm_len_y_each/2 - connect_overlap/2)])
            square([arm_w, arm_len_y_each + connect_overlap], center=true);

        // diagonal "nubs" (kept compact so bbox remains controlled)
        for (a = [45, 135, 225, 315]) {
            rotate(a)
                translate([min(hub_x,hub_y)/2 - connect_overlap/2, 0])
                    square([diag_arm_len + connect_overlap, diag_arm_w], center=true);
        }
    }
}

// 2D rounding (true fillets in XY), then extrude to thickness
module star_prism() {
    linear_extrude(height=bbox_z, center=true, convexity=10)
        offset(r=global_soft_r)
            offset(delta=-global_soft_r)
                core_and_arms_2d();
}

// Final: already exactly sized in XY by construction; Z by extrusion height
star_prism();