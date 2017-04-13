%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: []
      },
      checks: [
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 120},
        {Credo.Check.Design.DuplicatedCode, mass_threshold: 57},
        {Credo.Check.Refactor.ABCSize, max_size: 33}
      ]
    }
  ]
}
