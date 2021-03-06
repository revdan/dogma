defmodule Dogma.Rules.PredicateName do
  @moduledoc """
  A rule that disallows tautological predicate names.
  """

  @behaviour Dogma.Rule
  alias Dogma.Script
  alias Dogma.Error

  def test(script) do
    script |> Script.walk( &check_node(&1, &2) )
  end

  defp check_node({:def, _, [{name, meta, _}|_]} = node, errors) do
    test_predicate(name, meta, node, errors)
  end
  defp check_node({:defp, _, [{name, meta, _}|_]} = node, errors) do
    test_predicate(name, meta, node, errors)
  end
  defp check_node(node, errors) do
    {node, errors}
  end

  defp test_predicate(line) do
    Regex.run(~r{\A(is|has)_(\w+)\?\Z}, line)
  end

  defp test_predicate({:unquote,_,_} , _meta, node, errors) do
    {node, errors}
  end

  defp test_predicate(function_name, meta, node, errors) do
    name = function_name |> to_string |> test_predicate
    if name do
      {node, [error( meta[:line], name ) | errors]}
    else
      {node, errors}
    end
  end

  defp error(pos, [name, _prefix, suffix]) do
    %Error{
      rule:     __MODULE__,
      message:  "Favour `#{suffix}?` over `#{name}`",
      line: pos,
    }
  end
end
