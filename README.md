# elixir-avro

`elixir-avro` is a library designed to facilitate the conversion of Avro schemas into Elixir code. 
This library bridges the gap between Avro schema definitions and Elixir code, enabling seamless integration of 
Avro-defined data structures into Elixir projects.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_avro` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_avro, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/elixir_avro>.

## Usage

Run this command to generate Elixir code from Avro schema files:

```shell

```

This will generate Elixir code for the Avro schema files in the `avro` directory, one for each Avro type defined in the schemas.

## Example

Given the following Avro schema definition in `avro/user.avsc`:

```json
{
  "name": "User",
  "namespace": "registry",
  "fullname": "registry.User",
  "doc": "User registry information",
  "type": "record",
  "fields": [
    {
      "name": "firstname",
      "type": "string"
    },
    {
      "name": "lastname",
      "type": "string"
    },
    {
      "name": "age",
      "type": "int"
    },
    {
      "name": "role",
      "type": {
        "type": "enum",
        "name": "Role",
        "doc": "User's role.",
        "fullname": "registry.user.Role",
        "namespace": "registry.user",
        "symbols": [
          "ADMIN",
          "USER"
        ]
      }
    }
  ]
}
```

Running the following command:

```shell
mix elixir_avro_codegen --schemas-path avro/ --target-path lib --prefix MyApp.Avro
```

Will generate the following Elixir code in `lib/`:

```elixir
# lib/my_app/avro/registry/user.ex
defmodule MyApp.Avro.Registry.User do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  User registry information

  ### Fields
  - __fullname__: User's full name
  - __role__: User's role.
  """

  use TypedStruct

  alias ElixirAvro.AvroType.Value.Decoder
  alias ElixirAvro.AvroType.Value.Encoder

  @expected_keys MapSet.new(["fullname", "role"])

  typedstruct do
    field(:fullname, String.t(), enforce: true)
    field(:role, MyApp.Avro.Registry.User.Role.t(), enforce: true)
  end

  @module_prefix MyApp.Avro

  def to_avro(%__MODULE__{} = struct) do
    {:ok,
     %{
      # ...
     }}
  end

  def from_avro(%{"fullname" => fullname, "role" => role}) do
    {:ok,
     %__MODULE__{
      # ...
     }}
  rescue
    e -> {:error, inspect(e)}
  end

  # ...
end
```

```elixir
# lib/my_app/avro/registry/user/role.ex
defmodule MyApp.Avro.Registry.User.Role do
  @moduledoc """
  DO NOT EDIT MANUALLY: This module was automatically generated from an AVRO schema.

  ### Description
  User's role.

  """

  use ElixirAvro.Macro.ElixirEnum

  @values ["ADMIN", "USER"]

  def to_avro(value) do
    {:ok, to_avro_string(value)}
  rescue
    _ -> {:error, :invalid_enum_value}
  end

  def from_avro(value) do
    {:ok, from_avro_string(value)}
  rescue
    _ -> {:error, :invalid_enum_string_value}
  end
end
```

The generated path is a concatenation of the `--prefix` option (snake-cased) and the Avro schema type's namespace.

## CLI Options

```
Usage: mix elixir_avro_codegen <-s directory> <-t directory> <-p name> [-v]
-s, --schemas-path <directory>    The path to the directory containing the Avro schema files.
-t, --target-path <directory>     The path to the directory where the generated Elixir code will be saved.
-p, --prefix <name>               The prefix to be used for the generated Elixir modules.
-v, --verbose                     Enable verbose output.
```

## Compile-time generation

In your mix.exs file, in `project` function, add the following configuration:

```elixir
  def project do
    [
      # ...
      elixir_avro_codegen: [
        schema_path: "avro",
        target_path: "avro",
        prefix: "MyApp.Avro"
      ],
      compilers: Mix.compilers() ++ [:elixir_avro_codegen],
      # ...
    ]
  end
```

The parameters used in the `elixir_avro_codegen` configuration are the same as the CLI options.

## License

### The MIT License (MIT)

Copyright (c) 2020 Prima.it

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.