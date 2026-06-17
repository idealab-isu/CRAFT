// Light strip: rigid (single connected solid with visible details)
// Parameters
length_mm = 300; //[150:600:1]
width_mm = 10; //[5:20:1]
thickness_mm = 2; //[1:6:0.1]
pcb_thickness_mm = 1.2; //[0.6:2.4:0.1]
led_count = 30; //[6:120:1]
grouping = 3; //[1:6:1]
segment_count = 10; //[2:40:1]
edge_margin_mm = 6; //[3:15:1]
led_pkg_length_mm = 5; //[3:8:0.1]
led_pkg_width_mm = 5; //[3:8:0.1]
led_pkg_height_mm = 1.6; //[0.8:3.2:0.1]
pad_length_mm = 2.5; //[1.5:5:0.1]
pad_width_mm = 2.5; //[1.5:5:0.1]
pad_height_mm = 0.2; //[0.1:0.6:0.05]
pad_offset_y_mm = 3; //[2:4:0.1]
marker_thickness_mm = 0.2; //[0.1:0.6:0.05]
marker_width_mm = 0.4; //[0.2:1.2:0.05]
marker_span_y_mm = 8; //[4:16:0.5]
clip_wall_mm = 1.5; //[0.8:3:0.1]
clip_length_mm = 20; //[10:60:1]
clip_depth_mm = 8; //[4:20:0.5]
clip_clearance_mm = 0.4; //[0.2:1.2:0.05]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);
function safe(v, eps=0.01) = v < eps ? eps : v;

// Derived / safety
strip_t = safe(thickness_mm);
ov      = clamp(overlap_mm, 0.2, 2);

pcb_t   = clamp(pcb_thickness_mm, 0.2, strip_t - 0.2);

led_h   = clamp(led_pkg_height_mm, 0.4, 3.5);
pad_h   = clamp(pad_height_mm, 0.05, 1.0);
mark_h  = clamp(marker_thickness_mm, 0.05, 1.0);

// Ensure details fit within strip width
led_w   = clamp(led_pkg_width_mm, 0.5, width_mm - 2*ov);
pad_w   = clamp(pad_width_mm, 0.5, width_mm/2 - 2*ov);
pad_off = clamp(pad_offset_y_mm, 0, (width_mm/2 - pad_w/2 - ov));

// Keep edge margin valid
edge_m  = clamp(edge_margin_mm, 0, length_mm/2 - 1);

// Z placement: embed slightly so union is one connected solid
z_top = strip_t/2;
z_led = z_top + led_h/2 - ov;
z_pad = z_top + pad_h/2 - ov;
z_mrk = z_top + mark_h/2 - ov;

// Clip placement: intersect strip so assembly is one connected solid
clip_z = z_top + clip_depth_mm/2 - ov;

// Diffuser ridge (adds visible top feature, fused)
diffuser_h = clamp(strip_t*0.6, 0.4, 2.5);
diffuser_w = clamp(width_mm*0.75, 2, width_mm - 2*ov);
diffuser_z = z_top + diffuser_h/2 - ov;

// Small underside stiffener rib (adds visible bottom feature, fused)
rib_h = clamp(strip_t*0.5, 0.3, 2.0);
rib_w = clamp(width_mm*0.35, 1.0, width_mm - 2*ov);
rib_z = -strip_t/2 - rib_h/2 + ov;

// LED pitch derived from count and margins
usable_len = max(1, length_mm - 2*edge_m);
led_pitch  = usable_len / led_count;

// Segment marker positions
seg_n = clamp(segment_count, 2, 200);

// Main strip with details (single solid)
module light_strip_solid() {
    union() {
        // Main rigid strip body
        cube([length_mm, width_mm, strip_t], center=true);

        // Diffuser ridge along top (visible feature)
        translate([0, 0, diffuser_z])
            cube([length_mm - 2*ov, diffuser_w, diffuser_h], center=true);

        // Underside stiffener rib
        translate([0, 0, rib_z])
            cube([length_mm - 2*ov, rib_w, rib_h], center=true);

        // PCB core embedded within strip (solid, not void)
        translate([0, 0, z_top - pcb_t/2 - ov])
            cube([length_mm - 2*ov, width_mm - 2*ov, pcb_t], center=true);

        // LED packages (grouped, raised but fused)
        for (i = [0:led_count-1]) {
            x_led = -length_mm/2 + edge_m + led_pitch*(i + 0.5);

            // Slightly vary width by grouping to show segmentation while staying connected
            w_i = clamp(led_w * ( (i % grouping)==0 ? 1.0 : 0.85 ), 0.5, width_mm - 2*ov);

            translate([x_led, 0, z_led])
                cube([led_pkg_length_mm, w_i, led_h], center=true);
        }

        // Solder pads (fused)
        for (i = [0:seg_n-1]) {
            xpad = -length_mm/2 + edge_m + usable_len*(i + 0.5)/seg_n;

            translate([xpad,  pad_off, z_pad])
                cube([pad_length_mm, pad_w, pad_h], center=true);

            translate([xpad, -pad_off, z_pad])
                cube([pad_length_mm, pad_w, pad_h], center=true);
        }

        // Segment markers (fused)
        for (i = [1:seg_n-1]) {
            xmk = -length_mm/2 + length_mm*i/seg_n;
            translate([xmk, 0, z_mrk])
                cube([marker_width_mm, clamp(marker_span_y_mm, 1, width_mm - 2*ov), mark_h], center=true);
        }
    }
}

// Clip: U-channel that wraps over strip; intersects strip so union is connected
module light_strip_clip_solid() {
    outer = [clip_length_mm, width_mm + 2*clip_wall_mm, clip_depth_mm];

    // Inner cavity: ensure positive dimensions
    inner_x = max(0.5, clip_length_mm - 2*clip_wall_mm);
    inner_y = max(0.5, width_mm + 2*clip_clearance_mm);
    inner_z = max(0.5, clip_depth_mm - clip_wall_mm); // leaves top bridge thickness = clip_wall_mm

    difference() {
        translate([0, 0, clip_z])
            cube(outer, center=true);

        // Shift cavity downward so top bridge remains; also ensure it doesn't fully remove side walls
        translate([0, 0, clip_z - clip_wall_mm/2])
            cube([inner_x, inner_y, inner_z], center=true);
    }
}

// Assembly: ONE connected solid
union() {
    light_strip_solid();
    light_strip_clip_solid();
}