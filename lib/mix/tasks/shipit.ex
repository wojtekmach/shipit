defmodule Mix.Tasks.Shipit do
  use Mix.Task

  @shortdoc "Publishes new Hex package version"

  @moduledoc """
  ShipIt automates Hex package publishing to avoid common mistakes.

      mix shipit BRANCH VERSION

  It automates these steps:

  * ensure there are no uncommited changes in the working tree
  * ensure current branch matches the given branch
  * ensure local branch is in sync with remote branch
  * ensure project version in mix.exs matches the given version
  * ensure CHANGELOG.md contains an entry for the version
  * ensure LICENSE.md file is present
  * create a git tag and push it
  * publish to Hex.pm and HexDocs.pm

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
        check_changelog(version)
        check_license()
        check_remote_branch(branch)

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

    case System.cmd("git", ["rev-parse", "--symbolic-full-name", "--abbrev-ref", "#{local_branch}@{upstream}"]) do
      {out, 0} ->
        true
      {_, _} ->
        Mix.raise "Aborting due to git error"
    end

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
