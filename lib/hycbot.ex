defmodule HYCBot do
  @moduledoc """
  Documentation for `Hycbot`.
  """

  @openweather_api_key System.get_env("OPENWEATHER_API_KEY")
  @openweather "https://api.openweathermap.org/data/2.5/onecall?lat=42.262722588636954&lon=-70.89326654215711&exclude=minutely,daily,alerts&appid=#{@openweather_api_key}&units=imperial"
  @discourse_api_key System.get_env("DISCOURSE_API_KEY")
  @hycdiscourse_url System.get_env("DISCOURSE_URL")

  @timezone "America/New_York"

  def tides_url() do
    epoch =
      DateTime.now!(@timezone)
      |> DateTime.to_unix()

    "https://hightide.earth/api/tides?heights&datum=MLLW&extremes&length=43200&step=3600&stationDistance=100&start=#{epoch}&lon=-70.89326654215711&lat=42.262722588636954"
  end

  def render(:laser_friday) do
    data =
      fetch_data()
      |> parse_data()

    %{raw: EEx.eval_file("lib/templates/laser-friday.eex", assigns: data), topic_id: 53}
  end

  def render(:laser_sunday) do
    data =
      fetch_data()
      |> parse_data()

    %{raw: EEx.eval_file("lib/templates/laser-sunday.eex", assigns: data), topic_id: 53}
  end

  def render(:handicap_wednesday) do
    data =
      fetch_data()
      |> parse_data()

    %{raw: EEx.eval_file("lib/templates/handicap-wednesday.eex", assigns: data), topic_id: 77}
  end

  def render(:laser_salty_dog_june) do
    data =
      fetch_data()
      |> parse_data()

    %{raw: EEx.eval_file("lib/templates/laser-salty-dog-june.eex", assigns: data), topic_id: 53}
  end

  def render_print(type) do
    render(type) |> IO.inspect()
  end

  def post_conditions(type) do
    render = render(type)
    HTTPoison.post(@hycdiscourse_url, Jason.encode!(%{raw: render.raw, topic_id: render.topic_id}), [{"Api-Key", @discourse_api_key},{"Content-Type", "application/json"}])
  end

  def parse_data(data) do
    sunset = parse_sunset(data.weather)
    weather = parse_weather_range(data.weather, 5)
    next_tide = parse_next_tide(data.tides)

    %{sunset: sunset, weather: weather, tide: next_tide, current_date: current_date()}
  end

  defp current_date() do
    DateTime.now!(@timezone) |> Calendar.strftime("%-m/%-d")
  end

  def parse_sunset(weather) do
    weather
    |> Map.get("current")
    |> Map.get("sunset")
    |> convert_unix_to_datetime()
    |> Calendar.strftime("%-I:%M %p")
  end

  defp convert_unix_to_datetime(unixtime) do
    unixtime
    |> DateTime.from_unix!()
    |> DateTime.shift_zone!(@timezone)
  end

  def parse_weather_range(weather, hours) do
    weather
    |> Map.get("hourly")
    |> Enum.take(hours)
    |> Enum.map(fn(hour) ->
      %{
        hour: convert_unix_to_datetime(hour["dt"]) |> Calendar.strftime("%-I%P"),
        temp: round(hour["temp"]),
        direction: convert_wind_deg(hour["wind_deg"]),
        gust: convert_mph_to_knts(hour["wind_gust"]),
        speed: convert_mph_to_knts(hour["wind_speed"]),
        description: hour["weather"] |> List.first() |> Map.get("description")
      }
    end)
  end

  def convert_mph_to_knts(mph) do
    Float.round(mph * 0.86897624190065, 2)
  end

  def convert_wind_deg(degrees) when degrees in 0..11 or degrees in 349..360, do: "N"
  def convert_wind_deg(degrees) when degrees in 11..34, do: "NNE"
  def convert_wind_deg(degrees) when degrees in 34..56, do: "NE"
  def convert_wind_deg(degrees) when degrees in 56..79, do: "ENE"
  def convert_wind_deg(degrees) when degrees in 79..101, do: "E"
  def convert_wind_deg(degrees) when degrees in 101..124, do: "ESE"
  def convert_wind_deg(degrees) when degrees in 124..146, do: "SE"
  def convert_wind_deg(degrees) when degrees in 146..169, do: "SSE"
  def convert_wind_deg(degrees) when degrees in 169..191, do: "S"
  def convert_wind_deg(degrees) when degrees in 191..214, do: "SSW"
  def convert_wind_deg(degrees) when degrees in 214..236, do: "SW"
  def convert_wind_deg(degrees) when degrees in 236..259, do: "WSW"
  def convert_wind_deg(degrees) when degrees in 259..281, do: "W"
  def convert_wind_deg(degrees) when degrees in 281..304, do: "WNW"
  def convert_wind_deg(degrees) when degrees in 304..326, do: "NW"
  def convert_wind_deg(degrees) when degrees in 326..349, do: "NNW"

  def parse_next_tide(tides) do
    next_tide =
      tides
      |> Map.get("extremes")
      |> List.first()

    %{
      type: next_tide["type"],
      height: convert_meters_to_feet(next_tide["height"]),
      time: next_tide["dt"] |> convert_unix_to_datetime() |> Calendar.strftime("%-I:%M %p")
    }
  end

  defp convert_meters_to_feet(meters) do
    Float.round(meters * 3.28084, 2)
  end

  def fetch_data() do
    {:ok, weather} = fetch(@openweather)
    {:ok, tides} = tides_url() |> fetch()
    %{weather: weather, tides: tides}
  end

  def fetch(url) do
    {:ok, result} = HTTPoison.get(url)
    Jason.decode(result.body)
  end
end
