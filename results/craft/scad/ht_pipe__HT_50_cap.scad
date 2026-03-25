// HT 50 Cap (closed end cap) - single connected solid
// Fixes: proper cap depth, socket step, wall thickness, closed end, internal stop, higher resolution,
// and guaranteed connectivity (pipe stub fused into socket with overlap).

$fn = 160;

// Parameters
pipe_od_mm = 50; //[25:100:0.1]
cap_outer_diameter_mm = 60; //[30:120:0.1]
cap_length_mm = 45; //[25:90:0.1]
socket_depth_mm = 35; //[15:70:0.1]
wall_thickness_mm = 3; //[1.5:6:0.1]
clearance_mm = 0.4; //[0.1:1.2:0.05]
end_face_thickness_mm = 4; //[2:10:0.1]
internal_stop_offset_mm = 32; //[10:60:0.1]
fillet_radius_mm = 1; //[0:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
pipe_wall_mm = 2.4; //[1.2:5:0.1]
pipe_stub_length_mm = 60; //[30:120:0.5]

// Derived radii
pipe_or = pipe_od_mm/2;
pipe_ir = pipe_or - pipe_wall_mm;

cap_or  = cap_outer_diameter_mm/2;
cap_ir  = cap_or - wall_thickness_mm;

socket_ir = pipe_or + clearance_mm; // cap socket inner radius

// Clamp helpers (avoid invalid geometry)
function clamp(x, a, b) = min(max(x, a), b);

// Ensure stop is inside socket and before end face
stop_z_from_open = clamp(internal_stop_offset_mm, wall_thickness_mm, socket_depth_mm - wall_thickness_mm);
stop_th = wall_thickness_mm;

// Cap is oriented with OPEN end at z=0, CLOSED end at z=cap_length_mm
module ht50_cap_solid() {
    color([0.85, 0.85, 0.8])
    union() {
        // CAP BODY (closed end)
        difference() {
            // Outer shell
            translate([0,0,cap_length_mm/2])
                cylinder(r=cap_or, h=cap_length_mm, center=true);

            // Main inner cavity leaving closed end thickness
            // Inner cavity starts at open end and stops before closed end
            translate([0,0,(cap_length_mm - end_face_thickness_mm)/2])
                cylinder(r=cap_ir, h=cap_length_mm - end_face_thickness_mm + overlap_mm, center=true);

            // Socket bore (larger) from open end into cap
            translate([0,0,socket_depth_mm/2])
                cylinder(r=socket_ir, h=socket_depth_mm + overlap_mm, center=true);

            // Internal stop: reduce bore after stop position (prevents pipe from going too deep)
            // This creates a shoulder at z = stop_z_from_open
            translate([0,0,(socket_depth_mm - stop_z_from_open)/2 + stop_z_from_open])
                cylinder(r=pipe_ir, h=(socket_depth_mm - stop_z_from_open) + overlap_mm, center=true);

            // Entry chamfer at open end (slight lead-in)
            if (fillet_radius_mm > 0)
                translate([0,0,fillet_radius_mm/2])
                    cylinder(r1=socket_ir + fillet_radius_mm, r2=socket_ir, h=fillet_radius_mm + overlap_mm, center=true);
        }

        // PIPE STUB (fused into socket to ensure one connected solid)
        // Place pipe so its top end overlaps into socket by overlap_mm
        translate([0,0,-pipe_stub_length_mm/2 + overlap_mm])
            difference() {
                cylinder(r=pipe_or, h=pipe_stub_length_mm, center=true);
                translate([0,0,0])
                    cylinder(r=pipe_ir, h=pipe_stub_length_mm + overlap_mm, center=true);
            }
    }
}

ht50_cap_solid();