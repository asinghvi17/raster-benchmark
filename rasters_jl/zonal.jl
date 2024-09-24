using Rasters, ArchGDAL, GeoDataFrames
import GeometryOps as GO
using Statistics
using Chairmarks

include("utils.jl")

# Load the data
data_dir = joinpath(dirname(@__DIR__), "data")
buffer_df = GeoDataFrames.read(joinpath(data_dir, "vector", "buffers.gpkg"))
buffer_df.geom = GO.tuples(buffer_df.geom) # convert to Julia form

raster_dir = joinpath(data_dir, "LC08_L1TP_190024_20200418_20200822_02_T1")
raster_files = filter(endswith(".TIF"), readdir(raster_dir; join = true))
band_names = (:B1, :B10, :B11, :B2, :B3, :B4, :B5, :B6, :B7, :B9)
stack_file = joinpath(data_dir, "stack.nc")

# Stack the rasters
Rasters.checkmem!(false) # Just in case, there's a bug here.  Doesn't change performance.
rstack = RasterStack(raster_files; name=band_names)
benchmark = @be zonal($(Statistics.mean), $rstack; of=$(buffer_df.geom), progress=false) seconds=30 evals=5
zonal(Statistics.mean, rstack; of=buffer_df.geom, progress=false)

write_benchmark_as_csv(benchmark; task = "zonal")
