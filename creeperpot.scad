// ! make root
// % transparent
// * hide
// # mark

// translate([20, 20, 20]) {}
// difference() {}

//
$fn = 100;

cube_size = 70;
outer_edge_radius = 2.5;
inner_radius = 35;
padding = 10;
lid_height = 2;
lid_overlap = 2;
wall_width = 4;
insert_radius = 28;
insert_height = 50;
face_tolerance = 0.1;

function pot_pocket_width() = cube_size - 2 * wall_width;
function pot_pochet_height() = cube_size - wall_width;
function lid_z() = cube_size - lid_height;
function lid_width() = cube_size - 2 * lid_overlap;
function face_depth() = 1;
function face_sub_edge() = (cube_size - 2 * padding) / 8;

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
union() {
    color("green")
    difference() {
        difference() {
            difference() {
                cube(cube_size);
                translate([wall_width, wall_width, wall_width])
                    cube([pot_pocket_width(), pot_pocket_width(), pot_pochet_height()]);
            }
            translate([lid_overlap, lid_overlap, lid_z()])
                cube([lid_width(), lid_width(), lid_height]);
            
        }
        
        translate([0, face_depth(), 0])
            rotate([90, 0, 0])
                face_solid(face_depth() + 0.1, grow = 0);
    }
}


// LID
color("green")
translate([lid_overlap + cube_size, lid_overlap, lid_z()]) {
    difference() {
        union() {
            cube([lid_width(), lid_width(), lid_height]);
            translate([lid_width() / 2, lid_width() / 2, -insert_height + lid_height])
                cylinder(insert_height, insert_radius, insert_radius);
        }
        translate([lid_width() / 2, lid_width() / 2, -insert_height + lid_height + wall_width])
            cylinder(insert_height - wall_width, insert_radius - wall_width, insert_radius - wall_width);
    }
}

// FACE
face_print_gap = 3;

color("black")
translate([cube_size * 2, 10, 0])
    face_solid(face_depth(), grow = -face_tolerance, gap = face_print_gap);
