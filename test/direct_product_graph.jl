using Graphs, MetaGraphs, MolecularGraphKernels, SparseArrays, Test

include("check_isom.jl")

A = MetaGraph(3)
B = MetaGraph(3)

add_edge!(A, 1, 2, Dict(:label => :single))
add_edge!(A, 2, 3, Dict(:label => :single))
add_edge!(A, 3, 1, Dict(:label => :single))

add_edge!(B, 1, 2, Dict(:label => :single))
add_edge!(B, 2, 3, Dict(:label => :single))
add_edge!(B, 3, 1, Dict(:label => :double))

set_prop!(A, 1, :label, :C)
set_prop!(A, 2, :label, :C)
set_prop!(A, 3, :label, :C)

set_prop!(B, 1, :label, :C)
set_prop!(B, 2, :label, :C)
set_prop!(B, 3, :label, :C)

adj_mat = direct_product_graph(A, B)

@testset "direct_product_graph" begin

    @test adj_mat == sparse(
        [5, 6, 4, 6, 4, 5, 2, 3, 8, 9, 1, 3, 7, 9, 1, 2, 7, 8, 5, 6, 4, 6, 4, 5], 
        [1, 1, 2, 2, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 8, 8, 9, 9], 
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        9, 9
    )

    C = MetaGraph(2)

    add_edge!(C, 1, 2, Dict(:label => 1))
    set_prop!(C, 1, :label, :H)
    set_prop!(C, 2, :label, :H)

    @test direct_product_graph(C, C) == direct_product_graph(MetaGraph(smilestomol("[H]-[H]")), C)
end

@testset "return_graph" begin

    dpg = direct_product_graph(A, B, return_graph=true)

    @test adj_mat == adjacency_matrix(dpg)

    g = MetaGraph(smilestomol("COP(=O)(OC)OC(Br)C(Cl)(Cl)Br"))
    h = MetaGraph(smilestomol("COP(N)(=O)SC"))

    gxh = MetaGraph(17)
    set_prop!(gxh, 1, :label, :P)
    set_prop!(gxh, 2, :label, :O)
    set_prop!(gxh, 3, :label, :O)
    set_prop!(gxh, 4, :label, :O)
    set_prop!(gxh, 5, :label, :O)
    set_prop!(gxh, 6, :label, :O)
    set_prop!(gxh, 7, :label, :O)
    set_prop!(gxh, 8, :label, :O)
    set_prop!(gxh, 9, :label, :O)
    set_prop!(gxh, 10, :label, :C)
    set_prop!(gxh, 11, :label, :C)
    set_prop!(gxh, 12, :label, :C)
    set_prop!(gxh, 13, :label, :C)
    set_prop!(gxh, 14, :label, :C)
    set_prop!(gxh, 15, :label, :C)
    set_prop!(gxh, 16, :label, :C)
    set_prop!(gxh, 17, :label, :C)
    add_edge!(gxh, 1, 2, Dict(:label => 2))
    add_edge!(gxh, 1, 3, Dict(:label => 1))
    add_edge!(gxh, 1, 4, Dict(:label => 1))
    add_edge!(gxh, 1, 5, Dict(:label => 1))
    add_edge!(gxh, 3, 10, Dict(:label => 1))
    add_edge!(gxh, 4, 11, Dict(:label => 1))
    add_edge!(gxh, 5, 12, Dict(:label => 1))

    dpg = direct_product_graph(g, h, return_graph=true)

    @test is_isomorphic(dpg, gxh)
end

@testset "SMILES flexibility" begin

    A = smilestomol("c1ccccc1")
    B = smilestomol("C1C=CC=CC=1")
    C = smilestomol("C1=CC=CC=C1")
    D = smilestomol("c1-c-c-c-c-c1")

    B, C, D = MetaGraph.([B, C, D])

    @test is_isomorphic(direct_product_graph(A, A, return_graph=true), direct_product_graph(B, B, return_graph=true))
    @test is_isomorphic(direct_product_graph(B, C, return_graph=true), direct_product_graph(C, D, return_graph=true))
end
