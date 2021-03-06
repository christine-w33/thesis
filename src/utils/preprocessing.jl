
@doc doc"""
    All preprocessors must implement traindata, testdata and output methods.
""" ->
abstract Preprocessor

traindata(obj::Preprocessor) = error("traindata has not been implemented for type $(typeof(obj)).")
traindata(obj::Preprocessor, args::Dict) = error("traindata has not been implemented for type $(typeof(obj)).")
testdata(obj::Preprocessor) = error("testdata has not been implemented for type $(typeof(obj)).")
testdata(obj::Preprocessor, args::Dict) = error("testdata has not been implemented for type $(typeof(obj)).")


@doc doc"""
    scales a function to between 0 and 1 based on min and max of the input pattern.
""" ->
function scale(pattern, epsilon=0.0001)
    return (pattern - minimum(pattern)) / (maximum(pattern) + epsilon)
end

@doc doc"""
    takes the float point label and builds a binary
    pattern from that.
""" ->
function binary_label(label)
    bitstr = _get_bitstr(label)
    len = length(bitstr)
    binlabel = zeros(len)

    for i in 1:len
        if bitstr[i] == '1'
            binlabel[i] = 1
        end
    end

    return binlabel
end

@doc doc"""
    performs down sampling on a 2d array.
""" ->
function down_sample(patterns, batch_n_cols::Int64, batch_n_rows::Int64,
        cols::Int64, rows::Int64)
    println("Downsampling")
    pattern_length = int(ceil(size(patterns, 1)/(batch_n_cols * batch_n_rows)))
    new_patterns = Array(Float64, pattern_length, int(size(patterns, 2)))

    for i in 1:size(patterns, 2)
        new_patterns[:, i] = reshape(_avg(_batch(reshape(patterns[:, i], cols, rows), batch_n_cols, batch_n_rows)), pattern_length, 1)
    end

    return new_patterns
end

function _get_bitstr(label::Float64)
    return bits(convert(UInt8, label))
end

function _batch(pattern, batch_n_cols, batch_n_rows)
   num_batches = int(ceil(length(pattern) / (batch_n_cols * batch_n_rows)))
   batches = Array(Array, num_batches)

   count = 1
   for i in 1:(size(pattern, 1) / batch_n_cols)
       for j in 1:(size(pattern, 2) / batch_n_rows)
            batches[count] = reshape(
                pattern[((i-1)*batch_n_cols + 1):min(i*batch_n_cols, size(pattern, 1)), ((j-1)*batch_n_rows + 1):min(j*batch_n_rows, size(pattern, 2))],
                (batch_n_cols * batch_n_rows),
                1
            )
            count += 1
       end
   end
   return batches
end

function _avg(batches)
    averages = Array(Float64, length(batches))

    for i in 1:length(batches)
        averages[i] = sum(batches[i])/length(batches[i])
    end

    return averages
end


const preprocessing = [
    "mnist"
]

for preprocess in preprocessing
    include(joinpath("preprocessing", "$(preprocess).jl"))
end
