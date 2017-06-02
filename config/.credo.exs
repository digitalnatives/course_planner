%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: ["web/controllers/coherence/session_controller.ex"]
      },
      checks: [
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 100},
        {Credo.Check.Design.DuplicatedCode, mass_threshold: 57},
        {Credo.Check.Refactor.ABCSize, max_size: 33},
        {Credo.Check.Consistency.MultiAliasImportRequireUse, false}
      ]
    }
  ]
}
