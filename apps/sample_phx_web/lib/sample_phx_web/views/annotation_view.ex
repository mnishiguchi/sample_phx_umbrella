defmodule SamplePhxWeb.AnnotationView do
  use SamplePhxWeb, :view

  def render("annotation.json", %{annotation: annotation}) do
    %{
      id: annotation.id,
      body: annotation.body,
      at: annotation.at,
      user: render_one(annotation.user, SamplePhxWeb.UserView, "user.json")
    }
  end
end
