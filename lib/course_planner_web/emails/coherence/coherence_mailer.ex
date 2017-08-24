defmodule CoursePlannerWeb.Coherence.Mailer do
  @moduledoc false
  alias Coherence.Config

  if Config.mailer?() do
    use Swoosh.Mailer, otp_app: :coherence
  end
end
