defmodule Ash.Vector do
  @moduledoc """
  A vector struct for Ash.

  Implementation based off of https://github.com/pgvector/pgvector-elixir/blob/v0.2.0/lib/pgvector.ex
  """

  defstruct [:data]

  @doc """
  Creates a new vector from a list or tensor
  """
  def new(binary) when is_binary(binary) do
    from_binary(binary)
  end

  def new(%__MODULE__{} = vector), do: {:ok, vector}

  def new(list) when is_list(list) do
    # this definitely has failure cases
    dim = list |> length()
    bin = for v <- list, into: "", do: <<v::float-32>>
    {:ok, from_binary(<<dim::unsigned-16, 0::unsigned-16, bin::binary>>)}
  rescue
    _ -> {:error, :invalid_vector}
  end

  @doc """
  Creates a new vector from its binary representation
  """
  def from_binary(binary) when is_binary(binary) do
    %Ash.Vector{data: binary}
  end

  @doc """
  Converts the vector to its binary representation
  """
  def to_binary(vector) when is_struct(vector, Ash.Vector) do
    vector.data
  end

  @doc """
  Converts the vector to a list
  """
  def to_list(vector) when is_struct(vector, Ash.Vector) do
    <<dim::unsigned-16, 0::unsigned-16, bin::binary-size(dim)-unit(32)>> = vector.data
    for <<v::float-32 <- bin>>, do: v
  end
end

defimpl Inspect, for: Ash.Vector do
  import Inspect.Algebra

  def inspect(vec, opts) do
    concat(["Ash.Vector.new(", Inspect.List.inspect(Ash.Vector.to_list(vec), opts), ")"])
  end
end
