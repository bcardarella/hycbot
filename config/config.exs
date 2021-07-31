use Mix.Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :hycbot, HYCBot.Scheduler,
  jobs: [
    {"00 16 * * FRI", {HYCBot, :post_conditions, [:laser_friday]}},
    {"00 11 * * SUN", {HYCBot, :post_conditions, [:laser_sunday]}},
    {"30 16 * * WED", {HYCBot, :post_conditions, [:handicap_wednesday]}},
    {"30 16 * * THU", {HYCBot, :post_conditions, [:rhodes_thursday]}},
    {"00 11 * * SUN", {HYCBot, :post_conditions, [:rhodes_sunday]}},
    {"00 10 26 6 *", {HYCBot, :post_conditions, [:laser_salty_dog_june]}}
  ],
  debug_logging: false,
  timezone: "America/New_York"

  config :gen_tcp_accept_and_close, port: 4000
  config :gen_tcp_accept_and_close, ip: {0, 0, 0, 0}
