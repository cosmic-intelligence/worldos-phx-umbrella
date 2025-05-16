# ChatUmbrellaTest

**TODO: Add description**
# ➊ umbrella skeleton
mix new chat_umbrella --umbrella
cd chat_umbrella/apps     # every child lives here

# ➋ domain/data app (binary UUID PKs, no web assets)
mix phx.new.ecto core --binary-id

# ➌ gateway – Channels + JSON only
mix phx.new.web gateway_web --no-html --no-assets --no-live
# (command must be run inside apps/ – see docs)  [oai_citation:1‡HexDocs](https://hexdocs.pm/phoenix/1.6.15/Mix.Tasks.Phx.New.Web.html?utm_source=chatgpt.com)

# ➍ Python bridge library
mix new ai_bridge