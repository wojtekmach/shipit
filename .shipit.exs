# check archive url
"v" <> version = version
unless File.read!("README.md") |> String.contains?("shipit-#{version}.ez") do
  Mix.raise "archive url is missing version #{version}"
end
