defmodule ElixirAvro.AvroType.LogicalType do
  @moduledoc nil

  require Decimal

  @custom_logical_types Application.compile_env(:elixir_avro, :custom_logical_types, %{})

  # see: https://avro.apache.org/docs/1.11.0/spec.html#Logical+Types
  @supported_logical_types_spec_strings %{
    {"bytes", "decimal"} => "Decimal.t()",
    {"string", "uuid"} => "String.t()",
    {"int", "date"} => "Date.t()",
    {"int", "time-millis"} => "Time.t()",
    {"long", "time-micros"} => "Time.t()",
    {"long", "timestamp-millis"} => "DateTime.t()",
    {"long", "timestamp-micros"} => "DateTime.t()",
    {"long", "local-timestamp-millis"} => "NaiveDateTime.t()",
    {"long", "local-timestamp-micros"} => "NaiveDateTime.t()"
    # avro specific custom implemented duration (incompatible with Timex.Duration) - leaving it out for the moment
    # {"fixed", "duration"} => "ElixirBrod.Avro.Duration.t()"
  }

  @callback decode(any()) :: {:ok, any()} | {:error, String.t()}
  @callback encode(any()) :: {:ok, any()} | {:error, String.t()}

  @spec decode(any(), String.t(), String.t()) :: {:ok, any()} | {:error, String.t()}
  def decode(value, "int", "date") do
    if is_integer(value) do
      {:ok, Date.add(~D[1970-01-01], value)}
    else
      {:error, "not an integer value"}
    end
  end

  def decode(value, "int", "time-millis") do
    if is_integer(value) do
      {:ok, Time.add(~T[00:00:00.000], value, :millisecond)}
    else
      {:error, "not an integer value"}
    end
  end

  def decode(value, "long", "time-micros") do
    if is_integer(value) do
      {:ok, Time.add(~T[00:00:00.000000], value, :microsecond)}
    else
      {:error, "not an integer value"}
    end
  end

  def decode(value, "long", "timestamp-millis") do
    if is_integer(value) do
      DateTime.from_unix(value, :millisecond)
    else
      {:error, "not an integer value"}
    end
  end

  def decode(value, "long", "timestamp-micros") do
    if is_integer(value) do
      DateTime.from_unix(value, :microsecond)
    else
      {:error, "not an integer value"}
    end
  end

  def decode(value, "long", "local-timestamp-millis") do
    if is_integer(value) do
      {:ok, Timex.add(~N[1970-01-01 00:00:00.000000], Timex.Duration.from_milliseconds(value))}
    else
      {:error, "not an integer value"}
    end
  end

  def decode(value, "long", "local-timestamp-micros") do
    if is_integer(value) do
      {:ok, Timex.add(~N[1970-01-01 00:00:00.000000], Timex.Duration.from_microseconds(value))}
    else
      {:error, "not an integer value"}
    end
  end

  def decode(value, "string", "uuid") do
    case UUID.info(value) do
      {:ok, _} -> {:ok, value}
      _ -> {:error, "not a uuid value"}
    end
  end

  def decode(_, "bytes", "decimal") do
    {:error, "decimal decoding not implemented yet"}
  end

  Enum.map(@custom_logical_types, fn {{primitive, logical}, type} ->
    def decode(value, unquote(primitive), unquote(logical)) do
      apply(unquote(type), :decode, [value])
    end
  end)

  def decode(_, primitive_type, logical_type) do
    {:error, "#{logical_type}[#{primitive_type}] decoding not implemented"}
  end

  @spec encode(any(), String.t(), String.t()) :: {:ok, any()} | {:error, String.t()}
  def encode(value, "bytes", "decimal") do
    if Decimal.is_decimal(value) do
      {:error, "decimal encoding not implemented yet"}
    else
      {:error, "not a decimal value"}
    end
  end

  def encode(value, "int", "date") do
    case value do
      %Date{} -> {:ok, Date.diff(value, ~D[1970-01-01])}
      _ -> {:error, "not a date value"}
    end
  end

  def encode(value, "int", "time-millis") do
    case value do
      %Time{} ->
        {:ok, Time.diff(value, ~T[00:00:00.000], :millisecond)}

      _ ->
        {:error, "not a time value"}
    end
  end

  def encode(value, "long", "time-micros") do
    case value do
      %Time{} ->
        {:ok, Time.diff(value, ~T[00:00:00.000000], :microsecond)}

      _ ->
        {:error, "not a time value"}
    end
  end

  def encode(value, "long", "timestamp-millis") do
    case value do
      %DateTime{} ->
        {:ok, DateTime.to_unix(value, :millisecond)}

      _ ->
        {:error, "not a datetime value"}
    end
  end

  def encode(value, "long", "timestamp-micros") do
    case value do
      %DateTime{} ->
        {:ok, DateTime.to_unix(value, :microsecond)}

      _ ->
        {:error, "not a datetime value"}
    end
  end

  def encode(value, "long", "local-timestamp-millis") do
    case value do
      %NaiveDateTime{} ->
        {:ok, Timex.diff(value, ~N[1970-01-01 00:00:00.000000], :millisecond)}

      _ ->
        {:error, "not a naive datetime value"}
    end
  end

  def encode(value, "long", "local-timestamp-micros") do
    case value do
      %NaiveDateTime{} ->
        {:ok, Timex.diff(value, ~N[1970-01-01 00:00:00.000000], :microsecond)}

      _ ->
        {:error, "not a naive datetime value"}
    end
  end

  def encode(value, "string", "uuid") do
    case UUID.info(value) do
      {:ok, _} -> {:ok, value}
      _ -> {:error, "not a uuid value"}
    end
  end

  Enum.map(@custom_logical_types, fn {{primitive, logical}, type} ->
    def encode(value, unquote(primitive), unquote(logical)) do
      apply(unquote(type), :encode, [value])
    end
  end)

  def encode(_, primitive_type, logical_type) do
    {:error, "#{logical_type}[#{primitive_type}] encoding not implemented"}
  end

  @spec to_typedstruct_spec!(String.t(), String.t()) :: String.t() | no_return()
  Enum.map(@supported_logical_types_spec_strings, fn {{primitive, logical}, type} ->
    def to_typedstruct_spec!(unquote(primitive), unquote(logical)), do: unquote(type)
  end)

  Enum.map(@custom_logical_types, fn {{primitive, logical}, type} ->
    def to_typedstruct_spec!(unquote(primitive), unquote(logical)) do
      "#{to_string(unquote(type))}.t()"
    end
  end)

  def to_typedstruct_spec!(name, logical) do
    raise ArgumentError, message: "unsupported logical type: #{name} => #{logical}"
  end
end
