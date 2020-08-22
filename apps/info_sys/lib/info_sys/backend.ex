defmodule InfoSys.Backend do
  @moduledoc """
  An OTP behaviour for our backend interface. It consists of two callbacks,
  `name` and `compute`.
  """

  @callback name() :: String.t()

  @callback compute(query :: String.t(), opts :: Keyword.t()) :: [%InfoSys.Result{}]
end
