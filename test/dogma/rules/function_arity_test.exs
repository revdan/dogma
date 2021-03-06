defmodule Dogma.Rules.FunctionArityTest do
  use DogmaTest.Helper

  alias Dogma.Rules.FunctionArity
  alias Dogma.Script
  alias Dogma.Error

  def test(script) do
    script |> Script.parse( "foo.ex" ) |> FunctionArity.test
  end


  with "valid arity" do
    setup context do
      errors = """
      def something() do
      end

      def something_else do
      end

      def point(a,b,c,d) do
      end

      def has_defaults(a,b,c,d \\\\[]) do
      end

      def point(a,b,c,{d, e, f}) do
      end
      """ |> test
      %{ errors: errors }
    end
    should_register_no_errors
  end

  with "valid arity in a protocol definition" do
    setup context do
      errors = """
      defprotocol Some.Protocol do
        def run(thing, context)
      end
      """ |> test
      %{ errors: errors }
    end
    should_register_no_errors
  end

  with "invalid arity" do
    setup context do
      errors = """
      def point(a,b,c,d,e) do
      end
      """ |> test
      %{ errors: errors }
    end
    should_register_errors [
      %Error{
        rule:     FunctionArity,
        message:  "Function arity should be 4 or less",
        line: 1,
      }
    ]
  end

  with "invalid arity based on custom config" do
    setup context do
      errors = """
      def point(a,b,c) do
      end
      """
        |> Script.parse( "foo.ex" )
        |> FunctionArity.test(max: 2)

      %{ errors: errors }
    end
    should_register_errors [
      %Error{
        rule:     FunctionArity,
        message:  "Function arity should be 2 or less",
        line: 1,
      }
    ]
  end
end
