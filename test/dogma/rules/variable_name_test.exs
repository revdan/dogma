defmodule Dogma.Rules.VariableNameTest do
  use DogmaTest.Helper

  alias Dogma.Rules.VariableName
  alias Dogma.Script
  alias Dogma.Error

  def test(script) do
    script |> Script.parse( "foo.ex" ) |> VariableName.test
  end

  with "valid names" do
    setup context do
      errors = """
      x       = :ok
      foo     = :ok
      foo_bar = :ok
      """ |> test
      %{ errors: errors }
    end
    should_register_no_errors
  end

  with "invalid names" do
    setup context do
      errors = """
      fooBar  = :error
      foo_Bar = :error
      """ |> test
      %{ errors: errors }
    end
    should_register_errors [
      %Error{
        rule:     VariableName,
        message:  "Variable names should be in snake_case",
        line: 2,
      },
      %Error{
        rule:     VariableName,
        message:  "Variable names should be in snake_case",
        line: 1,
      },
    ]
  end

  with "" do
    setup context do
      errors = """
      [foo, bar] = foo_bar
      {fooBar}   = foo_bar
      """ |> test
      %{ errors: errors }
    end
    # For now we just want to show that we can not explode when the thing on
    # the left hand side of the match operator isn't just a variable name.
    should_register_no_errors
  end
end
