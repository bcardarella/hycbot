use Mix.Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :hycbot, HYCBot.Scheduler,
  jobs: [
    {"* * * * *", {HYCBot, :render_print, [:laser_friday]}}
  ],
  debug_logging: false
