###############################################################################
###############################################################################
### Standard constructions
###############################################################################
###############################################################################
@doc Markdown.doc"""
    birkhoff(n::Integer, even::Bool = false)

Construct the Birkhoff polytope of dimension $n^2$.

This is the polytope of $n \times n$ stochastic matrices (encoded as row vectors of
length $n^2$), i.e., the matrices with non-negative real entries whose row and column
entries sum up to one. Its vertices are the permutation matrices.

Use `even = true` to get the vertices only for the even permutation matrices.

# Examples
```jldoctest
julia> b = birkhoff(3)
A polyhedron in ambient dimension 9

julia> vertices(b)
6-element SubObjectIterator{PointVector{fmpq}}:
 [1, 0, 0, 0, 1, 0, 0, 0, 1]
 [0, 1, 0, 1, 0, 0, 0, 0, 1]
 [0, 0, 1, 1, 0, 0, 0, 1, 0]
 [1, 0, 0, 0, 0, 1, 0, 1, 0]
 [0, 1, 0, 0, 0, 1, 1, 0, 0]
 [0, 0, 1, 0, 1, 0, 1, 0, 0]
```
"""
birkhoff(n::Integer; even::Bool = false) = Polyhedron(Polymake.polytope.birkhoff(n, Int(even), group=true))



@doc Markdown.doc"""
    pyramid(P::Polyhedron, z::Number = 1)

Make a pyramid over the given polyhedron `P`.

The pyramid is the convex hull of the input polyhedron `P` and a point `v`
outside the affine span of `P`. For bounded polyhedra, the projection of `v` to
the affine span of `P` coincides with the vertex barycenter of `P`. The scalar `z`
is the distance between the vertex barycenter and `v`.


# Examples
```jldoctest
julia> c = cube(2)
A polyhedron in ambient dimension 2

julia> vertices(pyramid(c,5))
5-element SubObjectIterator{PointVector{fmpq}}:
 [-1, -1, 0]
 [1, -1, 0]
 [-1, 1, 0]
 [1, 1, 0]
 [0, 0, 5]
```
"""
function pyramid(P::Polyhedron{T}, z::Number=1) where T<:scalar_types
   pm_in = pm_object(P)
   has_group = Polymake.exists(pm_in, "GROUP")
   return Polyhedron{T}(Polymake.polytope.pyramid(pm_in, z, group=has_group))
end



@doc Markdown.doc"""
    bipyramid(P::Polyhedron, z::Number = 1, z_prime::Number = -z)

Make a bipyramid over a pointed polyhedron `P`.

The bipyramid is the convex hull of the input polyhedron `P` and two apexes
(`v`, `z`), (`v`, `z_prime`) on both sides of the affine span of `P`. For bounded
polyhedra, the projections of the apexes `v` to the affine span of `P` is the
vertex barycenter of `P`.

# Examples
```jldoctest
julia> c = cube(2)
A polyhedron in ambient dimension 2

julia> vertices(bipyramid(c,2))
6-element SubObjectIterator{PointVector{fmpq}}:
 [-1, -1, 0]
 [1, -1, 0]
 [-1, 1, 0]
 [1, 1, 0]
 [0, 0, 2]
 [0, 0, -2]

```
"""
function bipyramid(P::Polyhedron{T}, z::Number=1, z_prime::Number=-z)  where T<:scalar_types
   pm_in = pm_object(P)
   has_group = Polymake.exists(pm_in, "GROUP")
   return Polyhedron{T}(Polymake.polytope.bipyramid(pm_in, z, z_prime, group=has_group))
end



@doc Markdown.doc"""
    normal_cone(P::Polyhedron, i::Int64)

Construct the normal cone to `P` at the `i`-th vertex of `P`.

The normal cone at a face is generated by all the inner normals of `P` that
attain their minimum at the `i`-th vertex.

# Examples
Build the normal cones at the first vertex of the square (in this case [-1,-1]).
```jldoctest
julia> square = cube(2)
A polyhedron in ambient dimension 2

julia> vertices(square)
4-element SubObjectIterator{PointVector{fmpq}}:
 [-1, -1]
 [1, -1]
 [-1, 1]
 [1, 1]

julia> nc = normal_cone(square, 1)
A polyhedral cone in ambient dimension 2

julia> rays(nc)
2-element SubObjectIterator{RayVector{fmpq}}:
 [1, 0]
 [0, 1]
```
"""
function normal_cone(P::Polyhedron{T}, i::Int64) where T<:scalar_types
    if(i<1 || i>nvertices(P))
       throw(ArgumentError("Vertex index out of range"))
    end
    bigobject = Polymake.polytope.normal_cone(pm_object(P), Set{Int64}([i-1]))
    return Cone{T}(bigobject)
end


@doc Markdown.doc"""
    orbit_polytope(V::AbstractCollection[PointVector], G::PermGroup)

Construct the convex hull of the orbit of one or several points (given row-wise
in `V`) under the action of `G`.

# Examples
This will construct the $3$-dimensional permutahedron:
```jldoctest
julia> V = [1 2 3];

julia> G = symmetric_group(3);

julia> P = orbit_polytope(V, G)
A polyhedron in ambient dimension 3

julia> vertices(P)
6-element SubObjectIterator{PointVector{fmpq}}:
 [1, 2, 3]
 [1, 3, 2]
 [2, 1, 3]
 [2, 3, 1]
 [3, 1, 2]
 [3, 2, 1]
```
"""
function orbit_polytope(V::AbstractCollection[PointVector], G::PermGroup)
   Vhom = stack(homogenized_matrix(V, 1), nothing)
   if size(Vhom, 2) != degree(G) + 1
      throw(ArgumentError("Dimension of points and group degree need to be the same."))
   end
   generators = PermGroup_to_polymake_array(G)
   pmGroup = Polymake.group.PermutationAction(GENERATORS=generators)
   pmPolytope = Polymake.polytope.orbit_polytope(Vhom, pmGroup)
   return Polyhedron{fmpq}(pmPolytope)
end

@doc Markdown.doc"""
    cube([::Type{T} = fmpq,] d::Int , [l::Rational = -1, u::Rational = 1])

Construct the $[l,u]$-cube in dimension $d$.

# Examples
In this example the 5-dimensional unit cube is constructed to ask for one of its
properties:
```jldoctest
julia> C = cube(5,0,1);

julia> normalized_volume(C)
120
```
"""
cube(::Type{T}, d) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.cube{scalar_type_to_polymake[T]}(d))
cube(::Type{T}, d, l, u) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.cube{scalar_type_to_polymake[T]}(d, u, l))
cube(x...) = cube(fmpq, x...)



"""
    newton_polytope(poly::Polynomial)

Compute the Newton polytope of the multivariate polynomial `poly`.

# Examples
```jldoctest
julia> S, (x, y) = PolynomialRing(ZZ, ["x", "y"])
(Multivariate Polynomial Ring in x, y over Integer Ring, fmpz_mpoly[x, y])

julia> f = x^3*y + 3x*y^2 + 1
x^3*y + 3*x*y^2 + 1

julia> NP = newton_polytope(f)
A polyhedron in ambient dimension 2

julia> vertices(NP)
3-element SubObjectIterator{PointVector{fmpq}}:
 [3, 1]
 [1, 2]
 [0, 0]
```
"""
function newton_polytope(f)
    exponents = reduce(hcat, Oscar.exponent_vectors(f))'
    convex_hull(exponents)
end


Polyhedron(H::Halfspace{T}) where T<:scalar_types = Polyhedron{T}(normal_vector(H), negbias(H))

Polyhedron(H::Halfspace{Union{fmpq, nf_elem}}) = Polyhedron{nf_elem}(normal_vector(H), negbias(H))

Polyhedron(H::Hyperplane{T}) where T<:scalar_types = Polyhedron{T}(nothing, (normal_vector(H), [negbias(H)]))

Polyhedron(H::Hyperplane{Union{fmpq, nf_elem}}) = Polyhedron{nf_elem}(nothing, (normal_vector(H), [negbias(H)]))

@doc Markdown.doc"""
    intersect(P::Polyhedron, Q::Polyhedron)

Return the intersection $P \cap Q$ of `P` and `Q`.

# Examples
The positive orthant of the plane is the intersection of the two halfspaces with
$x≥0$ and $y≥0$ respectively.
```jldoctest
julia> UH1 = convex_hull([0 0],[1 0],[0 1]);

julia> UH2 = convex_hull([0 0],[0 1],[1 0]);

julia> PO = intersect(UH1, UH2)
A polyhedron in ambient dimension 2

julia> rays(PO)
2-element SubObjectIterator{RayVector{fmpq}}:
 [1, 0]
 [0, 1]
```
"""
function intersect(P::Polyhedron{T}, Q::Polyhedron{T}) where T<:scalar_types
   return Polyhedron{T}(Polymake.polytope.intersection(pm_object(P), pm_object(Q)))
end

@doc Markdown.doc"""
    minkowski_sum(P::Polyhedron, Q::Polyhedron)

Return the Minkowski sum $P + Q = \{ x+y\ |\ x∈P, y∈Q\}$ of `P` and `Q`.

# Examples
The Minkowski sum of a square and the 2-dimensional cross-polytope is an
octagon:
```jldoctest
julia> P = cube(2);

julia> Q = cross(2);

julia> M = minkowski_sum(P, Q)
A polyhedron in ambient dimension 2

julia> nvertices(M)
8
```
"""
function minkowski_sum(P::Polyhedron{T}, Q::Polyhedron{T}; algorithm::Symbol=:standard) where T<:scalar_types
   if algorithm == :standard
      return Polyhedron{T}(Polymake.polytope.minkowski_sum(pm_object(P), pm_object(Q)))
   elseif algorithm == :fukuda
      return Polyhedron{T}(Polymake.polytope.minkowski_sum_fukuda(pm_object(P), pm_object(Q)))
   else
      throw(ArgumentError("Unknown minkowski sum `algorithm` argument: $algorithm"))
   end
end





@doc Markdown.doc"""
    product(P::Polyhedron, Q::Polyhedron)

Return the Cartesian product of `P` and `Q`.

# Examples
The Cartesian product of a triangle and a line segment is a triangular prism.
```jldoctest
julia> T=simplex(2)
A polyhedron in ambient dimension 2

julia> S=cube(1)
A polyhedron in ambient dimension 1

julia> length(vertices(product(T,S)))
6
```
"""
product(P::Polyhedron{T}, Q::Polyhedron{T}) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.product(pm_object(P), pm_object(Q)))

@doc Markdown.doc"""
    *(P::Polyhedron, Q::Polyhedron)

Return the Cartesian product of `P` and `Q` (see also `product`).

# Examples
The Cartesian product of a triangle and a line segment is a triangular prism.
```jldoctest
julia> T=simplex(2)
A polyhedron in ambient dimension 2

julia> S=cube(1)
A polyhedron in ambient dimension 1

julia> length(vertices(T*S))
6
```
"""
*(P::Polyhedron{T}, Q::Polyhedron{T}) where T<:scalar_types = product(P,Q)

@doc Markdown.doc"""
    convex_hull(P::Polyhedron, Q::Polyhedron)

Return the convex_hull of `P` and `Q`.

# Examples
The convex hull of the following two line segments in $R^3$ is a tetrahedron.
```jldoctest
julia> L₁ = convex_hull([-1 0 0; 1 0 0])
A polyhedron in ambient dimension 3

julia> L₂ = convex_hull([0 -1 0; 0 1 0])
A polyhedron in ambient dimension 3

julia> T=convex_hull(L₁,L₂);

julia> f_vector(T)
2-element Vector{fmpz}:
 4
 4
```
"""
convex_hull(P::Polyhedron{T}, Q::Polyhedron{T}) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.conv(pm_object(P),pm_object(Q)))



#TODO: documentation  + extend to different fields.

@doc Markdown.doc"""
    +(P::Polyhedron, Q::Polyhedron)

Return the Minkowski sum $P + Q = \{ x+y\ |\ x∈P, y∈Q\}$ of `P` and `Q` (see also `minkowski_sum`).

# Examples
The Minkowski sum of a square and the 2-dimensional cross-polytope is an
octagon:
```jldoctest
julia> P = cube(2);

julia> Q = cross(2);

julia> M = minkowski_sum(P, Q)
A polyhedron in ambient dimension 2

julia> nvertices(M)
8
```
"""
+(P::Polyhedron{T}, Q::Polyhedron{T}) where T<:scalar_types = minkowski_sum(P,Q)


#TODO: extend to different fields

@doc Markdown.doc"""
    *(k::Int, Q::Polyhedron)

Return the scaled polyhedron $kQ = \{ kx\ |\ x∈Q\}$.

Note that `k*Q = Q*k`.

# Examples
Scaling an $n$-dimensional bounded polyhedron by the factor $k$ results in the
volume being scaled by $k^n$.
This example confirms the statement for the 6-dimensional cube and $k = 2$.
```jldoctest
julia> C = cube(6);

julia> SC = 2*C
A polyhedron in ambient dimension 6

julia> volume(SC)//volume(C)
64
```
"""
*(k::Int, P::Polyhedron{T}) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.scale(pm_object(P),k))


@doc Markdown.doc"""
    *(P::Polyhedron, k::Int)

Return the scaled polyhedron $kP = \{ kx\ |\ x∈P\}$.

Note that `k*P = P*k`.

# Examples
Scaling an $n$-dimensional bounded polyhedron by the factor $k$ results in the
volume being scaled by $k^n$.
This example confirms the statement for the 6-dimensional cube and $k = 2$.
```jldoctest
julia> C = cube(6);

julia> SC = C*2
A polyhedron in ambient dimension 6

julia> volume(SC)//volume(C)
64
```
"""
*(P::Polyhedron{T},k::Int) where T<:scalar_types = k*P


@doc Markdown.doc"""
    +(P::Polyhedron, v::AbstractVector)

Return the translation $P+v = \{ x+v\ |\ x∈P\}$ of `P` by `v`.

Note that `P+v = v+P`.

# Examples
We construct a polyhedron from its $V$-description. Shifting it by the right
vector reveals that its inner geometry corresponds to that of the 3-simplex.
```jldoctest
julia> P = convex_hull([100 200 300; 101 200 300; 100 201 300; 100 200 301]);

julia> v = [-100, -200, -300];

julia> S = P + v
A polyhedron in ambient dimension 3

julia> vertices(S)
4-element SubObjectIterator{PointVector{fmpq}}:
 [0, 0, 0]
 [1, 0, 0]
 [0, 1, 0]
 [0, 0, 1]
```
"""
function +(P::Polyhedron{T}, v::AbstractVector) where T<:scalar_types
    if ambient_dim(P) != length(v)
        throw(ArgumentError("Translation vector not correct dimension"))
    else
        return Polyhedron{T}(Polymake.polytope.translate(pm_object(P), Polymake.Vector{scalar_type_to_polymake[T]}(v)))
    end
end


@doc Markdown.doc"""
    +(v::AbstractVector, P::Polyhedron)

Return the translation $P+v = \{ x+v\ |\ x∈P\}$ of `P` by `v`.

Note that `P+v = v+P`.

# Examples
We construct a polyhedron from its $V$-description. Shifting it by the right
vector reveals that its inner geometry corresponds to that of the 3-simplex.
```jldoctest
julia> P = convex_hull([100 200 300; 101 200 300; 100 201 300; 100 200 301]);

julia> v = [-100, -200, -300];

julia> S = v + P
A polyhedron in ambient dimension 3

julia> vertices(S)
4-element SubObjectIterator{PointVector{fmpq}}:
 [0, 0, 0]
 [1, 0, 0]
 [0, 1, 0]
 [0, 0, 1]
```
"""
+(v::AbstractVector,P::Polyhedron{T}) where T<:scalar_types = P+v

@doc Markdown.doc"""

    simplex([::Type{T} = fmpq,] d::Int [,n::Rational])

Construct the simplex which is the convex hull of the standard basis vectors
along with the origin in $\mathbb{R}^d$, scaled by $n$.

# Examples
Here we take a look at the facets of the 7-simplex and a scaled 7-simplex:
```jldoctest
julia> s = simplex(7)
A polyhedron in ambient dimension 7

julia> facets(s)
8-element SubObjectIterator{AffineHalfspace{fmpq}} over the Halfspaces of R^7 described by:
-x₁ ≦ 0
-x₂ ≦ 0
-x₃ ≦ 0
-x₄ ≦ 0
-x₅ ≦ 0
-x₆ ≦ 0
-x₇ ≦ 0
x₁ + x₂ + x₃ + x₄ + x₅ + x₆ + x₇ ≦ 1

julia> t = simplex(7, 5)
A polyhedron in ambient dimension 7

julia> facets(t)
8-element SubObjectIterator{AffineHalfspace{fmpq}} over the Halfspaces of R^7 described by:
-x₁ ≦ 0
-x₂ ≦ 0
-x₃ ≦ 0
-x₄ ≦ 0
-x₅ ≦ 0
-x₆ ≦ 0
-x₇ ≦ 0
x₁ + x₂ + x₃ + x₄ + x₅ + x₆ + x₇ ≦ 5
```
"""
simplex(::Type{T}, d::Int64,n) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.simplex{scalar_type_to_polymake[T]}(d,n))
simplex(::Type{T}, d::Int64) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.simplex{scalar_type_to_polymake[T]}(d))
simplex(x...) = simplex(fmpq, x...)


@doc Markdown.doc"""

    cross([::Type{T} = fmpq,] d::Int [,n::Rational])

Construct a $d$-dimensional cross polytope around origin with vertices located
at $\pm e_i$ for each unit vector $e_i$ of $R^d$, scaled by $n$.

# Examples
Here we print the facets of a non-scaled and a scaled 3-dimensional cross
polytope:
```jldoctest
julia> C = cross(3)
A polyhedron in ambient dimension 3

julia> facets(C)
8-element SubObjectIterator{AffineHalfspace{fmpq}} over the Halfspaces of R^3 described by:
x₁ + x₂ + x₃ ≦ 1
-x₁ + x₂ + x₃ ≦ 1
x₁ - x₂ + x₃ ≦ 1
-x₁ - x₂ + x₃ ≦ 1
x₁ + x₂ - x₃ ≦ 1
-x₁ + x₂ - x₃ ≦ 1
x₁ - x₂ - x₃ ≦ 1
-x₁ - x₂ - x₃ ≦ 1

julia> D = cross(3, 2)
A polyhedron in ambient dimension 3

julia> facets(D)
8-element SubObjectIterator{AffineHalfspace{fmpq}} over the Halfspaces of R^3 described by:
x₁ + x₂ + x₃ ≦ 2
-x₁ + x₂ + x₃ ≦ 2
x₁ - x₂ + x₃ ≦ 2
-x₁ - x₂ + x₃ ≦ 2
x₁ + x₂ - x₃ ≦ 2
-x₁ + x₂ - x₃ ≦ 2
x₁ - x₂ - x₃ ≦ 2
-x₁ - x₂ - x₃ ≦ 2
```
"""
cross(::Type{T}, d::Int64,n) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.cross{scalar_type_to_polymake[T]}(d,n))
cross(::Type{T}, d::Int64) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.cross{scalar_type_to_polymake[T]}(d))
cross(x...) = cross(fmpq, x...)

@doc Markdown.doc"""

    archimedean_solid(s)

Construct an Archimedean solid with the name given by String `s` from the list
below.  The polytopes are realized with floating point numbers and thus not
exact; Vertex-facet-incidences are correct in all cases.

# Arguments
- `s::String`: The name of the desired Archimedean solid.
    Possible values:
    - "truncated_tetrahedron" : Truncated tetrahedron.
          Regular polytope with four triangular and four hexagonal facets.
    - "cuboctahedron" : Cuboctahedron.
          Regular polytope with eight triangular and six square facets.
    - "truncated_cube" : Truncated cube.
          Regular polytope with eight triangular and six octagonal facets.
    - "truncated_octahedron" : Truncated Octahedron.
          Regular polytope with six square and eight hexagonal facets.
    - "rhombicuboctahedron" : Rhombicuboctahedron.
          Regular polytope with eight triangular and 18 square facets.
    - "truncated_cuboctahedron" : Truncated Cuboctahedron.
          Regular polytope with 12 square, eight hexagonal and six octagonal
          facets.
    - "snub_cube" : Snub Cube.
          Regular polytope with 32 triangular and six square facets.
          The vertices are realized as floating point numbers.
          This is a chiral polytope.
    - "icosidodecahedron" : Icosidodecahedon.
          Regular polytope with 20 triangular and 12 pentagonal facets.
    - "truncated_dodecahedron" : Truncated Dodecahedron.
          Regular polytope with 20 triangular and 12 decagonal facets.
    - "truncated_icosahedron" : Truncated Icosahedron.
          Regular polytope with 12 pentagonal and 20 hexagonal facets.
    - "rhombicosidodecahedron" : Rhombicosidodecahedron.
          Regular polytope with 20 triangular, 30 square and 12 pentagonal
          facets.
    - "truncated_icosidodecahedron" : Truncated Icosidodecahedron.
          Regular polytope with 30 square, 20 hexagonal and 12 decagonal
          facets.
    - "snub_dodecahedron" : Snub Dodecahedron.
          Regular polytope with 80 triangular and 12 pentagonal facets.
          The vertices are realized as floating point numbers.
          This is a chiral polytope.

# Examples
```jldoctest
julia> T = archimedean_solid("cuboctahedron")
A polyhedron in ambient dimension 3

julia> sum([nvertices(F) for F in faces(T, 2)] .== 3)
8

julia> sum([nvertices(F) for F in faces(T, 2)] .== 4)
6

julia> nfacets(T)
14
```
"""
archimedean_solid(s::String) = Polyhedron(Polymake.polytope.archimedean_solid(s))


@doc Markdown.doc"""

    catalan_solid(s::String)

Construct a Catalan solid with the name `s` from the list
below.  The polytopes are realized with floating point coordinates and thus are not
exact. However, vertex-facet-incidences are correct in all cases.

# Arguments
- `s::String`: The name of the desired Archimedean solid.
    Possible values:
    - "triakis_tetrahedron" : Triakis Tetrahedron.
          Dual polytope to the Truncated Tetrahedron, made of 12 isosceles
          triangular facets.
    - "triakis_octahedron" : Triakis Octahedron.
          Dual polytope to the Truncated Cube, made of 24 isosceles triangular
          facets.
    - "rhombic_dodecahedron" : Rhombic dodecahedron.
          Dual polytope to the cuboctahedron, made of 12 rhombic facets.
    - "tetrakis_hexahedron" : Tetrakis hexahedron.
          Dual polytope to the truncated octahedron, made of 24 isosceles
          triangluar facets.
    - "disdyakis_dodecahedron" : Disdyakis dodecahedron.
          Dual polytope to the truncated cuboctahedron, made of 48 scalene
          triangular facets.
    - "pentagonal_icositetrahedron" : Pentagonal Icositetrahedron.
          Dual polytope to the snub cube, made of 24 irregular pentagonal facets.
          The vertices are realized as floating point numbers.
    - "pentagonal_hexecontahedron" : Pentagonal Hexecontahedron.
          Dual polytope to the snub dodecahedron, made of 60 irregular pentagonal
          facets. The vertices are realized as floating point numbers.
    - "rhombic_triacontahedron" : Rhombic triacontahedron.
          Dual polytope to the icosidodecahedron, made of 30 rhombic facets.
    - "triakis_icosahedron" : Triakis icosahedron.
          Dual polytope to the icosidodecahedron, made of 30 rhombic facets.
    - "deltoidal_icositetrahedron" : Deltoidal Icositetrahedron.
          Dual polytope to the rhombicubaoctahedron, made of 24 kite facets.
    - "pentakis_dodecahedron" : Pentakis dodecahedron.
          Dual polytope to the truncated icosahedron, made of 60 isosceles
          triangular facets.
    - "deltoidal_hexecontahedron" : Deltoidal hexecontahedron.
          Dual polytope to the rhombicosidodecahedron, made of 60 kite facets.
    - "disdyakis_triacontahedron" : Disdyakis triacontahedron.
          Dual polytope to the truncated icosidodecahedron, made of 120 scalene
          triangular facets.


# Examples
```jldoctest
julia> T = catalan_solid("triakis_tetrahedron");

julia> count(F -> nvertices(F) == 3, faces(T, 2))
12

julia> nfacets(T)
12
```
"""
catalan_solid(s::String) = Polyhedron(Polymake.polytope.catalan_solid(s))


@doc Markdown.doc"""

    upper_bound_f_vector(d::Int, n::Int)

Return the maximal f-vector of a `d`-polytope with `n` vertices;
this is given by McMullen's Upper-Bound-Theorem.
"""
upper_bound_f_vector(d::Int,n::Int) = Vector{Int}(Polymake.polytope.upper_bound_theorem(d,n).F_VECTOR)

@doc Markdown.doc"""

    upper_bound_g_vector(d::Int, n::Int)

Return the maximal g-vector of a `d`-polytope with `n` vertices;
this is given by McMullen's Upper-Bound-Theorem.
"""
upper_bound_g_vector(d::Int,n::Int) = Vector{Int}(Polymake.polytope.upper_bound_theorem(d,n).G_VECTOR)

@doc Markdown.doc"""

    upper_bound_h_vector(d::Int, n::Int)

Return the maximal h-vector of a `d`-polytope with `n` vertices;
this is given by McMullen's Upper-Bound-Theorem.
"""
upper_bound_h_vector(d::Int,n::Int) = Vector{Int}(Polymake.polytope.upper_bound_theorem(d,n).H_VECTOR)


@doc Markdown.doc"""
    polarize(P::Polyhedron)

Return the polar dual of the polyhedron `P`, consisting of all linear functions
whose evaluation on `P` does not exceed 1.

# Examples
```jldoctest
julia> square = cube(2)
A polyhedron in ambient dimension 2

julia> P = polarize(square)
A polyhedron in ambient dimension 2

julia> vertices(P)
4-element SubObjectIterator{PointVector{fmpq}}:
 [1, 0]
 [-1, 0]
 [0, 1]
 [0, -1]
```
"""
function polarize(P::Polyhedron{T}) where T<:scalar_types
    return Polyhedron{T}(Polymake.polytope.polarize(pm_object(P)))
end


@doc Markdown.doc"""

    project_full(P::Polyhedron)

Project the polyhedron down such that it becomes full dimensional in the new
ambient space.

```jldoctest
julia> P = convex_hull([1 0 0; 0 0 0])
A polyhedron in ambient dimension 3

julia> is_fulldimensional(P)
false

julia> p = project_full(P)
A polyhedron in ambient dimension 1

julia> is_fulldimensional(p)
true
```
"""
project_full(P::Polyhedron{T}) where T<:scalar_types = Polyhedron{T}(Polymake.polytope.project_full(pm_object(P)))

@doc Markdown.doc"""

    gelfand_tsetlin(lambda::AbstractVector)

Construct the Gelfand Tsetlin polytope indexed by a weakly decreasing vector `lambda`.

```jldoctest
julia> P = gelfand_tsetlin([5,3,2])
A polyhedron in ambient dimension 6

julia> is_fulldimensional(P)
false

julia> p = project_full(P)
A polyhedron in ambient dimension 3

julia> is_fulldimensional(p)
true

julia> volume(p)
3
```
"""
gelfand_tsetlin(lambda::AbstractVector) = Polyhedron{fmpq}(Polymake.polytope.gelfand_tsetlin(Polymake.Vector{Polymake.Rational}(lambda), projected = false))

@doc Markdown.doc"""
    fano_simplex(d::Int)

Construct a lattice simplex such that the origin is the unique interior lattice point.
The normal toric variety associated with its face fan is smooth.

```jldoctest
julia> S = fano_simplex(3)
A polyhedron in ambient dimension 3

julia> X = NormalToricVariety(face_fan(S))
A normal toric variety

julia> is_smooth(X)
true
```
"""
fano_simplex(d::Int) = Polyhedron{fmpq}(Polymake.polytope.fano_simplex(d))

@doc Markdown.doc"""
    del_pezzo_polytope(d::Int)

Produce the d-dimensional del Pezzo polytope, which is the convex hull of
the cross polytope together with the all-ones and minus all-ones vector.

```jldoctest
julia> DP = del_pezzo_polytope(4)
A polyhedron in ambient dimension 4

julia> f_vector(DP)
4-element Vector{fmpz}:
 10
 40
 60
 30
```
"""
del_pezzo_polytope(d::Int) = Polyhedron{fmpq}(Polymake.polytope.delpezzo(d))



@doc Markdown.doc"""
    cyclic_polytope(d::Int, n::Int)

Construct the cyclic polytope that is the convex hull of $n$ points on the
moment curve in dimension $d$.


# Examples
```jldoctest
julia> cp = cyclic_polytope(3, 20)
A polyhedron in ambient dimension 3

julia> nvertices(cp)
20
```
"""
cyclic_polytope(d::Int, n::Int) = Polyhedron(Polymake.polytope.cyclic(d, n))
