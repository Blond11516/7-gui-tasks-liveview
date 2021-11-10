import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :seven_gui_tasks_liveview, SevenGuiTasksLiveviewWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "5VRN5uG2tw8iRnd5AATxaOjLvnQx2HMH7EBwVoQTFZ4EuVqIHWe6YLFPYIX2rHzi",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
