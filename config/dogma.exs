use Mix.Config
alias Dogma.Rule

config :dogma,
  exclude: [
    ~r(\Atest/.*)
  ],
  override: [
    %Rule.LineLength{ max_length: 100 },
  ]
