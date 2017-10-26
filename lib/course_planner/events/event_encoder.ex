defimpl Poison.Encoder, for: CoursePlanner.Events.Event do
  def encode(%{__struct__: _} = event, options) do
    event
    |> build_response_map()
    |> Poison.Encoder.Map.encode(options)
  end

  defp build_response_map(event) do
    %{
      id: event.id,
      name: event.name,
      description: event.description,
      location: event.location,
      date: event.date,
      starting_time: event.starting_time,
      finishing_time: event.finishing_time
    }
  end
end
