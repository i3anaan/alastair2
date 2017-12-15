defmodule Alastair.Notification do
  @derive [Poison.Encoder]
  @enforce_keys [:audience_type, :audience_params, :category, :category_name, :heading, :body]
  defstruct [:audience_type, :audience_params, :category, :category_name, :heading, :heading_link, :heading_link_params, :heading_url, :body, :time, :service]
end