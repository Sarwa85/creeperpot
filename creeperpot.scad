/* [Main pot dimensions] */

// Outer cube size in mm
cube_size = 74;

// Outer edge fillet radius
outer_edge_radius = 1;

// Main wall thickness
wall_width = 4;

/* [Lid and inner insert] */

// Height of the outer lid rim
lid_height = 2;

// Depth of the lid recessed fit into the pot
lid_overlap = 2;

// Inner radius of the cylindrical lid insert
insert_radius = 28;

// Inner depth of the cylindrical lid insert, measured from the top of the lid
insert_depth = 50;

/* [Face pattern] */

// Margin from the front wall edges to the face pattern
padding = 10;

// Tolerance offset for the face insert fit (FDM clearance)
face_tolerance = 0.1;

/* [Hidden] */
$fn = 100;
eps = 0.0001;
face_print_gap = 3;
print_layout = true;

function pot_pocket_width() = cube_size - 2 * wall_width;
function pot_pochet_height() = cube_size - wall_width;
function lid_z() = cube_size - lid_height;
function lid_width() = cube_size - 2 * lid_overlap;
function insert_height() = insert_depth + wall_width;
function face_depth() = 1;
function face_sub_edge() = (cube_size - 2 * padding) / 8;

// SHAPES
module rounded_cube(size, r, center = false) {
    s = is_list(size) ? size : [size, size, size];
    shift = center ? [-s[0]/2, -s[1]/2, -s[2]/2] : [0, 0, 0];

    translate(shift) {
        hull() {
            translate([r, r, r]) sphere(r = r);
            translate([s[0] - r, r, r]) sphere(r = r);
            translate([r, s[1] - r, r]) sphere(r = r);
            translate([s[0] - r, s[1] - r, r]) sphere(r = r);

            translate([r, r, s[2] - r]) sphere(r = r);
            translate([s[0] - r, r, s[2] - r]) sphere(r = r);
            translate([r, s[1] - r, s[2] - r]) sphere(r = r);
            translate([s[0] - r, s[1] - r, s[2] - r]) sphere(r = r);
        }
    }
}

// FACE
eye_l_grid = [[1, 5], [3, 5], [3, 7], [1, 7]];
eye_r_grid = [[5, 5], [7, 5], [7, 7], [5, 7]];
nose_grid  = [[2, 1], [3, 1], [3, 2], [5, 2], [5, 1], [6, 1],
              [6, 4], [5, 4], [5, 5], [3, 5], [3, 4], [2, 4]];

function face_pts(grid) =
    [for (p = grid) [padding + face_sub_edge() * p[0], padding + face_sub_edge() * p[1]]];

// Each piece is extruded separately and joined only in 3D. A 2D linear_extrude on a region 
// that narrows down to a point produces an open mesh — a 3D union does not have this issue, 
// so corners of eyes and nose can meet exactly.
//   grow - size adjustment; opening is practically 1:1, insert is smaller by face_tolerance
//   gap  - nose offset when laying out pieces on the build plate
module face_solid(h, grow = 0, gap = 0) {
    
    linear_extrude(height = h) offset(delta = grow) polygon(face_pts(eye_l_grid));
    linear_extrude(height = h) offset(delta = grow) polygon(face_pts(eye_r_grid));
    translate([0, -gap, 0])
        linear_extrude(height = h) offset(delta = grow) polygon(face_pts(nose_grid));
}

// POT
module pot() {
    color("green")
    difference() {
        rounded_cube(cube_size, outer_edge_radius);

        translate([wall_width, wall_width, wall_width])
            cube([pot_pocket_width(), pot_pocket_width(), pot_pochet_height() + 1]);
        translate([lid_overlap, lid_overlap, lid_z()])
            cube([lid_width(), lid_width(), lid_height + 1]);
        translate([0, face_depth(), 0])
            rotate([90, 0, 0])
                face_solid(face_depth() + 0.2, grow = eps);
    }
}

// LID
// Built in print orientation: insert bottom at z = 0, lid plate on top
// (the plate overhangs the insert, so it needs supports).
module lid() {
    color("green")
    translate([0, 0, insert_height() - lid_height])
    difference() {
        union() {
            cube([lid_width(), lid_width(), lid_height]);
            translate([lid_width() / 2, lid_width() / 2, -insert_height() + lid_height])
                cylinder(insert_height(), insert_radius + wall_width, insert_radius + wall_width);
        }
        translate([lid_width() / 2, lid_width() / 2, -insert_height() + lid_height + wall_width])
            cylinder(insert_height() - wall_width, insert_radius, insert_radius);
    }
}

// FACE
module face_inlay(gap = face_print_gap) {
    color("black")
        face_solid(face_depth(), grow = -face_tolerance, gap = gap);
}

// MAKERWORLD PLATES
// Parametric Model Maker exports each mw_plate_N() as a separate plate in the 3MF.
// mw_assembly_view() is used only for the on-site preview and is not exported.
module mw_plate_1() { pot(); }
module mw_plate_2() { lid(); }
module mw_plate_3() { face_inlay(); }

module mw_assembly_view() {
    pot();
    translate([lid_overlap, lid_overlap, lid_z() - insert_height() + lid_height])
        lid();
    translate([0, face_depth(), 0])
        rotate([90, 0, 0])
            face_inlay(gap = 0);
}

// MakerWorld adds top-level geometry to the Assemble View and to every plate, so nothing
// may be rendered at top level there (it renders with $preview = false).
// Local use: F5 preview shows the assembly; for a print export use -D print_layout=true.
// Each part is a separate top-level object, so with the lazy-union feature enabled
// the exported 3MF contains them as separate objects.
if ($preview && !print_layout) {
    mw_assembly_view();
} else if (print_layout) {
    pot();
    translate([cube_size + 10, 0, 0]) lid();
    translate([cube_size + lid_width() + 20, 0, 0]) face_inlay();
}
