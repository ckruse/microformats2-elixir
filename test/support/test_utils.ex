defmodule Microformats2.TestUtils do
  def suite_document(name) do
    html = File.read!("./test/documents/suite-v2/#{name}.html")
    json = File.read!("./test/documents/suite-v2/#{name}.json") |> Jason.decode!()

    {html, json}
  end
end
