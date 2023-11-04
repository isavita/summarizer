Mox.defmock(HTTPoison.BaseMock, for: HTTPoison.Base)
Application.put_env(:summarizer, :http_client, HTTPoison.BaseMock)
ExUnit.start()
