
import Markdown
import Base: ==

const AnyVecOrMat = Union{MatElem, AbstractVecOrMat}


export Cone,
    Graphs,
    PointVector,
    PolyhedralFan,
    Polyhedron,
    Halfspace,
    Hyperplane,
    SubdivisionOfPoints,
    IncidenceMatrix,
    LinearProgram,
    RayVector,
    PolyhedronOrConeIterator,
    HalfspaceIterator,
    VectorIterator,
    affine_hull,
    archimedean_solid,
    ambient_dim,
    boundary_lattice_points,
    catalan_solid,
    codim,
    combinatorial_symmetries,
    cone_from_inequalities,
    convex_hull,
    cross,
    cube,
    dim,
    dual_cone,
    faces,
    facets,
    facets_as_halfspace_matrix_pair,
    facets_as_point_matrix,
    face_fan,
    feasible_region,
    f_vector,
    halfspace_matrix_pair,
    hilbert_basis,
    intersect,
    interior_lattice_points,
    isbounded,
    iscomplete,
    isfeasible,
    isfulldimensional,
    isnormal,
    ispointed,
    isregular,
    issmooth,
    lattice_points,
    lineality_dim,
    lineality_space,
    linear_span,
    linear_symmetries,
    load_cone,
    load_linearprogram,
    load_polyhedralfan,
    load_polyhedron,
    load_subdivisionofpoints,
    maximal_cells,
    maximal_cells_as_incidence_matrix,
    maximal_cones,
    maximal_cones_as_incidence_matrix,
    maximal_value,
    maximal_vertex,
    minimal_value,
    minimal_vertex,
    min_weights,
    minkowski_sum,
    ne,
    newton_polytope,
    normalized_volume,
    normal_fan,
    normal_cone,
    nfacets,
    nmaximal_cones,
    nmaximal_cells,
    nrays,
    nv,
    nvertices,
    objective_function,
    orbit_polytope,
    point_matrix,
    polarize,
    print_constraints,
    product,
    recession_cone,
    save_cone,
    save_linearprogram,
    save_polyhedralfan,
    save_polyhedron,
    save_subdivisionofpoints,
    secondary_cone,
    simplex,
    solve_lp,
    support_function,
    positive_hull,
    rays,
    rays_as_point_matrix,
    upper_bound_theorem,
    vertices,
    vertices_as_point_matrix,
    vf_group,
    visualize,
    volume

include("helpers.jl")
include("iterators.jl")
include("Polyhedron/constructors.jl")
include("Cone/constructors.jl")
include("Cone/properties.jl")
include("Cone/standard_constructions.jl")
include("Polyhedron/properties.jl")
include("Polyhedron/standard_constructions.jl")
include("PolyhedralFan/constructors.jl")
include("PolyhedralFan/properties.jl")
include("PolyhedralFan/standard_constructions.jl")
include("SubdivisionOfPoints/constructors.jl")
include("SubdivisionOfPoints/properties.jl")
include("SubdivisionOfPoints/functions.jl")
include("LinearProgram.jl")
include("Groups.jl")
include("Graphs.jl")
include("Serialization.jl")
include("Visualization.jl")
include("solving_integrally.jl")
