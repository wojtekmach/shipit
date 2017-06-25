defmodule Mix.Tasks.Shipit do
  use Mix.Task

  @shortdoc "Publishes a new package version"

  @moduledoc """
  ShipIt is an opinionated package publisher for Elixir.

      mix shipit BRANCH VERSION

  It assumes the following:

  - as usual, packages are published to Hex.pm and docs to HexDocs.pm
  - for each release, a tag is created and pushed to git
  - CHANGELOG.md is present and updated with the release
  - LICENSE.md is present

  A `--dry-run` option might be given to only perform local checks.
  """

  @changelog "CHANGELOG.md"
  @license "LICENSE.md"

  @switches [dry_run: :boolean]

  def run(args) do
    case OptionParser.parse(args, strict: @switches) do
      {opts, [branch, version], []} ->
        project = Mix.Project.config()
        version = normalize_version(project, version)

        check_working_tree()
        check_branch(branch)
        check_remote_branch(branch)
        check_changelog(version)
        check_license()

        unless opts[:dry_run] do
          publish()
          create_and_push_tag(version)
        end
      _ ->
        Mix.raise "Usage: mix shipit BRANCH VERSION [--dry-run]"
    end
  end

  defp check_working_tree() do
    {out, 0} = System.cmd("git", ["status", "--porcelain"])
    if out != "" do
      Mix.raise "Found uncommitted changes in the working tree"
    end
  end

  defp check_branch(branch) do
    current_branch = current_branch()
    if branch != current_branch do
      Mix.raise "Expected branch #{inspect branch} does not match the current branch #{inspect current_branch}"
    end
  end

  defp check_remote_branch(local_branch) do
    {_, 0} = System.cmd("git", ["fetch"])

    {out, 0} = System.cmd("git", ["status", "--branch", local_branch, "--porcelain"])

    if String.contains?(out, "ahead") do
      Mix.raise "Local branch is ahead the remote branch, aborting"
    end

    if String.contains?(out, "behind") do
      Mix.raise "Local branch is behind the remote branch, aborting"
    end
  end

  defp current_branch() do
    {branch, 0} = System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"])
    String.trim(branch)
  end

  defp normalize_version(project, "v" <> rest), do: normalize_version(project, rest)
  defp normalize_version(project, version) do
    check_version(version, project[:version])
    "v#{version}"
  end

  defp check_version(version, project_version) do
    if version != project_version do
      Mix.raise "Expected #{inspect version} to match mix.exs version #{inspect project_version}"
    end
  end

  defp check_changelog(version) do
    unless File.exists?(@changelog) do
      Mix.raise "#{@changelog} is missing"
    end

    unless File.read!(@changelog) |> String.contains?(version) do
      Mix.raise "#{@changelog} does not include an entry for #{version}"
    end
  end

  defp check_license do
    unless File.exists?(@license) do
      Mix.raise "#{@license} is missing"
    end
  end

  defp create_and_push_tag(version) do
    Mix.shell.info "Creating tag #{version}..."
    {_, 0} = System.cmd("git", ["tag", version, "-a", "-m", version])
    Mix.shell.info "done\n"

    Mix.shell.info "Pushing tag #{version}..."
    {_, 0} = System.cmd("git", ["push", "origin", version])
    Mix.shell.info "done\n"
  end

  defp publish do
    Mix.Tasks.Hex.Publish.run([])
  end
end
