use Mix.Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :hycbot, HYCBot.Scheduler,
  jobs: [
    {"00 16 * * FRI", {HYCBot, :post_conditions, [:laser_friday]}},
    {"00 11 * * SUN", {HYCBot, :post_conditions, [:laser_sunday]}}
  ],
  debug_logging: false,
  timezone: "America/New_York"
